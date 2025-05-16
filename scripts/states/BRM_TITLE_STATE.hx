import objects.BGSprite;
import states.TitleState;

var text:Alphabet;
var ngSpr:FlxSprite;

var skippedIntro:Bool = false;
var transitioning:Bool = false;

var sickBeats:Int = 0;

var blackScreen:FlxSprite;
var logoBl:BGSprite;

var tempRock:FlxSprite;
var tempHell:BGSprite;

function onCreate():Void {
    if (!TitleState.initialized || FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

    FlxSprite.antialiasing = ClientPrefs.data.antialiasing;
	Conductor.bpm = 50;

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

	add(text = new Alphabet(40, 120, 'Iccer\nNickNGC\nFlying Felt Boot\nHordy17\nMintDefiance', true));
	text.setScale(0.8, 0.8);
	text.scrollFactor.set();

	add(ngSpr = new BGSprite('menus/title/durka', 40, FlxG.height * 0.44, 0, 0, ['logo'], true));
	ngSpr.visible = logoBl.visible = blackScreen.visible = false;

    FlxTween.tween(FlxG.camera.scroll, {y: 4750}, 25, {ease: FlxEase.linear, type: 2});

    if (FlxG.random.bool(0.1)) {
        FlxG.openURL('youtu.be/ld2pFUIY35M?si=7yvMWvjKhyQLk8ac');
    }

	TitleState.initialized ? skipIntro() : TitleState.initialized = true;
}

function getIntroTextShit():Array<Array<String>> {
	var fullText:String = File.getContent(Paths.txt('introText'));
	var firstArray:Array<String> = fullText.split('\n');
	var swagGoodArray:Array<Array<String>> = [];

	for (i in firstArray) swagGoodArray.push(i.split('--'));

	return swagGoodArray;
}

var gotRidOfTempAssets:Bool = false;
function onUpdate(elapsed:Float):Void {
	if (FlxG.sound.music != null) {
		Conductor.songPosition = FlxG.sound.music.time;
	}

	if (TitleState.initialized && !transitioning && skippedIntro) {
		if (controls.ACCEPT) {
			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(1, function(tmr:FlxTimer) {
				MusicBeatState.switchState(new states.MainMenuState());
				TitleState.closedState = true;
			});
		}
	}

	if (TitleState.initialized && controls.ACCEPT && !skippedIntro) skipIntro();

    if (controls.ACCEPT && !gotRidOfTempAssets) {
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

function createCoolText(textArray:String, ?offset:Float = 0):Void {
	text.y = 120 + offset;
	text.text = textArray;
}

function addMoreText(textArray:String):Void {
	text.text += '\n' + textArray;
}

function deleteCoolText():Void {
	text.text = '';
}

function onBeatHit(beat:Int):Void {
	if (TitleState.closedState || skippedIntro) return;
    
    sickBeats++;
	switch sickBeats {
		case 2:
			addMoreText('\nPresent');
		case 3:
			deleteCoolText();
            createCoolText('From Russia', 180);
		case 6:
			addMoreText('With love');
		case 7:
			deleteCoolText();
            createCoolText('Inspired by', 180);
		case 10:
			addMoreText('17 bucks');
		case 11:
			deleteCoolText();
            createCoolText('idk', 180);
		case 14:
			addMoreText('idk');
		case 15:
			deleteCoolText();
            createCoolText('idk', 180);
        case 18:
			addMoreText('idk');
		case 19:
			deleteCoolText();
            createCoolText('Powered\nby', -20);
        case 22:
            addMoreText('Durkagrad');
			ngSpr.visible = blackScreen.visible = true;
        case 23:
			deleteCoolText();
            ngSpr.visible = blackScreen.visible = false;
            createCoolText('idk', 180);
        case 26:
            addMoreText('idk');
		case 27:
            deleteCoolText();
            logoBl.visible = true;
			createCoolText('28', 140);
		case 28:
			addMoreText('BRM');
		case 29:
			addMoreText('Season 1');
		case 31:
			skipIntro();
	}
}

function isOnScreen(sprite:BGSprite):Bool {
	@:privateAccess return FlxG.camera.containsRect(sprite.getScreenBounds(sprite._rect, FlxG.camera)); //for some reason regular isOnScreen didnt want to work??????
}

function skipIntro():Void {
    if (skippedIntro) return;

	remove(ngSpr);
    remove(text);
	FlxG.camera.flash(FlxColor.WHITE, 4);
	skippedIntro = logoBl.visible = true;
}