import states.TitleState;

function onCreatePost():Void {
    TitleState.initialized = false;
    FlxG.sound.music = null;
    FlxG.switchState(new CustomState('BRM_TITLE_STATE'));
}