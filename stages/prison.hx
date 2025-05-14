function onCreate():Void {
    game.gf.visible = false;
}

function onBeatHit():Void {
    game.variables['speaker'].animation.play('speaker', true);
}