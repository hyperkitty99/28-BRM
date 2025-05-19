import flixel.group.FlxTypedGroup;

var textGroup:FlxTypedGroup<Alphabet>;

function onCreatePost():Void {
    add(textGroup = new FlxTypedGroup());

    var leArray = ['Resume', 'Restart song', 'Return to menu'];

    for (i in 0...3) {
        var text = new Alphabet(90, 100 + (i * 100), leArray[i]);
        textGroup.add(text);
    }
}