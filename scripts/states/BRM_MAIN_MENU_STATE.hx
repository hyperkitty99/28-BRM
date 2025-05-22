import objects.BGSprite;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.effects.FlxSkewedSprite;
import states.PlayState;
import backend.Song;

var skew:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shaderFragment('skew')));
var lightSkew:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shaderFragment('skew')));

var zoomedIn:Bool = false;
var tvOn:Bool = false;
var grabbedDVD:Bool = false;

var camDoors:FlxCamera;
var camScreen:FlxCamera;

var thing:FlxRuntimeShader = createRuntimeShader('barrel');

var insertedDVD:Bool = false;

function onCreate():Void {
    camDoors = new FlxCamera();
    camScreen = new FlxCamera();
    camDoors.bgColor = camScreen.bgColor = 0x00000000;

    FlxG.cameras.add(camDoors, false);
    FlxG.cameras.add(camScreen, false);

    camDoors.filters = [new ShaderFilter(thing), new ShaderFilter(createRuntimeShader('ntsc'))];
}

function createDoorsStuff():Void {
    addSprite('bg', [130, -10], [0.625], 'pc/doors', false, camDoors);
    getVar('bg').scale.set(0.535, 0.515);

    addSprite('welcome', [135, -10], [0.625], 'pc/doors', false, camDoors);
    getVar('welcome').scale.set(0.535, 0.535);
    getVar('welcome').visible = false;

    addSprite('doors', [401, 120], [0.625], 'pc/doors', false, camDoors);
    getVar('doors').scale.set(0.535, 0.515);

    addSprite('bar0', [500, 480.5], [0.625], 'pc/doors', true, camDoors);
    getVar('bar0').scale.set(0.535, 0.515);

    addSprite('load', [415, 300], [0.625], 'pc/doors', false, camDoors);
    getVar('load').scale.set(0.535, 0.515);

    addSprite('barloading0', [450, 361], [0.625], 'pc/doors', false, camDoors);
    getVar('barloading0').scale.set(0.535, 0.515);
    getVar('barloading0').animation.stop();

    addSprite('screen', [-11, 120], [0.61], 'screen', false, camScreen);
    addSprite('monitor', [-11, -86], [0.625], 'mainmenu', false, camScreen);

    getVar('doors').visible = getVar('bar0').visible = false;
}

var letimer:FlxTimer;
var letimer2:FlxTimer;
var isPcStarting:Bool = false;
var pcFullySetup:Bool = false;

function onCreatePost():Void {
    createDoorsStuff();

    addSprite('window', [516, -12], [0.15]);
    addSprite('stickies', [-174, 107], [0.15]);
    addSprite('door', [1345, 188], [0.15]);

    addSprite('table', [-1881, 890], [1], 'table');
    getVar('table').shader = skew;
    getVar('table').scale.set(2, 2);

    addSprite('tissue', [-132, 475], [0.4]);
    addSprite('kvas', [1176, 321], [0.4]);
    addSprite('tv dark', [336, 182], [0.61]);

    addSprite('light', [-939, 1100], [1.6], 'light');
    getVar('light').shader = lightSkew;
    getVar('light').scale.set(2, 2);

    addSprite('glow', [385, 685], [0.625], 'glow');
    getVar('glow').alpha = 0;

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
    camScreen.scroll.y = FlxG.camera.scroll.y = 78.5;
    FlxG.camera.bgColor = 0xFF0A0E15;

    letimer = new FlxTimer();
    letimer2 = new FlxTimer();
}

var titleTimer:Float = 0;
function onUpdatePost(elapsed:Float):Void {
    titleTimer = (titleTimer + elapsed) % 2;

	final timer = FlxEase.quadInOut(titleTimer >= 1 ? 2 - titleTimer : titleTimer);

    if (controls.BACK) {
        if (!zoomedIn) {
            MusicBeatState.switchState(new CustomState('BRM_TITLE_STATE'));
        } else {
            zoomedIn = false;
        }
    }

    if (FlxG.keys.justPressed.Q) {
        if (grabbedDVD) {
            insertedDVD = !insertedDVD;
            getVar('barloading0').animation.play('barloading0');
            getVar('barloading0').animation.timeScale = FlxG.random.float(0.5, 2);
            getVar('barloading0').animation.onFinish.add(loadSong);
        }
    }

    if (globalStatic.get('firstTime')) {
        glow.alpha = FlxMath.lerp(0.65, 0, timer);
    }

    if (controls.ACCEPT) {
        zoomedIn = !zoomedIn;
    }

    getVar('barloading0').visible = getVar('load').visible = grabbedDVD && insertedDVD && tvOn && pcFullySetup;

    if (FlxG.mouse.overlaps(getVar('glow')) && FlxG.mouse.justPressed) {
        if(globalStatic.get('firstTime')) {
            globalStatic.set('firstTime', false);
            glow.alpha = 0;
        }
        tvOn = !tvOn;
        if (tvOn) {
            zoomedIn = true;
        }
        isPcStarting = false;

        getVar('welcome').visible = tvOn;

        if (letimer2 != null) {
            letimer2.destroy();
        }

        if (letimer != null) {
            letimer.destroy();
        }


        if (tvOn) {
            letimer.start(5, startPC);

            getVar('bg').color = getVar('welcome').color = FlxColor.BLACK;
        }

        getVar('doors').visible = getVar('bar0').visible = tvOn;
    }

    if (isPcStarting) {
        getVar('bg').color = getVar('welcome').color = FlxColor.WHITE;
        getVar('welcome').visible = true;
        getVar('doors').visible = getVar('bar0').visible = false;
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
    }

    getVar('bg').alpha = tvOn ? 1 : 0.00001;
    getVar('light').visible = getVar('shadow').visible = tvOn;

    FlxG.camera.zoom = camScreen.zoom = camDoors.zoom = FlxMath.lerp(FlxG.camera.zoom, zoomedIn ? 1.85 : 0.5, 10 * elapsed);

	camScreen.scroll.x = camScreen.scroll.x = FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, zoomedIn ? 0 : FlxMath.bound(FlxG.mouse.x - 640, -900, 900) * FlxG.camera.zoom * 0.5, 10 * elapsed);

    camDoors.x = -camScreen.scroll.x / 3.25;

    thing.setFloat('distortionX', 0.6 - Math.abs((FlxG.camera.zoom - 1.85) / 2));
    thing.setFloat('distortionY', 0.9 - Math.abs((FlxG.camera.zoom - 1.85) / 2));
}

function loadSong():Void {
    if (!zoomedIn) {
        zoomedIn = true;

        FlxTimer.wait(0.5, playSong);
    } else {
        playSong();
    }
}

function playSong():Void {
    PlayState.SONG = Song.loadFromJson('russophobia', 'russophobia');
    PlayState.isStoryMode = false;
    FlxG.switchState(new PlayState());
    FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
}

function startPC(_:FlxTimer):Void {
    isPcStarting = true;

    if (letimer2 != null) {
        letimer2.destroy();
    }

    letimer2.start(5, welcomeToTheUnderground);
}

function welcomeToTheUnderground(_:FlxTimer):Void {
    pcFullySetup = true;
    isPcStarting = false;
    getVar('welcome').visible = false;
    FlxG.sound.play(Paths.sound('Microsoft Windows XP Startup Sound - Ballyweg'));
}

function addSprite(name:String, ?pos:Array<Float> = [0, 0], ?scroll:Array<Float> = [1, 1], ?prefix:String = null, ?loop:Bool = false, ?camera:FlxCamera):Void {
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
    if (camera != null) sprite.camera = camera;
    setVar(name, sprite);
    add(sprite);
}