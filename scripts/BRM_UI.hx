import objects.BGSprite;
using StringTools;

var skinPath:String = 'noteSkins/' + game.dad.curCharacter + '/';

var playerBG:BGSprite;
var opponentBG:BGSprite;

var debugMode:Bool = false;

function onCreate():Void {
    var skinNotNull:Bool = Paths.image(skinPath + 'strumBG') != null;
    add(opponentBG = new BGSprite(skinNotNull ? skinPath + 'strumBG' : 'strumBG', skinNotNull ? -30 : -46, skinNotNull ? 0 : 60));
    opponentBG.scale.set(0.69, 0.69);
    opponentBG.cameras = [game.camHUD];

    add(playerBG = new BGSprite('strumBG', 594, 60));
    playerBG.scale.set(0.69, 0.69);
    playerBG.cameras = [game.camHUD];

    FlxTween.num(0, 1, 1.5, {ease: FlxEase.cubeInOut}, applyOpponentAlpha);
    FlxTween.num(0, 1, 1.5, {ease: FlxEase.cubeInOut, delay: 0.3}, applyPlayerAlpha);
}

function onCreatePost():Void {
    loadSkin();
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