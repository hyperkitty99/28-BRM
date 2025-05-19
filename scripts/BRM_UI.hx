import objects.BGSprite;
import psychlua.CustomSubstate;
using StringTools;

var skinPath:String = 'noteSkins/' + game.dad.curCharacter + '/';

var playerBG:BGSprite;
var opponentBG:BGSprite;

var debugMode:Bool = false;
var camBG:FlxCamera;

function onCreate():Void {
    camBG = new FlxCamera();
    camBG.bgColor = 0x00000000;
    FlxG.cameras.add(camBG, false);

    var bg:BGSprite = new BGSprite('menus/main/screenClose');
    bg.camera = camBG;
    add(bg);

    camGame.width = camHUD.width = 960;
    camGame.x = camHUD.x = 160;

    camGame.filters = camHUD.filters = [new ShaderFilter(createRuntimeShader('barrel'))];

    FlxG.game.setFilters([new ShaderFilter(createRuntimeShader('ntsc'))]);

    var skinNotNull:Bool = Paths.image(skinPath + 'strumBG') != null;
    add(opponentBG = new BGSprite(skinNotNull ? skinPath + 'strumBG' : 'strumBG', -100, 0));
    opponentBG.scale.set(0.69, 0.69);
    opponentBG.cameras = [game.camHUD];

    add(playerBG = new BGSprite('strumBG', 360, 60));
    playerBG.scale.set(0.64, 0.64);
    playerBG.cameras = [game.camHUD];

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

function onDestroy():Void {
    FlxG.game.setFilters([]);
}

function opponentNoteHit():Void {
    vocals.volume = 1;
}

function onCreatePost():Void {
    loadSkin();

    for (strum in game.opponentStrums) {
        strum.x -= 100;
    }

    for (i in 0...playerStrums.members.length) {
        playerStrums.members[i].x -= 225 + (i * 5);
        playerStrums.members[i].scale.x = playerStrums.members[i].scale.y -= 0.05;
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
        }
    }
}

function onUpdatePost(elapsed:Float):Void {
    for (note in notes.members) {
        if (note.isSustainNote) note.alpha = note.multAlpha = 1;
    }
}

function applyOpponentAlpha(value:Float):Void {
    opponentBG.alpha = value;
}

function applyPlayerAlpha(value:Float):Void {
    playerBG.alpha = value;
}