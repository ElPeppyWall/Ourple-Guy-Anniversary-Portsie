function onSongStart()
    setProperty("showCombo", false)
    setProperty("showComboNum", false)
    setProperty("showRating", false)
end

function onUpdatePost(elapsed)
	for i = 0,getProperty('unspawnNotes.length') - 1 do
		if getPropertyFromGroup('unspawnNotes', i, 'rgbShader.enabled') then
			setPropertyFromGroup('unspawnNotes', i, 'rgbShader.enabled', false);
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.useRGBShader', false);
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/NOTE_assets');
            setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.texture', 'noteSplashes/noteSplashes');	
		end
	end

    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'useRGBShader', false)
    end
end

function onSpawnNote(membersIndex, noteData, noteType, isSustainNote) --WHYYYYYYY I FUKCKING HATE PSYCH ENGINE
    if isSustainNote then
        if string.find(getPropertyFromGroup('notes', membersIndex, 'animation.curAnim.name'), 'holdend') then
            setPropertyFromGroup('notes', membersIndex, 'offsetX', noteData == 1 and 23 or 27)
            setPropertyFromGroup('notes', membersIndex, 'offsetY', 1)
        else
            setPropertyFromGroup('notes', membersIndex, 'offsetX', noteData == 1 and 36 or 40)
            setPropertyFromGroup('notes', membersIndex, 'offsetY', 0)
        end
    end
end