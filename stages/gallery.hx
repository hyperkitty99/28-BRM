import objects.BGSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

//dude i HATE psych engine
function onCreate():Void {
    game.gf.visible = false;

    addSprite('bg', 7800, 2000, 0.1, 0.1, ['sun']);
    addSprite('bg', 556, -304, 0.5, 0.5, ['clouds']);
    addSprite('bg', 750, 550, 0.6, 0.6, ['bg']);
    addSprite('bg', -200, 1350, 0.825, 0.825, ['road']);
    addSprite('bg', 1615, 19, 0.85, 0.85, ['building']);
}

function onCreatePost():Void {
    game.camGame.bgColor = 0xFFFFFFFF;

    game.camFollow.setPosition(getVar('building').getMidpoint().x - 150, getVar('building').getMidpoint().y - 1000);
    isCameraOnForcedPos = true;
}

function onCountdownTick(tick:Countdown):Void {
    isCameraOnForcedPos = false;
    if (tick == Countdown.START) FlxTween.num(getVar('building').getMidpoint().y - 1000, 1250, 4.5, {ease: FlxEase.sineInOut}, onYChange);
}

function onYChange(value:Float):Void {
    game.camFollow.x = getVar('building').getMidpoint().x - 150;
    game.camFollow.y = value;
}

function addSprite(name:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false):Void {
    var sprite:BGSprite = new BGSprite('gallery/' + name, x * scrollX, y * scrollY, scrollX, scrollY, animArray == null ? [name] : animArray, loop);
    setVar(animArray[0], sprite);
    addBehindDad(sprite);
}