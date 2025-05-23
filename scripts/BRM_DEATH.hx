import flixel.FlxObject;
import flixel.math.FlxBasePoint;
import flixel.FlxCameraFollowStyle;
import substates.GameOverSubstate;
import states.PlayState;
import states.MainMenuState;
import states.FreeplayState;
import backend.StageData;
import flixel.addons.transition.FlxTransitionableState;
import objects.BGSprite;

var camFollow:FlxObject;
var black:FlxSprite;

var musicLoop:FlxSound;

var stageZoom:Float;

var deathMonitor:BGSprite;

function onCreatePost():Void {
    stageZoom = game.defaultCamZoom;
}

//this code is horrible
//i dont care :3
function onGameOver():Void {
    if (((game.skipHealthCheck && game.instakillOnMiss) || game.health <= 0) && !game.practiceMode && !game.isDead && game.gameOverTimer == null) {
        game.paused = game.isDead = game.boyfriend.stunned = true;
		game.canResync = game.canPause = false;

		FlxG.animationTimeScale = 1;
        PlayState.deathCounter++;

		#if VIDEOS_ALLOWED
		if(game.videoCutscene != null)
		{
			game.videoCutscene.destroy();
			game.videoCutscene = null;
		}
		#end

		FlxTimer.globalManager.clear();
		FlxTween.globalManager.clear();

        FlxG.sound.play(Paths.sound(GameOverSubstate.deathSoundName));
    
		#if DISCORD_ALLOWED
		if(game.autoUpdateRPC) DiscordClient.changePresence("Game Over - " + game.detailsText, game.SONG.song + " (" + game.storyDifficultyText + ")", game.iconP2.getCharacter());
		#end

        game.boyfriend.playAnim('firstDeath');
		game.camGame.target = null;

        camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.getMidpoint().x - 45, boyfriend.getMidpoint().y);
		camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
		camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

		game.camGame.focusOn(new FlxBasePoint(game.camGame.scroll.x + (game.camGame.width / 2), game.camGame.scroll.y + (game.camGame.height / 2)));
		game.camGame.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.01);
		add(camFollow);

        defaultCamZoom = 1.85;

        FlxTween.num(1.85, 1, 1, {ease: FlxEase.circInOut, startDelay: 2}, (v) -> defaultCamZoom = v);

        camHUD.alpha = 0;

        game.addBehindBF(black = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK));
        black.scrollFactor.set();

        add(deathMonitor = new BGSprite('deathGraphic', game.boyfriend.x - 950, game.boyfriend.y - 590, 0, 0, ['Symbol 1'], true));
        deathMonitor.animation.play('Symbol 1');
        deathMonitor.scale.set(0.95, 0.95);
        deathMonitor.alpha = 0;
        deathMonitor.updateHitbox();

        FlxTimer.wait(1, () -> deathMonitor.alpha = 1);

        FlxTween.num(1.5, 0.95, 1, {ease: FlxEase.circInOut, startDelay: 2}, (v) -> deathMonitor.scale.x = deathMonitor.scale.y = v);

        FlxTween.num(1, 0.7, 0.5, {ease: FlxEase.circOut, startDelay: 0.8}, (v) -> black.alpha = v);

        Conductor.songPosition = 0;

        game.vocals.stop();
		game.opponentVocals.stop();
		FlxG.sound.music.stop();
	}

    return Function_Stop;
}

var isEnding:Bool = false;
var allowInput:Bool = false;
function onUpdatePost(elapsed:Float):Void {
	if (game.isDead) {
        FlxG.camera.followLerp = 0.04 * game.cameraSpeed * game.playbackRate;
		FlxG.camera.zoom = FlxMath.lerp(game.defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * game.camZoomingDecay * game.playbackRate));

        var justPlayedLoop:Bool = false;
		if (!game.boyfriend.isAnimationNull() && game.boyfriend.getAnimationName() == 'firstDeath' && game.boyfriend.isAnimationFinished()) {
			game.boyfriend.playAnim('deathLoop');
			justPlayedLoop = allowInput = true;
		}

        if(!isEnding)
		{
            if (allowInput) {
                if (controls.ACCEPT)
                {
                    endBullshit();
                }
                else if (controls.BACK)
                {
                    #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
                    FlxG.camera.visible = false;
                    if (musicLoop != null) musicLoop.destroy();
                    PlayState.deathCounter = 0;
                    PlayState.seenCutscene = false;
                    PlayState.chartingMode = false;
            
                    FlxG.switchState(new CustomState('BRM_MAIN_MENU_STATE'));
                    FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
            
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                }
            }

            if (justPlayedLoop) musicLoop = FlxG.sound.play(Paths.music(GameOverSubstate.loopSoundName), 1, true);
        }
    }
}

function endBullshit():Void
{
	if (!isEnding)
	{
        FlxTween.num(1, 0, 0.5, {ease: FlxEase.circOut}, (v) -> deathMonitor.alpha = v);
        FlxTween.num(0.7, 0, 0.5, {ease: FlxEase.circOut, startDelay: 1.6}, (v) -> black.alpha = v);
        FlxTimer.wait(1.6, () -> {
            game.defaultCamZoom = stageZoom;

            camFollow.setPosition(game.gf.getMidpoint().x, game.gf.getMidpoint().y);
		    camFollow.x += game.gf.cameraPosition[0] + game.girlfriendCameraOffset[0];
		    camFollow.y += game.gf.cameraPosition[1] + game.girlfriendCameraOffset[1];
        });

		isEnding = true;
		if(game.boyfriend.hasAnimation('deathConfirm'))
			game.boyfriend.playAnim('deathConfirm', true);
		else if(game.boyfriend.hasAnimation('deathLoop'))
			game.boyfriend.playAnim('deathLoop', true);

		if (musicLoop != null) musicLoop.destroy();
		FlxG.sound.play(Paths.music(GameOverSubstate.endSoundName));
		new FlxTimer().start(2.7, function(tmr:FlxTimer)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		});
	}
}