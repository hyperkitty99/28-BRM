function createSprite(name:String, ?x:Float = 0, ?y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1):BGSprite {
    var sprite:BGSprite = new BGSprite('menus/main/' + name, x, y, scrollX, scrollY, [name], false);
    sprite.animation.play(name);
    return sprite;
}

function createAnimatedSprite(name:String, ?x:Float = 0, ?y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String>, ?loop:Bool = false):BGSprite {
    var sprite:BGSprite = new BGSprite('menus/main/' + name, x, y, scrollX, scrollY, animArray, loop);
    if (animArray != null && animArray.length > 0) sprite.animation.play(animArray[0]);
    return sprite;
}