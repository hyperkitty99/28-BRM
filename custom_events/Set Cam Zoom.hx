import psychlua.LuaUtils;

var camTween:FlxTween;

function onEvent(name:String, val1:String, val2:String):Void {
    if (name != 'Set Cam Zoom') return;

    final val:String = val1.split(',');

    if (camTween != null) camTween.cancel();
    camTween = FlxTween.num(game.defaultCamZoom, Std.parseFloat(val[0]), Std.parseFloat(val[1]) ?? 1, {ease: LuaUtils.getTweenEaseByString(val2) ?? FlxEase.sineInOut}, applyTween);
}

function applyTween(value:Float):Void {
    game.defaultCamZoom = value;
}