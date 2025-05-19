import objects.BGSprite;
import psychlua.CustomSubstate;
using StringTools;
import Main;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import lime.graphics.Image;

var skinPath:String = 'noteSkins/' + game.dad.curCharacter + '/';

var playerBG:BGSprite;
var opponentBG:BGSprite;

var debugMode:Bool = false;
var camBG:FlxCamera;

var bg:Bitmap = new Bitmap(BitmapData.fromImage(Image.fromFile('mods/28-BRM/images/menus/main/screenClose.png')));

function onCreate():Void {
    camBG = new FlxCamera();
    camBG.bgColor = 0x00000000;
    FlxG.cameras.add(camBG, false);

    camGame.width = 960;
    camGame.x = 160;

    FlxG.game.setFilters([new ShaderFilter(createRuntimeShader('ntsc'))]);

    camGame.filters = camHUD.filters = [new ShaderFilter(createRuntimeShader('barrel'))];

    var skinNotNull:Bool = Paths.image(skinPath + 'strumBG') != null;
    add(opponentBG = new BGSprite(skinNotNull ? skinPath + 'strumBG' : 'strumBG', 80, 0));
    opponentBG.scale.set(0.58, 0.68);
    opponentBG.cameras = [game.camHUD];

    add(playerBG = new BGSprite('strumBG', 495, 65));
    playerBG.scale.set(0.54, 0.54);
    playerBG.cameras = [game.camHUD];

    FlxTween.num(0, 1, 1.5, {ease: FlxEase.cubeInOut}, applyOpponentAlpha);
    FlxTween.num(0, 1, 1.5, {ease: FlxEase.cubeInOut, delay: 0.3}, applyPlayerAlpha);

    FlxG.stage.addChild(bg);
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

function onDestroy():Void {
    FlxG.game.setFilters([]);
    FlxG.stage.removeChild(bg);
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
}

function applyOpponentAlpha(value:Float):Void {
    opponentBG.alpha = value;
}

function applyPlayerAlpha(value:Float):Void {
    playerBG.alpha = value;
}