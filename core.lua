--variables used
local xpForNextLevel = 0
local playerLastXP = 0
local playerCurrentXP = 0

local loginTime = 0
local currentTime = 0
local passedTime = 0
local totalGainedXP = 0

local frameLocked = false

local gainedXPString = "XP Gained: "
local xpForlvlupString = "XP Till LevelUp : "
local estimatedXPperHourString = "XP/Hour: "

local frame = CreateFrame("Frame", "MyHelloWorldFrame", UIParent)

local textGainedXP = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
textGainedXP:SetText(gainedXPString .. " " .. tostring(0))
textGainedXP:SetPoint("TOPLEFT", 5, -5)

local textremainingXP = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
textremainingXP:SetPoint("TOPLEFT", 5, -20)

local textestimatedXP = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
textestimatedXP:SetPoint("LEFT", 5, -15)

--functions used: 



local function getPlayerCurrentXP()
    return UnitXP("player")
end

local function getNextLevelXP()
    xpForNextLevel = UnitXPMax("player")
    return xpForNextLevel
end


local function ToggleXPFrame(cmd)
    if cmd == "lock" then
        print("Frame is now locked")
        frame:SetMovable(false)
        return -- No need to show/hide when locking/unlocking
    end

    if cmd == "unlock" then
        print("Frame is now unlocked")
        frame:SetMovable(true)
        return -- No need to show/hide when locking/unlocking
    end

    if cmd == "reset" then
        print("XP Stats reset")
        playerLastXP = getPlayerCurrentXP()
        totalXPGained = 0 -- Reset total XP gained
        textGainedXP:SetText(gainedXPString .. " " .. tostring(0))
        textestimatedXP:SetText(estimatedXPperHourString .. " " .. tostring(0))
        return -- No need to show/hide when locking/unlocking
    end

    if cmd == "" then -- If no argument provided, toggle visibility
    

        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
end

-- Slash command handler registration
SLASH_XPFRAME1 = "/xp"
SlashCmdList["XPFRAME"] = ToggleXPFrame


frame:SetSize(200, 50)
frame:SetPoint("CENTER", 0, 0)

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("PLAYER_LEVEL_UP")

local background = frame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(frame)
background:SetColorTexture(0, 0, 0, 0.5)

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)


frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        loginTime = time()
        currentTime = loginTime
        local playerName = UnitName("player")
        print("Welcome back " .. playerName .. "! Let's clap some cheeks today!")
        print("XPTracker is running! Type !xp to toggle window on/off." .. "\n" .. "type /xp lock to lock window. Type /xp unlock to unlock window" .. "\n" .. "Type /xp reset to reset the XP Stats")
        playerLastXP = getPlayerCurrentXP()
        xpForNextLevel = getNextLevelXP()
        playerCurrentXP = getPlayerCurrentXP()
        totalGainedXP = 0  -- Initialize total XP gained

        local remainingXP = xpForNextLevel - playerCurrentXP 
        textestimatedXP:SetText(estimatedXPperHourString .. " " .. tostring(0))
        textremainingXP:SetText(xpForlvlupString .. " " .. tostring(remainingXP))

        frame:Show()
    elseif event == "PLAYER_XP_UPDATE" then
        currentTime = time()
        passedTime = currentTime - loginTime
        playerCurrentXP = getPlayerCurrentXP()
        local xpGained = playerCurrentXP - playerLastXP
        -- Check if xpGained is negative (level-up scenario)
        if xpGained < 0 then
            xpGained = (xpForNextLevel - playerLastXP) + playerCurrentXP
            xpForNextLevel = getNextLevelXP()
        end
        playerLastXP = playerCurrentXP
        totalGainedXP = totalGainedXP + xpGained  -- Update total XP gained
        local remainingXP = xpForNextLevel - playerCurrentXP
        local xpPerHour = math.floor((totalGainedXP / passedTime) * 3600)
        textestimatedXP:SetText(estimatedXPperHourString .. " " .. tostring(xpPerHour))
        textremainingXP:SetText(xpForlvlupString .. " " .. tostring(remainingXP))
        textGainedXP:SetText(gainedXPString .. " " .. tostring(totalGainedXP))
    elseif event == "PLAYER_LEVEL_UP" then
        print("Congrats you just leveled up")
        local soundPath = "Interface\\AddOns\\XPTracker\\levelUpSound.mp3"
        PlaySoundFile(soundPath, "Master")
    end
end)

