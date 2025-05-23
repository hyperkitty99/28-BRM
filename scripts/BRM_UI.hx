import objects.BGSprite;
import psychlua.CustomSubstate;
using StringTools;
import Main;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import lime.graphics.Image;
import openfl.Lib;
import flixel.FlxObject;
import backend.Highscore;
import backend.Song;
import backend.WeekData;
import backend.Discord.DiscordClient;
import backend.Mods;
import states.LoadingState;
import flixel.addons.transition.FlxTransitionableState;

var skinPath:String = 'noteSkins/' + game.dad.curCharacter + '/';

var playerBG:BGSprite;
var opponentBG:BGSprite;

var debugMode:Bool = false;
var camBG:FlxCamera;
var bg:BGSprite;

var storedFilters:Array<ShaderFilter> = [];

function onCreate():Void {
    camBG = new FlxCamera();
    camBG.bgColor = 0x00000000;
    FlxG.cameras.add(camBG, false);

    camGame.filters = camHUD.filters = storedFilters = [new ShaderFilter(createRuntimeShader('barrel4by3')), new ShaderFilter(createRuntimeShader('ntsc'))];

    var skinNotNull:Bool = Paths.image(skinPath + 'strumBG') != null;
    add(opponentBG = new BGSprite(skinNotNull ? skinPath + 'strumBG' : 'strumBG', 225, 30));
    opponentBG.scale.set(0.58, 0.68);
    opponentBG.updateHitbox();
    opponentBG.cameras = [game.camHUD];

    add(playerBG = new BGSprite('strumBG', 663, 88));
    playerBG.scale.set(0.54, 0.54);
    playerBG.updateHitbox();
    playerBG.cameras = [game.camHUD];

    add(bg = new BGSprite('menus/main/screenClose'));
    bg.cameras = [game.camOther];

    FlxTween.num(0, 1, 1.5, {ease: FlxEase.cubeInOut}, applyOpponentAlpha);
    FlxTween.num(0, 1, 1.5, {ease: FlxEase.cubeInOut, delay: 0.3}, applyPlayerAlpha);
}

// function onPause():Void {
//     var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
// 	bg.updateHitbox();
//     bg.cameras = [camOther];
// 	bg.alpha = 0.6;
// 	bg.scrollFactor.set();
// 	add(bg);

//     CustomSubstate.openCustomSubstate('BRM_PAUSE', true);

//     return Function_Stop;
// }


var toggled:Bool = true;
function toggleEffect():Void {
    toggled = !toggled;
    bg.visible = toggled;
    
    camGame.filters = camHUD.filters = toggled ? storedFilters : [];

    opponentBG.x = toggled ? 225 : 85;
    playerBG.x = toggled ? 663 : 792;

    var val = toggled ? -150 : 150;

    getVar('healthBG').x += val;
    getVar('fysIcon').x += val;

    for (heart in getVar('displayHearts')) {
        heart.x += val;
    }

    for (i in 0...opponentStrums.members.length) {
        opponentStrums.members[i].x += toggled ? 140 : -140;
    }

    for (i in 0...playerStrums.members.length) {
        playerStrums.members[i].x -=  toggled ? 130 : -130;
    }
}

function opponentNoteHit():Void {
    vocals.volume = 1;
}

function onCreatePost():Void {
    loadSkin();

    for (i in 0...opponentStrums.members.length) {
        opponentStrums.members[i].x += 120 - (i * 25);
        opponentStrums.members[i].scale.x = opponentStrums.members[i].scale.y -= 0.1;
    }

    for (i in 0...playerStrums.members.length) {
        playerStrums.members[i].x -= 60 + (i * 25);
        playerStrums.members[i].y += 10;
        playerStrums.members[i].scale.x = playerStrums.members[i].scale.y -= 0.15;
    }
}

function loadSkin():Void {
    if (Paths.image(skinPath + 'NOTE_ASSETS') == null) {
        if (debugMode) debugPrint(skinPath + ' is null.', FlxColor.RED);
        return;
    }

    for (strum in game.opponentStrums) {
        strum.texture = skinPath + 'NOTE_ASSETS';
        strum.useRGBShader = false;
    }

    for (note in unspawnNotes) {
        if (!note.mustPress) {
            note.texture = skinPath + 'NOTE_ASSETS';
            note.scale.x = note.scale.y -= 0.1;
        } else {
            note.scale.x = note.scale.y -= 0.15;
        }
    }
}

function onUpdatePost(elapsed:Float):Void {
    for (note in notes.members) {
        if (note.isSustainNote) note.alpha = note.multAlpha = 1;
    }

    for (splash in grpNoteSplashes) {
        splash.scale.x = splash.scale.y = 0.65;
    }

    if (FlxG.keys.justPressed.F6) {
        toggleEffect();
    }
}

function applyOpponentAlpha(value:Float):Void {
    opponentBG.alpha = value;
}

function applyPlayerAlpha(value:Float):Void {
    playerBG.alpha = value;
}

function onEndSong():Void {
	var percent:Float = ratingPercent;
	if(Math.isNaN(percent)) percent = 0;
	Highscore.saveScore(Song.loadedSongName, songScore, PlayState.storyDifficulty, percent);

	playbackRate = 1;


	if (PlayState.isStoryMode) {
	    campaignScore += songScore;
		campaignMisses += songMisses;

		storyPlaylist.remove(storyPlaylist[0]);

		if (storyPlaylist.length <= 0) {
			Mods.loadTopMod();
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

			canResync = false;
			MusicBeatState.switchState(new StoryMenuState());

			if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
				StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
				Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, PlayState.storyDifficulty);

				FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
				FlxG.save.flush();
			}
			changedDifficulty = false;
		} else {
			var difficulty:String = Difficulty.getFilePath();

			trace('LOADING NEXT SONG');
			trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			prevCamFollow = camFollow;

			Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
			FlxG.sound.music.stop();

			canResync = false;
			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState(), false, false);
		}
	}
	else
	{
		trace('WENT BACK TO FREEPLAY??');
		Mods.loadTopMod();
		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

        FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;

		canResync = false;
		FlxG.switchState(new CustomState('BRM_MAIN_MENU_STATE'));
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		changedDifficulty = false;
	}
	transitioning = true;

    return Function_Stop;
}