import states.TitleState;
import openfl.text.TextFormat;
import Main;

function onCreatePost():Void {
    TitleState.initialized = false;
    FlxG.sound.music = null;
    FlxG.switchState(new CustomState('BRM_TITLE_STATE'));

    Main.fpsVar.x = Main.fpsVar.y = 10;
    Main.fpsVar.defaultTextFormat = new TextFormat(Paths.font('FallingSkyBlk.otf'), 13, 0xFFFFFFFF);
    Main.fpsVar.alpha = 1;

    globalStatic.set('firstTime', true);

	globalStatic.set('curWacky', curWacky);
	globalStatic.set('curWacky2', getIntroTextShit()[FlxG.random.int(0, getIntroTextShit().length - 1)]);
}