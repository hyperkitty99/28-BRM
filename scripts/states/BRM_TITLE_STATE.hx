import flixel.input.gamepad.FlxGamepad;
import flixel.group.FlxTypedGroup;
import objects.BGSprite;
import states.TitleState;

var textGroup:FlxTypedGroup<Alphabet>;
var ngSpr:FlxSprite;

var skippedIntro:Bool = false;
var transitioning:Bool = false;

var sickBeats:Int = 0;

var blackScreen:FlxSprite;
var logoBl:BGSprite;

var tempRock:FlxSprite;
var tempHell:BGSprite;

function onCreate():Void {
	Paths.clearStoredMemory();

    if (!TitleState.initialized || FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

    FlxSprite.antialiasing = ClientPrefs.data.antialiasing;
	Conductor.bpm = 50;
	persistentUpdate = true;

    add(new BGSprite('menus/title/sky', 0, 1094, 1, 0.4));
    add(new BGSprite('menus/title/mountains', 0, 3300, 1, 0.6));
    add(new BGSprite('menus/title/sky', 0, -806, 1, 0.4));
    add(new BGSprite('menus/title/mountains', 0, 451, 1, 0.6));
    add(new BGSprite('menus/title/factory', 995, 992, 1, 0.7));
    add(new BGSprite('menus/title/cityBG', 0, 1429, 1, 0.8));
    add(new BGSprite('menus/title/city', 0, 1661, 1, 0.9));
	add(new BGSprite('menus/title/hell', 0, 2790));
    add(new BGSprite('menus/title/transitionRock', 0, 2982, 1, 1.2));

    logoBl = new BGSprite('menus/title/logoBumpin', 0, 0, 0, 0);
	logoBl.scale.set(0.6, 0.6);
	logoBl.updateHitbox();
	logoBl.screenCenter();
	add(logoBl);

    add(tempHell = new BGSprite('menus/title/hell', 0, 2790));
    add(tempRock = new BGSprite('menus/title/transitionRock', 0, 2982, 1, 1.2));

    add(blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
    blackScreen.scrollFactor.set();

	var dBar = new FlxSprite(0, FlxG.height - 75).makeGraphic(1280, 75, FlxColor.BLACK);
    dBar.scrollFactor.set();
	add(dBar);

	var uBar = new FlxSprite().makeGraphic(1280, 75, FlxColor.BLACK);
    uBar.scrollFactor.set();
	add(uBar);

	add(textGroup = new FlxTypedGroup());

	add(ngSpr = new BGSprite('menus/title/durka', 40, FlxG.height * 0.44, 0, 0, ['logo'], true));
	ngSpr.visible = logoBl.visible = blackScreen.visible = false;

    FlxTween.tween(FlxG.camera.scroll, {y: 4750}, 25, {ease: FlxEase.linear, type: 2});

    createCoolText(['28 BRM by'], -20);

    if (FlxG.random.bool(0.1)) {
        FlxG.openURL('youtu.be/ld2pFUIY35M?si=7yvMWvjKhyQLk8ac');
    }

	TitleState.initialized ? skipIntro() : TitleState.initialized = true;

	Paths.clearUnusedMemory();
}

function getIntroTextShit():Array<Array<String>> {
	var fullText:String = File.getContent(Paths.txt('introText'));
	var firstArray:Array<String> = fullText.split('\n');
	var swagGoodArray:Array<Array<String>> = [];

	for (i in firstArray) swagGoodArray.push(i.split('--'));

	return swagGoodArray;
}

var gotRidOfTempAssets:Bool = false;
function onUpdate(elapsed:Float) {
	if (FlxG.sound.music != null)
		Conductor.songPosition = FlxG.sound.music.time;

	var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

	var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

	if (gamepad != null) if (gamepad.justPressed.START) pressedEnter = true;

	if (TitleState.initialized && !transitioning && skippedIntro)
	{
		if(pressedEnter)
		{
			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(1, function(tmr:FlxTimer) {
				MusicBeatState.switchState(new states.MainMenuState());
				TitleState.closedState = true;
			});
		}
	}

	if (TitleState.initialized && pressedEnter && !skippedIntro) skipIntro();

    if (pressedEnter && !gotRidOfTempAssets) {
        tempRock.destroy();
        tempHell.destroy();
        gotRidOfTempAssets = true;
    }

    if (skippedIntro && !gotRidOfTempAssets) {
        if (!isOnScreen(tempRock)) {
            tempRock.destroy();
            tempHell.destroy();
            gotRidOfTempAssets = true;
        }
    }
}

function createCoolText(textArray:Array<String>, ?offset:Float = 0) {
	for (i in 0...textArray.length) {
		var money:Alphabet = new Alphabet(40, (i * 60) + 200 + offset, textArray[i], true);
        money.scrollFactor.set();
		textGroup.add(money);
	}
}

function addMoreText(text:String, ?offset:Float = 0) {
	var coolText:Alphabet = new Alphabet(40, (textGroup.length * 60) + 200 + offset, text, true);
    coolText.scrollFactor.set();
	textGroup.add(coolText);
}

function deleteCoolText() {
	textGroup.clear();
}

function onBeatHit(beat:Int) {
	if(TitleState.closedState || skippedIntro) return;
    
    sickBeats++;
	switch sickBeats {
		case 3:
			addMoreText('Iccer', -20);
            addMoreText('NickNGC', -20);
            addMoreText('Flying Felt Boot', -20);
			addMoreText('Hordy17', -20);
			addMoreText('MintDefiance', -20);
		case 4:
			deleteCoolText();
            createCoolText(['From Russia'], 80);
		case 7:
			addMoreText('With love', 80);
		case 8:
			deleteCoolText();
            createCoolText(['Inspired by'], 80);
		case 11:
			addMoreText('17 bucks', 80);
		case 12:
			deleteCoolText();
            createCoolText(['idk'], 80);
		case 15:
			addMoreText('idk', 80);
		case 16:
			deleteCoolText();
            createCoolText(['idk'], 80);
        case 19:
			addMoreText('idk', 80);
		case 20:
			deleteCoolText();
            createCoolText(['Powered', 'by'], -75);
        case 23:
            addMoreText('Durkagrad', -75);
			ngSpr.visible = blackScreen.visible = true;
        case 24:
			deleteCoolText();
            ngSpr.visible = blackScreen.visible = false;
            createCoolText(['idk'], 80);
        case 27:
            addMoreText('idk', 80);
		case 28:
            deleteCoolText();
            logoBl.visible = true;
			addMoreText('28');
		case 29:
			addMoreText('BRM');
		case 30:
			addMoreText('Season 1');
		case 32:
			skipIntro();
	}
}

function isOnScreen(sprite:BGSprite):Bool
{
	@:privateAccess return FlxG.camera.containsRect(sprite.getScreenBounds(sprite._rect, FlxG.camera));
}

function skipIntro():Void {
    if (skippedIntro) return;

	remove(ngSpr);
    remove(textGroup);
	FlxG.camera.flash(FlxColor.WHITE, 4);
	skippedIntro = logoBl.visible = true;
}