
function opponentNoteHit(membersIndex, d, noteType, isSustainNote)
    local animToPlay = getProperty('singAnimations')[d+1]

    if noteType == 'Lime Sing' then
        runHaxeCode([[
            var lime = getVar("limeC");

            lime.playAnim("]] .. animToPlay .. [[", true);
            lime.holdTimer = 0;
        ]])
    end

    if noteType == 'Grace Sing' then
        runHaxeCode([[
            var grace = getVar("graceC");

            grace.playAnim("]] .. animToPlay .. [[", true);
            grace.holdTimer = 0;
        ]])
    end
end