import objects.BGSprite;
import flixel.group.FlxTypedGroup;
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.effects.FlxSkewedSprite;

typedef Sprite = {name:String, sprite:FlxSprite}

function createSprite(name:String, ?x:Float = 0, ?y:Float = 0, ?scrollX:Float = null, ?scrollY:Float = null, ?prefix:String = null, ?loop:Bool = false):Sprite {
    var sprite:FlxSkewedSprite = new FlxSkewedSprite(x, y);
    sprite.frames = Paths.getSparrowAtlas(prefix != null ? 'menus/main/' + prefix : 'menus/main/mainmenu');

    if (sprite.frames != null) {
        sprite.animation.addByPrefix(name, name, 24, loop);
        sprite.animation.play(name);
    } else {
        sprite.loadGraphic(Paths.image(name));
    }

    sprite.updateHitbox();
    sprite.scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
    return {name: name, sprite: sprite};
}

var skew:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shaderFragment('skew')));
var skew2:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shaderFragment('skew')));
var skew3:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shaderFragment('skew')));
var lightSkew:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shaderFragment('skew')));

var objects:Array<Sprite> = [
    createSprite('window', 516, -212, 0.15, 0.15),
    createSprite('stickies', -174, -93, 0.15, 0.15),
    createSprite('door', 1345, -12, 0.15, 0.15),
    createSprite('table', -1881, 690, 1, 1, 'table'),
    createSprite('tissue', -132, 275, 0.4, 0.25),
    createSprite('kvas', 1176, 121, 0.4, 0.25),
    createSprite('tv dark', 336, -18, 0.6395, 0.415),
    createSprite('light', -939, 900, 1.6, 1.35, 'light'),
    createSprite('static', 364, 39, 0.6395, 0.415, 'mainmenu', true),
    createSprite('screen', -11, -80, 0.635, 0.415, 'screen'),
    createSprite('monitor', -11, -286, 0.65, 0.43),
    createSprite('tv light', 325, -10, 0.65, 0.43),
    //createSprite('shadow', 679, 661),
    createSprite('other', -830, 520, 0.85, 0.61, 'other'),
    createSprite('long', -460, 490, 1.125, 0.61, 'long'),
    createSprite('bud zdorov', -932, 525, 1.1, 0.555, 'bud zdorov'),
    createSprite('drink', -537, 60, 0.86, 0.465),
    createSprite('icon', 107, 530, 0.78, 0.5),
    createSprite('books', 1233, 467, 0.8, 0.495),
    createSprite('ffb', 1513, -97, 0.8, 0.495)
];

var disc:BGSprite; 

var tvOn:Bool = false;

function onCreatePost():Void {
    for (object in objects) {
        add(object.sprite);
    }

    for (object in objects) {
        object.sprite.y += 200;
    }

    getProp('table').shader = skew;
    getProp('bud zdorov').shader = skew2;
    getProp('bud zdorov').scale.set(2, 2);
    getProp('long').origin.set(0, getProp('long').height);
    getProp('other').origin.set(0, getProp('other').height);
    getProp('light').shader = lightSkew;
    getProp('light').scale.set(2, 2);

    //add(disc = new BGSprite('menus/main/discs', 685, 851, 1, 0.6, ['disc']));
    //disc.updateHitbox();
    //disc.origin.y = 0;
    //disc.dance(true);

    FlxG.camera.zoom = 0.5;
    FlxG.camera.bgColor = 0xFF0A0E15;
}

function onUpdatePost(elapsed:Float):Void {
    if (controls.BACK) {
        MusicBeatState.switchState(new CustomState('BRM_TITLE_STATE'));
    }

    if (controls.ACCEPT) {
        tvOn = !tvOn;
    }

    skew2.setFloat('skew', (FlxG.camera.scroll.x / 500) / 2);
    lightSkew.setFloat('skew', (FlxG.camera.scroll.x / 650) / 2.6);
    skew.setFloat('skew', (FlxG.camera.scroll.x / 1280) / 2.5);
    getProp('table').scale.set(2, (-(FlxG.camera.scroll.y / 720) * 2) + 2);
    getProp('light').scale.y = (-(FlxG.camera.scroll.y / 720) * 2) + 2;
    getProp('bud zdorov').scale.set(2, (-(FlxG.camera.scroll.y / 720) * 1.8) + 2);
    getProp('long').scale.set((FlxG.camera.scroll.x / 1050) + 1, (-(FlxG.camera.scroll.y / 720) * 0.5) + 1);
    getProp('other').scale.set((FlxG.camera.scroll.x / getProp('other').x) / 1.6 + 1, (-(FlxG.camera.scroll.y / 720) * 0.5) + 1);

    getProp('other').skew.y = (FlxG.camera.scroll.y / 720) * -1;
    getProp('long').skew.y = FlxG.camera.scroll.y / 250;

    //disc.scale.y = (-(FlxG.camera.scroll.y / 720) / 1.3) + 1;

    //disc.color = tvOn ? FlxColor.WHITE : 0xFFBDBDBD;

    for (object in [getProp('light'), getProp('static'), getProp('tv light')/*, getProp('shadow')*/]) {
        object.visible = tvOn;
    }

	final point = [FlxMath.bound(FlxG.mouse.x, getProp('table').x, getProp('table').width - 4000), FlxMath.bound(FlxG.mouse.y, 0, 450)];
	FlxG.camera.scroll.set(
		FlxMath.lerp(point[0] * FlxG.camera.zoom * 0.5, FlxG.camera.scroll.x, Math.exp(-elapsed * 25)), 
		FlxMath.lerp(point[1] * FlxG.camera.zoom * 0.5, FlxG.camera.scroll.y, Math.exp(-elapsed * 25))
	);
}

function getProp(name:String):BGSprite {
    for (object in objects) {
        if (object.name == name) {
            return object.sprite;
        }
    }
    return null;
}