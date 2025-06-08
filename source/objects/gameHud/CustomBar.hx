package objects.gameHud;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

class CustomBar extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var leftBar:FlxSprite;
	public var rightBar:FlxSprite;

	public var percent(default, set):Float = 100;
	public var value(default, set):Float = 2; // 0 ~ 2
	public var bounds:Dynamic = {min: 0, max: 2};

	public var barWidth:Float = 200;
	public var barHeight:Float = 20;

	public var scaleMultiplier:FlxPoint = new FlxPoint(1.0, 1.0);

	public var leftToRight:Bool = false;
	public var barOffset:FlxPoint = new FlxPoint(0, 1.3);
	public var barCenter:Float = 0;

	public function new(x:Float, y:Float, width:Int = 0, height:Int = 0, color:FlxColor = FlxColor.RED, bgColor:FlxColor = FlxColor.BLACK) {
		super(x, y);

		bg = new FlxSprite().loadGraphic(Paths.image('healthBar'));

		barWidth = bg.width;
		barHeight = bg.height;

		leftBar = new FlxSprite().makeGraphic(Std.int(barWidth), Std.int(barHeight), color);
		rightBar = new FlxSprite().makeGraphic(Std.int(barWidth), Std.int(barHeight), FlxColor.RED);

		add(bg);
		add(leftBar);
		add(rightBar);

		updateBar();
	}

	private function set_value(v:Float):Float {
		value = Math.max(bounds.min, Math.min(v, bounds.max));
		percent = (value / bounds.max) * 100;
		updateBar();
		return value;
	}

	private function set_percent(v:Float):Float {
		percent = Math.max(0, Math.min(v, 100));
		updateBar();
		return percent;
	}

	private function updateBar():Void {
		var scaledWidth:Float = barWidth * scaleMultiplier.x;
		var scaledHeight:Float = barHeight * scaleMultiplier.y;

		leftBar.setPosition(bg.x + barOffset.x, bg.y + barOffset.y);
		rightBar.setPosition(bg.x + barOffset.x, bg.y + barOffset.y);

		leftBar.setGraphicSize(Std.int(scaledWidth), Std.int(scaledHeight));
		rightBar.setGraphicSize(Std.int(scaledWidth), Std.int(scaledHeight));

		var filledWidth:Float = (percent / 100) * scaledWidth;
		var emptyWidth:Float = scaledWidth - filledWidth;

		if (leftToRight) {
			leftBar.clipRect = new FlxRect(0, 0, filledWidth, scaledHeight);
			rightBar.clipRect = new FlxRect(filledWidth, 0, emptyWidth, scaledHeight);
		} else {
			leftBar.clipRect = new FlxRect(emptyWidth, 0, filledWidth, scaledHeight);
			rightBar.clipRect = new FlxRect(0, 0, emptyWidth, scaledHeight);
		}

		leftBar.clipRect = leftBar.clipRect;
		rightBar.clipRect = rightBar.clipRect;

		barCenter = leftBar.x + leftBar.clipRect.width;
	}

	public function setBarColors(fill:FlxColor, empty:FlxColor):Void {
		leftBar.makeGraphic(Std.int(barWidth), Std.int(barHeight), fill);
		rightBar.makeGraphic(Std.int(barWidth), Std.int(barHeight), empty);
		updateBar();
	}
}
