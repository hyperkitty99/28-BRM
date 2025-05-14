import objects.BGSprite;

var stopTheCrap:Bool = false;

var hearts:Array<Int> = [2, 2, 2];
var displayHearts:Array<BGSprite> = [];

var curHealth:Int = 6;

var healthBG:BGSprite;
var fysIcon:BGSprite;

function noteMiss():Void decreaseHP();
function noteMissPress():Void decreaseHP();
function goodNoteHit():Void increaseHP();

function decreaseHP():Void {
    if (curHealth > 0) curHealth -= 1;

    if (curHealth == 0) {
        stopTheCrap = true;
        game.health = 0;
        return;
    }

    if (curHealth <= 2) {
        fysIcon.animation.play('dead', true);
    }

    var damaged:Bool = false;

    for (i in 0...hearts.length) {
        if (hearts[i] > 0) {
            hearts[i] -= 1;

            displayHearts[i].animation.play(hearts[i] >= 1 ? 'heart half' : 'no heart');
            damaged = true;
            break;
        }
    }

    if (!damaged && hearts.length > 0) {
        hearts[hearts.length - 1] -= 1;
    }
}

function increaseHP():Void {
    if (curHealth < 6) curHealth += 1;

    if (curHealth >= 3) {
        fysIcon.animation.play('fys', true);
    }

    for (i in 0...hearts.length) {
        var id = hearts.length - 1 - i;

        if (hearts[id] < 2) {
            hearts[id] += 1;

            displayHearts[id].animation.play(hearts[id] == 1 ? 'heart half' : 'heart');
            break;
        }
    }
}

function onCreate():Void {
    add(healthBG = new BGSprite('healthMonitor', 890, 502, 0, 0, ['healthMonitor'], false));
    add(fysIcon = new BGSprite('healthMonitor', 1083, 600, 0, 0, ['fys', 'dead'], false));

    for (i in 0...3) {
        var heartSpr = new BGSprite('healthMonitor', 948 + (i * 35), 665, 0, 0, ['heart', 'heart half', 'no heart']);
        heartSpr.scale.set(0.75, 0.75);
        heartSpr.updateHitbox();
        heartSpr.cameras = [camHUD];
        displayHearts.push(heartSpr);
        add(displayHearts[i]);
    }

    for (item in [healthBG, fysIcon]) {
        item.scale.set(0.75, 0.75);
        item.updateHitbox();
        item.cameras = [camHUD];
    }
}

function onCreatePost():Void {
    game.healthBar.visible = game.scoreTxt.visible = game.iconP1.visible = game.iconP2.visible = game.timeBar.visible = game.timeTxt.visible = game.comboGroup.visible = false;
}

function onUpdatePost(elapsed:Float):Void {
    if (!stopTheCrap) game.health = 1;
}