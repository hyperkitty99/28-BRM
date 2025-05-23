function onEvent(name:String, val1:String, val2:String):Void {
    if (name != 'Cam Flash') return;

    FlxG.camera.flash(0xFFFFFFFF, Std.parseFloat(val1));
}