function onCreate():Void {
    game.gf.visible = false;
}

function onCreatePost():Void {
    game.camGame.bgColor = 0xFF666666;
}

function onBeatHit():Void {
    game.variables['speaker'].animation.play('speaker', true);
}