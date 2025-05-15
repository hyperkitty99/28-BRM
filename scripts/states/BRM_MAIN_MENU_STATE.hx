function onCreatePost():Void {
}

function onUpdatePost(elapsed:Float):Void {
    if (controls.BACK) {
        MusicBeatState.switchState(new CustomState('BRM_TITLE_STATE'));
    }
}