package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var curPlaying:Bool = false;

	var arcadeGrp:FlxTypedGroup<FlxSprite>;

	var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;

	var bg:FlxBackdrop;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('fp'), 1);
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxBackdrop(Paths.image('menu/freeplay/wall'), 0x01);
		bg.setGraphicSize(Std.int(FlxG.width * 0.9));
		bg.updateHitbox();
		add(bg);

		arcadeGrp = new FlxTypedGroup<FlxSprite>();
		add(arcadeGrp);

		for (i in 0...songs.length)
		{
			var arcade:FlxSprite = new FlxSprite(50 + (i * 400), 80);
			arcade.loadGraphic(Paths.image('menu/freeplay/songs/blank'));
			arcade.scale.set(1.6, 1.6);
			arcade.updateHitbox();
			arcade.ID = i;
			arcadeGrp.add(arcade);
		}

		arrowRight = new FlxSprite(FlxG.width, 0);
		arrowRight.frames = Paths.getSparrowAtlas("menu/freeplay/freeplayarrow");
		arrowRight.animation.addByPrefix('idle', 'normal', 12, true);
		arrowRight.animation.addByPrefix('selected', 'press', 12, false);
		arrowRight.animation.play('idle');
		arrowRight.scale.set(3, 3);
		arrowRight.updateHitbox();
		arrowRight.screenCenter(Y);
		arrowRight.x -= arrowRight.width + 50;
		add(arrowRight);
		arrowRight.animation.finishCallback = function(name:String){
			if(name == 'selected')
				arrowRight.animation.play('idle');
		};

		arrowLeft = arrowRight.clone();
		arrowLeft.x = 50;
		arrowLeft.flipX = true;
		arrowLeft.scale.set(3, 3);
		arrowLeft.updateHitbox();
		arrowLeft.screenCenter(Y);
		add(arrowLeft);
		arrowLeft.animation.finishCallback = function(name:String){
			if(name == 'selected')
				arrowLeft.animation.play('idle');
		};

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(0, FlxG.height, FlxG.width,'SCORE: 0', 32);
        scoreText.alignment = 'center';
		scoreText.font = Paths.font("f.otf");
		scoreText.alpha = 0.8;
		scoreText.y -= scoreText.height - 8;
		scoreText.screenCenter(X);

		scoreBG = new FlxSprite(scoreText.x - 6, FlxG.height).makeGraphic(1, 48, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.y -= scoreBG.height;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);
		diffText.alpha = 0;

		add(scoreText);


		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

                var leText:String;

                if (controls.mobileC) {
		leText = "Press X to listen to the Song / Press C to open the Gameplay Changers Menu / Press Y to Reset your Score and Accuracy.";
                } else {
		leText = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
                }
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);

		bottomBG.visible = false;
		bottomText.visible = false;
		
		player = new MusicPlayer(this);
		add(player);

		var vignette = new FlxSprite(0,0);
		vignette.loadGraphic(Paths.image('menu/freeplay/menuvig'));
		vignette.setGraphicSize(Std.int(FlxG.width));
		vignette.updateHitbox();
		vignette.alpha = 0.8;
		add(vignette);
		
		changeSelection();
		updateTexts();

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	var shitmyself:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
        if((FlxG.keys.pressed.SHIFT) && !player.playingMusic) shiftMult = 3;

		if (!player.playingMusic)
		{
			scoreText.text = 'SCORE: ' + lerpScore;
			positionHighscore();
			
			if(songs.length > 1)
			{
				if(controls.UI_LEFT_P || (FlxG.mouse.overlaps(arrowLeft) && FlxG.mouse.justPressed)){
					arrowLeft.animation.play('selected');
					changeSelection(-1);
				}
				else if(controls.UI_RIGHT_P || (FlxG.mouse.overlaps(arrowRight) && FlxG.mouse.justPressed)){
					arrowRight.animation.play('selected');
					changeSelection(1);
				}
			}
		}

        if (controls.BACK #if mobile || FlxG.android.justReleased.BACK #end)
		{
			if (player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}
			else 
			{
				persistentUpdate = false;
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if (controls.ACCEPT || shitmyself && !player.playingMusic)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
        else if((controls.RESET) && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		arcadeGrp.forEach(
			function(arcade:FlxSprite) //este puto codigo me va a dar migraña -peppy
			{
				if(curSelected == arcade.ID)
					if(FlxG.mouse.overlaps(arcade) && FlxG.mouse.justPressed && !((FlxG.mouse.overlaps(arrowRight) || FlxG.mouse.overlaps(arrowLeft)) && FlxG.mouse.justPressed))
						shitmyself = true;

				var newX:Float = 440;
	
				if(arcade.ID > curSelected)
					newX = newX + (arcade.width + 90);

				if(arcade.ID < curSelected)
					newX = newX - (arcade.width + 90);
	
				arcade.x = bg.x = FlxMath.lerp(arcade.x, newX, FlxMath.bound(FlxG.elapsed * 10, 0, 1));
			}
		);

		updateTexts(elapsed);
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);

		trace(intendedScore);
		#end

		for (i in 0...songs.length)
		{
			arcadeGrp.forEach((silly) -> {
				if(Highscore.getScore(songs[i].songName, curDifficulty) != 0)
				{
					if(silly.ID == i)
						silly.loadGraphic(Paths.image('menu/freeplay/songs/' + songs[i].songName));
				}
				else
				{
					if(silly.ID == i)
						silly.loadGraphic(Paths.image('menu/freeplay/songs/blank'));
				}
				silly.updateHitbox();
			});
		}

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else
			diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore() {
		scoreText.screenCenter(X);
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.screenCenter(X);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		_lastVisibles = [];
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
