import objects.BGSprite;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.effects.FlxSkewedSprite;
import states.PlayState;
import backend.Song;

function addSprite(name:String, ?pos:Array<Float> = [0, 0], ?scroll:Array<Float> = [1, 1], ?prefix:String = null, ?loop:Bool = false):Void {
    var sprite:FlxSkewedSprite = new FlxSkewedSprite(pos[0] ?? 0, pos[1] ?? 0);
    sprite.antialiasing = ClientPrefs.data.antialiasing;

    var path:String = prefix != null ? 'menus/main/' + prefix : 'menus/main/mainmenu';

    if (FileSystem.exists(Paths.modsXml(path))) {
        sprite.frames = Paths.getSparrowAtlas(path);
        sprite.animation.addByPrefix(name, name, 24, loop);
        sprite.animation.play(name);
    } else {
        sprite.loadGraphic(Paths.image(path));
    }

    sprite.updateHitbox();
    sprite.scrollFactor.set(scroll[0] ?? 1, scroll[1] ?? 1);
    setVar(name, sprite);
    add(sprite);
}

var skew:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shaderFragment('skew')));
var lightSkew:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shaderFragment('skew')));

var zoomedIn:Bool = false;
var tvOn:Bool = false;
var grabbedDVD:Bool = false;

function onCreatePost():Void {
    addSprite('window', [516, -12], [0.15]);
    addSprite('stickies', [-174, 107], [0.15]);
    addSprite('door', [1345, 188], [0.15]);

    addSprite('table', [-1881, 890], [1], 'table');
    getVar('table').shader = skew;
    getVar('table').scale.set(2, 2);

    addSprite('tissue', [-132, 475], [0.4]);
    addSprite('kvas', [1176, 321], [0.4]);
    addSprite('tv dark', [336, 182], [0.6145]);

    addSprite('light', [-939, 1100], [1.6], 'light');
    getVar('light').shader = lightSkew;
    getVar('light').scale.set(2, 2);

    addSprite('static', [364, 239], [0.6145], 'mainmenu', true);
    addSprite('screen', [-11, 120], [0.61], 'screen');
    addSprite('monitor', [-11, -86], [0.625]);
    addSprite('glow', [385, 690], [0.625], 'glow');

    addSprite('tv light', [332, 206], [0.625]);
    addSprite('shadow', [679, 861], [1, 1]);

    addSprite('other', [-830, 720], [0.85], 'other');
    getVar('other').origin.set(0, getVar('other').height);

    addSprite('long', [-460, 690], [1.125], 'long');
    getVar('long').origin.set(0, getVar('long').height);
    
    addSprite('bud zdorov', [-790, 655], [0.885], 'bud zdorov');
    addSprite('drink', [-537, 260], [0.84]);
    addSprite('icon', [107, 730], [0.78]);
    addSprite('books', [1233, 667], [0.8]);
    addSprite('ffb', [1513, 103], [0.8]);

    addSprite('disc', [685, 851], [0.9], 'disc');
    getVar('disc').origin.set(0, 0);

    for (member in members) {
        member.x += 16;
    }

    FlxG.camera.zoom = 0.5;
    FlxG.camera.bgColor = 0xFF0A0E15;
}

function onUpdatePost(elapsed:Float):Void {
    if (controls.BACK) {
        if (!zoomedIn) {
            MusicBeatState.switchState(new CustomState('BRM_TITLE_STATE'));
        } else {
            zoomedIn = false;
        }
    }

    if (controls.ACCEPT) {
        zoomedIn = !zoomedIn;
    }

    if (FlxG.mouse.overlaps(getVar('glow')) && FlxG.mouse.justPressed) {
        if (!tvOn) zoomedIn = !zoomedIn;
        tvOn = !tvOn;
    }

    if (FlxG.mouse.overlaps(getVar('ffb')) && FlxG.mouse.justPressed) {
        if (FlxG.random.bool(100 / ClientPrefs.data.framerate)) FlxG.sound.play(Paths.sound('WHAT'));
    }

    getVar('bud zdorov').skew.x = (FlxG.camera.scroll.x / -6.3);
    lightSkew.setFloat('skew', (FlxG.camera.scroll.x / 650) / 2.6);
    skew.setFloat('skew', (FlxG.camera.scroll.x / 1280) / 2.5);

    getVar('long').scale.x = (FlxG.camera.scroll.x / 1050) + 1;
    getVar('other').scale.x = (FlxG.camera.scroll.x / getVar('other').x) / 1.6 + 1;

    var disc = getVar('disc');

    disc.color = tvOn ? FlxColor.WHITE : 0xFFBDBDBD;
    disc.skew.x = (FlxG.camera.scroll.x / -7.2);

    if (FlxG.mouse.overlaps(disc) && FlxG.mouse.justPressed) {
        grabbedDVD = true;
    }

    if (grabbedDVD) {
        disc.setPosition(FlxMath.lerp(disc.x, (-FlxG.camera.scroll.x) + 1000, 2 * elapsed), FlxMath.lerp(disc.y, 1400, 2 * elapsed));
        disc.scale.x = disc.scale.y = FlxMath.lerp(disc.scale.x, 1.7, 2 * elapsed);
        if (tvOn) {
            tvOn = false;
			PlayState.SONG = Song.loadFromJson('russophobia', 'russophobia');
			PlayState.isStoryMode = false;
            FlxG.switchState(new PlayState());
            FlxTransitionableState.skipNextTransOut = FlxTransitionableState.skipNextTransIn = true;
        }
    }

    getVar('light').visible = getVar('static').visible = getVar('tv light').visible = getVar('shadow').visible = tvOn;

    FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, zoomedIn ? 78.5 : 0, 10 * elapsed);
    FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, zoomedIn ? 1.85 : 0.5, 10 * elapsed);

	FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, zoomedIn ? 0 : FlxMath.bound(FlxG.mouse.x - 640, -900, 900) * FlxG.camera.zoom * 0.5, 10 * elapsed);
}