package;

import data.Conductor.BPMChangeEvent;
import data.Conductor;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import misc.meta.transition.RTFunkinTransition;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		if(!skip)
			openSubState(new RTFunkinTransition(0.7, true));
		
		FlxTransitionableState.skipNextTransOut = false;

		super.create();
	}

	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
		curBeat = Math.floor(curStep / 4);

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
