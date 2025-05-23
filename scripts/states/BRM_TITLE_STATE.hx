import objects.BGSprite;
import states.TitleState;
import flixel.addons.transition.FlxTransitionableState;

var text:Alphabet;

var reAddedLogo:Bool = false;
var skippedIntro:Bool = false;
var transitioning:Bool = false;

var sickBeats:Int;

var blackScreen:FlxSprite;
var logoBl:BGSprite;
var ngSpr:BGSprite;
var rock:BGSprite;

function onCreate():Void {
    if (!TitleState.initialized || FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

	Conductor.bpm = 100;

	var barCam = new FlxCamera();
	FlxG.cameras.add(barCam, false).bgColor = 0x00000000;

	FlxTransitionableState.skipNextTransOut = true;

    add(new BGSprite('menus/title/title', 0, 1094, 1, 0.4, ['sky']));
    add(new BGSprite('menus/title/title', 0, -806, 1, 0.4, ['sky']));
    add(new BGSprite('menus/title/title', 0, 451, 1, 0.6, ['mountains']));
	add(new BGSprite('menus/title/title', 0, 3300, 1, 0.6, ['mountains']));
    add(new BGSprite('menus/title/title', 995, 992, 1, 0.7, ['factory']));
    add(new BGSprite('menus/title/title', 0, 1429, 1, 0.8, ['BGCity']));
    add(new BGSprite('menus/title/title', 0, 1661, 1, 0.9, ['city']));

	add(logoBl = new BGSprite('menus/title/logo', 0, 0, 0, 0));
	logoBl.scale.set(0.6, 0.6);
	logoBl.updateHitbox();
	logoBl.screenCenter();

	add(new BGSprite('menus/title/title', 0, 2790, 1, 1, ['hell']));
    add(rock = new BGSprite('menus/title/title', 0, 2982, 1, 1.2, ['rock']));

    add(blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
    blackScreen.scrollFactor.set();

	for (i in 0...2) {
		var bar = new FlxSprite(0, (FlxG.height - 75) * i).makeGraphic(FlxG.width, 75, FlxColor.BLACK);
    	bar.scrollFactor.set();
		bar.camera = barCam;
		add(bar);
	}

	add(text = new Alphabet(40, 120, 'Iccer\nNickNGC\nFlying Felt Boot\nHordy17\nMintDefiance', true));
	text.scrollFactor.set();
	text.setScale(0.8, 0.8);

	add(ngSpr = new BGSprite('menus/title/durka', 40, FlxG.height * 0.4, 0, 0, ['logo'], true));
	ngSpr.visible = logoBl.visible = blackScreen.visible = false;

    if (FlxG.random.bool(1 / ClientPrefs.data.framerate)) {
        FlxG.openURL(FlxG.random.bool(0.00001) ? 'youtu.be/49aRGtyy9VM?si=SglmU_V9EPB9xLxI' : 'youtu.be/ld2pFUIY35M?si=7yvMWvjKhyQLk8ac');
    }

	if (FlxG.random.bool(0.5 / ClientPrefs.data.framerate)) {
		FlxG.openURL('youtu.be/HtgEQeMb4Uc?si=jgWu59pREBNqm_NX');
	}

	TitleState.initialized ? skipIntro(true) : TitleState.initialized = true;
}

function onUpdate(elapsed:Float):Void {
	if (FlxG.sound.music.volume < 0.7)
		FlxG.sound.music.volume += 0.01 * elapsed;

	FlxG.camera.scroll.y = FlxG.camera.scroll.y < 4750 ? FlxG.camera.scroll.y + 190 * elapsed : 0;

	if (FlxG.sound.music != null) {
		Conductor.songPosition = FlxG.sound.music.time;
	}

	if (TitleState.initialized && controls.ACCEPT) {
		if (!skippedIntro) {
			skipIntro(true);
		} else if (!transitioning) {
			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			FlxTimer.wait(1, MusicBeatState.switchState.bind(new states.MainMenuState()));
		}
	}

    if (!reAddedLogo && !rock.isOnScreen() && skippedIntro) {
		reAddLogo();
	}
}

function reAddLogo():Void {
	remove(logoBl);
	insert(10, logoBl);
	reAddedLogo = true;
}

function createText(textArray:String, ?offset:Float = 0):Void {
	text.y = 120 + offset;
	text.text = textArray;
}

function addMoreText(textArray:String):Void {
	text.text += '\n' + textArray;
}

function onBeatHit(beat:Int):Void {
	if (skippedIntro) return;
    
    sickBeats++;
	switch sickBeats {
		case 3:  addMoreText('\nPresent');
		case 4:  createText('From Russia', 180);
		case 7:  addMoreText('With love');
		case 8:  createText('Inspired by', 180);
		case 11: addMoreText('17 bucks');
		case 12: createText(globalStatic['curWacky'][0], 180);
		case 15: addMoreText(globalStatic['curWacky'][1]);
		case 16: createText(globalStatic['curWacky2'][0], 180);
		case 19: addMoreText(globalStatic['curWacky2'][1], 180);
		case 20: createText('Powered\nby', -30);
		case 23:
            addMoreText('Durkagrad');
			ngSpr.visible = blackScreen.visible = logoBl.visible = true;
        case 24:
            ngSpr.visible = blackScreen.visible = false;
            createText('pemza', 180);
        case 27: addMoreText('pemza');
		case 28: createText('28', 140);
		case 29: addMoreText('BRM');
		case 30: addMoreText('Season 1');
		case 32: skipIntro();
	}
}

function skipIntro(?reAdd:Bool = false):Void {
    if (skippedIntro) return;

	for (obj in [ngSpr, text]) remove(obj);

	FlxG.camera.flash(FlxColor.WHITE, 2);
	skippedIntro = logoBl.visible = true;
	if (reAdd) reAddLogo();
}