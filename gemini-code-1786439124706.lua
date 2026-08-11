--// GAME : FORSAKEN
--// XENO READY VERSION (FULL FIXED + LOOP EMOTES RESTORED)
--// Version 6.5 (Custom Folders & Top-Sorted Custom Emote Buttons)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local currentProp
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local currentAnim
local currentSound
local loopConnection
local autoWalkConnection = nil
local speedTrackConnection = nil
local actionId = 0

--// FOLDER PATH SETUP
local baseFolder = "f6'sNiceHub"
local emoteScriptFolder = baseFolder .. "/EmoteScript"
local settingsFolder = emoteScriptFolder .. "/settings"
local customEmotesFolder = emoteScriptFolder .. "/CustomEmotes"

if not isfolder(baseFolder) then makefolder(baseFolder) end
if not isfolder(emoteScriptFolder) then makefolder(emoteScriptFolder) end
if not isfolder(settingsFolder) then makefolder(settingsFolder) end
if not isfolder(customEmotesFolder) then makefolder(customEmotesFolder) end

-- Custom Randomization Tables
local CustomRandomAnimations = {}
local CustomRandomMusic = {}

local function AddRandomAnims(emoteName, animList)
    CustomRandomAnimations[emoteName] = animList
end

local function AddRandomMusic(emoteName, musicList)
    CustomRandomMusic[emoteName] = musicList
end

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- CAMERA
local function enableCamLock(character)
    local head = character:FindFirstChild("Head")
    if head then
        camera.CameraSubject = head
        camera.CameraType = Enum.CameraType.Custom
    end
end

local function disableCamLock(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        camera.CameraSubject = humanoid
        camera.CameraType = Enum.CameraType.Custom
    end
end

-- STOP ALL
local function stopAll()
    actionId += 1
    if currentProp then
        currentProp:Destroy()
        currentProp = nil
    end

    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop(0.1)
            end
        end
        disableCamLock(character)
    end

    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
    end

    if loopConnection then
        loopConnection:Disconnect()
        loopConnection = nil
    end

    if autoWalkConnection then
        autoWalkConnection:Disconnect()
        autoWalkConnection = nil
    end

    if speedTrackConnection then
        speedTrackConnection:Disconnect()
        speedTrackConnection = nil
    end
end

-- EMOTE ENGINE
local function playEmote(animId, soundId, speed, isLoop, propData, camLock, customSpeedTracks, autoWalk, randomAnims, randomMusic)
    stopAll()
    local myActionId = actionId

    local character = getCharacter()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if autoWalk then
        humanoid.WalkSpeed = 10
        autoWalkConnection = RunService.RenderStepped:Connect(function()
            if actionId ~= myActionId then return end
            humanoid:Move(rootPart.CFrame.LookVector, false)
        end)
    end

    if camLock then enableCamLock(character) end

    -- SOUND
    if soundId then
        local chooseSound = soundId
        if randomMusic and #randomMusic > 0 then
            chooseSound = randomMusic[math.random(1, #randomMusic)]
        end

        currentSound = Instance.new("Sound")
        currentSound.SoundId = chooseSound
        currentSound.Volume = 1
        currentSound.Parent = rootPart
        currentSound:Play()
    end

    -- PROP
    if propData then
        local prop = Instance.new("Part")
        prop.Size = propData.Size or Vector3.new(1, 1, 1)
        prop.Color = propData.Color or Color3.fromRGB(255, 255, 255)
        prop.CanCollide = false
        prop.Parent = character

        local weld = Instance.new("Weld")
        weld.Part0 = character:WaitForChild(propData.Part or "RightHand")
        weld.Part1 = prop
        weld.C0 = propData.C0 or CFrame.new()
        weld.Parent = prop

        currentProp = prop
    end

    -- ANIMATION
    local chooseAnim = animId
    if randomAnims and #randomAnims > 0 then
        chooseAnim = randomAnims[math.random(1, #randomAnims)]
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = chooseAnim

    currentAnim = humanoid:LoadAnimation(anim)
    currentAnim:Play()
    currentAnim:AdjustSpeed(speed or 1)

    if customSpeedTracks then
        speedTrackConnection = RunService.RenderStepped:Connect(function()
            if actionId ~= myActionId or not currentAnim then return end
            local moveSpeed = rootPart.AssemblyLinearVelocity.Magnitude
            if moveSpeed > 0.1 then
                currentAnim:AdjustSpeed(customSpeedTracks.Moving or 1)
            else
                currentAnim:AdjustSpeed(customSpeedTracks.Idle or 1)
            end
        end)
    end

    if isLoop then
        loopConnection = currentAnim.Stopped:Connect(function()
            if actionId == myActionId then
                if randomAnims and #randomAnims > 0 then
                    local nextAnim = randomAnims[math.random(1, #randomAnims)]
                    local newAnimObj = Instance.new("Animation")
                    newAnimObj.AnimationId = nextAnim
                    currentAnim = humanoid:LoadAnimation(newAnimObj)
                end
                currentAnim:Play()
                currentAnim:AdjustSpeed(speed or 1)
            end
        end)
    end
end

-- UI CREATION
local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("XenoGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XenoGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0, 220, 0, 360)
scrollFrame.Position = UDim2.new(1, -240, 0.5, -180)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BackgroundTransparency = 0.2
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = screenGui

Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 8)
uiPadding.PaddingBottom = UDim.new(0, 8)
uiPadding.PaddingLeft = UDim.new(0, 8)
uiPadding.PaddingRight = UDim.new(0, 8)
uiPadding.Parent = scrollFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
end)

-- HELPER BUTTON GENERATOR
local layoutIndex = 1

local function createEmoteButton(name, callback, isCustom)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.LayoutOrder = layoutIndex
    layoutIndex += 1

    if isCustom then
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray for Custom Emotes
    else
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215) -- Standard Blue
    end

    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = scrollFrame

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 1. LOAD CUSTOM EMOTES AT THE VERY TOP
if isfolder(customEmotesFolder) then
    for _, fileName in ipairs(listfiles(customEmotesFolder)) do
        if string.sub(fileName, -5) == ".json" or string.sub(fileName, -4) == ".txt" then
            local fileContent = readfile(fileName)
            local success, emoteData = pcall(function()
                return HttpService:JSONDecode(fileContent)
            end)

            if success and type(emoteData) == "table" then
                local emoteName = emoteData.Name or "Custom Emote"
                createEmoteButton("⭐ " .. emoteName, function()
                    playEmote(
                        emoteData.AnimId,
                        emoteData.SoundId,
                        emoteData.Speed or 1,
                        emoteData.IsLoop or false,
                        emoteData.PropData,
                        emoteData.CamLock or false,
                        emoteData.CustomSpeedTracks,
                        emoteData.AutoWalk or false,
                        emoteData.RandomAnims,
                        emoteData.RandomMusic
                    )
                end, true) -- true = applies Gray background
            end
        end
    end
end

-- 2. STANDARD DEFAULT EMOTES
createEmoteButton("Default Dance", function()
    playEmote("rbxassetid://507771019", "rbxassetid://184113970", 1, true)
end, false)

createEmoteButton("Calm Vibe", function()
    playEmote("rbxassetid://507772104", nil, 0.8, true)
end, false)

-- STOP BUTTON
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 220, 0, 40)
stopBtn.Position = UDim2.new(1, -240, 0.5, 190)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
stopBtn.Text = "🛑 STOP ALL"
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.TextSize = 18
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Parent = screenGui

Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)
stopBtn.MouseButton1Click:Connect(stopAll)