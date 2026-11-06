local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RS               = game:GetService("ReplicatedStorage")
local CS               = game:GetService("CollectionService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP.PlayerGui

local Players          = game:GetService("Players")

local DESIGN_W, DESIGN_H = 1320, 900
local SHOW_AUTO_FARM     = true
local NOISE_ID           = ""
local UNDER_MAP_Y = -280
local RING_TEX = ""
local CFG = {
CollectYOffset = 2, CollectWait = 0.5, CollectRetries = 8, CollectRetryGap = 1,
CollectStandLimit = 0.6, CollectPrioWindow = 0.9, CollectMaxCycles = 8,
CollectPostAvoidWait = 2,
AvoidCheckRadius = 50, AvoidWaitTime = 2, AvoidCooldown = 0.5, AvoidMaxAttempts = 3, AvoidDodge = 60,
MapCenterX = -23, MapCenterZ = 801, MapRadius = 200,
TimerSec = 1, VoteSkipSec = 1,
TicketIds = {
        ["Sun: Tier1"] = "f1e9e4276c5344bba645234749d02064",
        ["Sun: Tier2"] = "077eb68ce3994f169754cf2c2201dcd2",
        ["Sun: Tier3"] = "e1a560a2a0584993952b4a082282444e",
        ["Wisps: Tier1"] = "f1e9e4276c5344bba645234749d02064",
        ["Wisps: Tier2"] = "077eb68ce3994f169754cf2c2201dcd2",
        ["Wisps: Tier3"] = "e1a560a2a0584993952b4a082282444e",
    },
}
local C = {
	White = Color3.fromRGB(200,200,200), Bg = Color3.fromRGB(25,25,25),
	Card = Color3.fromRGB(21,21,21), CardBg = Color3.fromRGB(28,28,28), CardHover = Color3.fromRGB(60,60,60),
	CardBorder = Color3.fromRGB(65,65,65), Blue = Color3.fromRGB(100,100,100),
	BlueHover = Color3.fromRGB(80,80,80), BlueAccent = Color3.fromRGB(110,110,110),
	StartOn = Color3.fromRGB(130,130,130), StartBtn = Color3.fromRGB(48,48,48),
	Dark = Color3.fromRGB(60,60,60), Deep = Color3.fromRGB(40,40,40),
	Soul = Color3.fromRGB(90,90,90), VeryLight = Color3.fromRGB(12,14,26),
	StatBadge = Color3.fromRGB(33,33,33),
	Text = Color3.fromRGB(220,220,220), Text2 = Color3.fromRGB(150,150,150),
	Shadow = Color3.fromRGB(10,10,10), Console = Color3.fromRGB(18,18,18),
	Pagination = Color3.fromRGB(180,180,180), BottomBar = Color3.fromRGB(48,48,48),
	HintBar = Color3.fromRGB(130,130,130), InnerLight = Color3.fromRGB(55,55,55),
	HeaderButton = Color3.fromRGB(90,90,90),
}
local GLASS = {
	Bg = Color3.fromRGB(35,35,35), BgTransparency = 0.85,
	Stroke = Color3.fromRGB(65,65,65), StrokeTransparency = 0.40,
	InnerLight = Color3.fromRGB(50,50,50), InnerLightTransparency = 0.85,
	Shadow = Color3.fromRGB(10,10,10), ShadowTransparency = 0.90,
	Text = Color3.fromRGB(180,180,180), TextTransparency = 0.85,
}
local function fnt(n)
    local ok, e = pcall(function() return Enum.Font[n] end)
    return (ok and e) or Enum.Font.Gotham
end
local F_BOLD = fnt("GothamBold"); local F_SEMI = fnt("GothamSemibold")
local F_MED = fnt("GothamMedium"); local F_REG = fnt("Gotham"); local F_CODE = fnt("Code")
local F_GARAMOND = fnt("Garamond"); local F_OSWALD = fnt("Oswald")
local SOUL_FONT = F_GARAMOND
pcall(function()
    local f = Font.fromName("AccanthisADFStd", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    local probe = Instance.new("TextLabel"); probe.Font = f; probe:Destroy(); SOUL_FONT = f
end)
local function mk(class, props, parent)
    local o = Instance.new(class)
    if props then for k, v in pairs(props) do o[k] = v end end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r)
    mk("UICorner", {CornerRadius = UDim.new(0, r)}, p)
end
local function stroke(p, t, col, th)
    return mk("UIStroke", {Color = col or C.CardBorder, Transparency = t or 0.9, Thickness = th or 1}, p)
end
local function shadow(p, blur, tr, offY, col)
    local s
    pcall(function()
        s = mk("UIShadow", {Blur = blur or 45, Transparency = tr or 0.85, Offset = Vector2.new(0, offY or 8), Color = col or C.Shadow}, p)
    end)
    return s
end
local QU = Enum.EasingStyle.Quart
local function ease(o, d, props, style)
    local t = TweenService:Create(o, TweenInfo.new(d or 0.2, style or QU, Enum.EasingDirection.Out), props)
    t:Play(); return t
end
local function seq2(a, b) return ColorSequence.new(a, b) end
local function seq3(a, b, c)
    return ColorSequence.new({ColorSequenceKeypoint.new(0,a), ColorSequenceKeypoint.new(0.5,b), ColorSequenceKeypoint.new(1,c)})
end
local log, applyTheme, paintStart, startFarmLogic, onFeatureToggled, showToast
local startWispCounter, stopWispCounter
local showRing, hideRing, setRingRadius
local toggleRegs = {}
local featureStates, featurePaint = {}, {}
local statVals, statShadows = {}, {}
local autoGrad, autoRedShadow, fillGradObj, thumbGlow, soulGrad
local ContentPanel, BgGlow, Toast, DragZone, ImageContainer
local Avatar, Handle, eyeIcon, GithubBtn, EyeButton
local tip, thumbStroke
settingsGui = nil

local EVENTS = {
    gamemode = {label = "Gamemode", default = "!Gamemode Pro", value = "!Gamemode Pro"},
    map = {label = "Map", default = "!map WorkFacility", value = "!map WorkFacility"},
    addmap = {label = "AddMap", default = "AddMap,WorkFacility", value = "AddMap,WorkFacility"},
    specialround = {label = "Special Round", default = "!specialround Plushie Hell", value = "!specialround Plushie Hell"},
    perk1 = {label = "Perk Slot 1 ID", default = "7", value = "7"},
    perk2 = {label = "Perk Slot 2 ID", default = "3", value = "3"},
}

local function getEventValue(key)
    return EVENTS[key] and EVENTS[key].value or EVENTS[key].default
end

local function parseAddMap(val)
    local parts = {}
    for p in string.gmatch(val, "[^,]+") do
        table.insert(parts, p:gsub("^%s+", ""):gsub("%s+$", ""))
    end
    return parts
end
local sd, faceStroke, eyeL, eyeR, mouthStroke, n1, n2
local sS, sLabel, sDot, sDotCore, StartBtn
local farmRunning = false
local avoidValue = 35
local MapWasRequested = false
local perfModeActive = false
local perfModeBlocking = false
local _perfScreenGui = nil
local _perfLogFn = nil
local _perfRoundCount = 0
local _perfWispCount = 0
local _perfSkipCount = 0
local _perfDownedCount = 0
local _perfDownedCooldown = false
local _perfRoundStartTime = nil
local _perfRoundActive = false
local _perfModeStartTime = nil
local _perfTotalElapsed = 0
local _perfRoundTimerConn = nil
local _removedObjects = {}
local _lastWispLogTime = 0
local _lastAvoidLogTime = 0
local _skipDoneThisRound = false
local _savedProperties = {}
local _savedTerrain = {}
local _savedSkyStarCounts = {}
local _blurEffect = nil
local modalOpen = false
local settingsOpen = false
local transitionBusy = false
local _returnPerfMode = nil
local _profilePrivate = false
local GAME_STATS = {
    wisps = 0,
    skips = 0,
    rounds = 0,
    downed = 0,
    roundTime = 0,
    totalTime = 0,
    isFarming = false,
}
local DISPLAY_TO_GAME = {
    Wisps = "wisps",
    Skips = "skips",
    Rounds = "rounds",
    Downed = "downed",
    ["Round Time"] = "roundTime",
    ["Total Time"] = "totalTime",
}
local function setGameStat(name, val)
    local key = DISPLAY_TO_GAME[name]
    if key then GAME_STATS[key] = val end
    if statVals[name] then statVals[name].Text = tostring(val) end
    if statShadows[name] then statShadows[name].Text = tostring(val) end
end
local function incGameStat(name, amount)
    local key = DISPLAY_TO_GAME[name]
    if not key then return end
    local nextVal = GAME_STATS[key] + (amount or 1)
    setGameStat(name, nextVal)
    return nextVal
end
local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%dh %02dm", h, m)
    end
    return string.format("%d:%02d", m, s)
end
local function parseTime(text)
    if type(text) ~= "string" then return 0 end
    local parts = {}
    for part in string.gmatch(text, "%d+") do
        parts[#parts + 1] = tonumber(part)
    end
    if #parts == 0 then return 0 end
    if #parts == 1 then
        return parts[1]
    elseif #parts == 2 then
        return parts[1] * 60 + parts[2]
    elseif #parts == 3 then
        return parts[1] * 3600 + parts[2] * 60 + parts[3]
    end
    return 0
end
local function refreshPerfStatLabels(perfStatLabels)
    if not perfStatLabels then return end
    if perfStatLabels["perfRounds"] then perfStatLabels["perfRounds"].Text = tostring(GAME_STATS.rounds) end
        if perfStatLabels["perfWisps"] then perfStatLabels["perfWisps"].Text = tostring(GAME_STATS.wisps) end
    if perfStatLabels["perfSkips"] then perfStatLabels["perfSkips"].Text = tostring(GAME_STATS.skips) end
    if perfStatLabels["perfDowned"] then perfStatLabels["perfDowned"].Text = tostring(GAME_STATS.downed) end
    if perfStatLabels["perfRoundTime"] then
        if GAME_STATS.roundTime > 0 then
            perfStatLabels["perfRoundTime"].Text = formatTime(GAME_STATS.roundTime)
        else
            perfStatLabels["perfRoundTime"].Text = "–:––"
        end
    end
    if perfStatLabels["perfTotalTime"] then
        perfStatLabels["perfTotalTime"].Text = formatTime(GAME_STATS.totalTime)
    end
end
local PERF_BACKGROUND_IMAGE = "rbxassetid://120046254113895"

local oldGui = LP.PlayerGui:FindFirstChild("SoulLite")
if oldGui then oldGui:Destroy() end
local ScreenGui = mk("ScreenGui", {Name = "SoulLite", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    DisplayOrder = 1000}, LP.PlayerGui)
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1366, 768)
local SCALE_BASE_W = 1920
local SCALE_BASE_H = 1080
local SCALE_MIN = 0.6
local SCALE_MAX = 1.0
local uiScale = 1
local function computeScale()
    local cam = workspace.CurrentCamera
    local v = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local scaleX = v.X / SCALE_BASE_W
    local scaleY = v.Y / SCALE_BASE_H
    uiScale = math.clamp(math.min(scaleX, scaleY), SCALE_MIN, SCALE_MAX)
    return uiScale
end
uiScale = computeScale()
local MainWindow = mk("Frame", {Name = "MainWindow", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, DESIGN_W * uiScale, 0, DESIGN_H * uiScale),
    BackgroundColor3 = C.Bg, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 1}, ScreenGui)
corner(MainWindow, 36 * uiScale)
stroke(MainWindow, 0.85, C.CardBorder, 1)
shadow(MainWindow, 55, 0.88, 10 * uiScale, C.Shadow)
mk("UIGradient", {Rotation = 90, Color = seq3(Color3.fromRGB(45,45,45), Color3.fromRGB(38,38,38), Color3.fromRGB(255,255,255))}, MainWindow)
local ScaleFrame = mk("Frame", {Name = "ScaleFrame", Size = UDim2.new(0, DESIGN_W, 0, DESIGN_H),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1}, MainWindow)
local _scaleUIScale = mk("UIScale", {Scale = uiScale}, ScaleFrame)
local function UpdateScale()
    uiScale = computeScale()
    MainWindow.Size = UDim2.new(0, DESIGN_W * uiScale, 0, DESIGN_H * uiScale)
    if _scaleUIScale then _scaleUIScale.Scale = uiScale end
    MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    for _, child in ipairs(MainWindow:GetChildren()) do
        if child:IsA("UICorner") then
            child.CornerRadius = UDim.new(0, 36 * uiScale)
        end
    end
end
UpdateScale()
local LEFT_STRIP = 150
local HEADER_H = 64
local BAN_Y = 26 + HEADER_H + 16
local PAD = 34
local CP_X, CP_Y = LEFT_STRIP - 6, 18
local CP_W, CP_H = DESIGN_W - CP_X - 18, DESIGN_H - 36
local INNER_W = CP_W - PAD*2
local BAN_W, BAN_H = INNER_W, 360
local SOUL_Y = BAN_Y + BAN_H + 16
local GRID_Y = SOUL_Y + 50 + 18
local CELL_H, GRID_H = 56, 56*2 + 16
local START_Y = GRID_Y + GRID_H + 14
local BAR_Y = START_Y + 70 + 16
local IMG_R = 26
local ICON_OPEN = "rbxassetid://87979929120640"
local ICON_CLOSED = "rbxassetid://103792531335672"
local realHandle = "@" .. LP.Name
local masked = "@" .. string.rep("•", math.max(4, #LP.Name))
local privacy, busy = true, false
local _fadeBase, _fading, _fadeSeq = nil, false, 0
local _hidingGui = false
local FADE_DUR = 0.25
local dragActive = false
local dragStartMs = Vector2.new()
local dragStartMF = MainWindow.Position
local _guiShown = true
local RED_THEME = {key="blue", calm=Color3.fromRGB(100,100,100), hover=Color3.fromRGB(80,80,80),
	bright=Color3.fromRGB(110,110,110), deep=Color3.fromRGB(40,40,40),
	very=Color3.fromRGB(33,33,33), soul=Color3.fromRGB(0,0,0),
	border=Color3.fromRGB(65,65,65),
	soulGrad=seq3(Color3.fromRGB(90,90,90),Color3.fromRGB(170,170,170),Color3.fromRGB(255,255,255)),
	fillGrad=seq2(Color3.fromRGB(100,100,100),Color3.fromRGB(80,80,80)),
	avatarBg=Color3.fromRGB(100,100,100), sliderStroke=Color3.fromRGB(100,100,100),
	githubText=Color3.fromRGB(135,135,135), tooltipBg=Color3.fromRGB(100,100,100),
	soulDot=Color3.fromRGB(100,100,100), smileyStroke=Color3.fromRGB(100,100,100),
	smileyEye=Color3.fromRGB(100,100,100), headerBg=Color3.fromRGB(42,42,42)}
showToast = function(txt)
    Toast.Text = txt
    Toast.BackgroundTransparency = 1
    Toast.TextTransparency = 1
    Toast.Visible = true
    ease(Toast, 0.2, {BackgroundTransparency = 0.1, TextTransparency = 0})
    task.delay(1.4, function()
        ease(Toast, 0.25, {BackgroundTransparency = 1, TextTransparency = 1})
    end)
end
applyTheme = function(t)
	C.Blue = t.calm; C.BlueHover = t.hover; C.BlueAccent = t.bright
    C.Deep = t.deep; C.Soul = t.soul; C.CardBorder = t.border
    if fillGradObj then fillGradObj.Color = t.fillGrad end
    if thumbStroke then thumbStroke.Color = t.sliderStroke end
    if thumbGlow then thumbGlow.Color = t.sliderStroke end
    if tip then tip.BackgroundColor3 = t.tooltipBg end
    if Avatar then Avatar.BackgroundColor3 = t.avatarBg end
    if eyeIcon then eyeIcon.ImageColor3 = t.githubText end
    if GithubBtn then GithubBtn.TextColor3 = t.githubText end
    if sd then sd.BackgroundColor3 = t.soulDot end
    if faceStroke then faceStroke.Color = t.smileyStroke end
    if eyeL then eyeL.BackgroundColor3 = t.smileyEye end
    if eyeR then eyeR.BackgroundColor3 = t.smileyEye end
    if mouthStroke then mouthStroke.Color = t.smileyStroke end
    if slL then slL.BackgroundColor3 = t.calm end
    if slR then slR.BackgroundColor3 = t.calm end
    if SoulTitle then SoulTitle.TextColor3 = t.soul end
    if SoulShadow then SoulShadow.TextColor3 = t.deep end
    if SoulShadow2 then SoulShadow2.TextColor3 = t.deep end
    if soulGrad then soulGrad.Color = t.soulGrad end
    if BgGlow then BgGlow.BackgroundColor3 = t.deep end
    if autoGrad then autoGrad.Color = seq3(t.deep, t.calm, t.very) end
    if autoRedShadow then autoRedShadow.BackgroundColor3 = t.calm end
    if paintStart then paintStart(farmRunning) end
    for _, e in ipairs(toggleRegs) do featurePaint[e.name](featureStates[e.name]) end
end
paintStart = function(on)
	ease(sDot, 0.25, {BackgroundColor3 = on and C.White or C.BlueHover})
    ease(sDotCore, 0.25, {BackgroundColor3 = on and C.StartOn or C.White})
end

local function applyBlur(targetSize, onComplete)
    pcall(function()
        local existing = Lighting:FindFirstChildOfClass("BlurEffect")
        if existing then existing:Destroy() end
    end)
    local blurObj = Instance.new("BlurEffect")
    blurObj.Size = 0
    blurObj.Parent = Lighting
    _blurEffect = blurObj
    local tw = TweenService:Create(blurObj, TweenInfo.new(0.45, QU, Enum.EasingDirection.Out), {Size = targetSize})
    tw:Play()
    if onComplete then tw.Completed:Connect(onComplete) end
    return blurObj
end

local function removeBlur(onComplete)
    if not _blurEffect then
        if onComplete then onComplete() end
        return
    end
    local blurObj = _blurEffect
    _blurEffect = nil
    local tw = TweenService:Create(blurObj, TweenInfo.new(0.35, QU, Enum.EasingDirection.Out), {Size = 0})
    tw:Play()
    tw.Completed:Connect(function()
        pcall(function() blurObj:Destroy() end)
        if onComplete then onComplete() end
    end)
end

local _savedLighting = {}
local function removeWorldClutter()
    _removedObjects = {}
    _savedProperties = {}
    _savedTerrain = {}
    _savedSkyStarCounts = {}
    for _, eff in ipairs(Lighting:GetChildren()) do
        local cn = eff.ClassName
        if cn == "Bloom" or cn == "BloomEffect" or cn == "SunRays" or cn == "SunRaysEffect"
           or cn == "DepthOfField" or cn == "DepthOfFieldEffect"
           or cn == "ColorCorrection" or cn == "ColorCorrectionEffect"
           or cn == "Atmosphere" or cn == "Clouds" or cn == "Sky" or cn == "BlurEffect" then
            if cn == "Sky" then
                pcall(function() _savedSkyStarCounts[eff] = eff.StarCount end)
            end
            _removedObjects[#_removedObjects+1] = {obj = eff, parent = eff.Parent}
            pcall(function() eff.Parent = nil end)
        end
    end
    _savedLighting.GlobalShadows = Lighting.GlobalShadows
    _savedLighting.Brightness = Lighting.Brightness
    pcall(function() Lighting.GlobalShadows = false end)
    pcall(function()
        _savedTerrain.WaterWaveSize = workspace.Terrain.WaterWaveSize
        _savedTerrain.WaterWaveSpeed = workspace.Terrain.WaterWaveSpeed
        _savedTerrain.WaterReflectance = workspace.Terrain.WaterReflectance
        _savedTerrain.WaterTransparency = workspace.Terrain.WaterTransparency
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
    end)
    local safe = {
        ["Bubble"] = true, ["Nextbot"] = true, ["HumanoidRootPart"] = true,
        ["Humanoid"] = true, ["Game"] = true, ["Collectibles"] = true,
        ["AirPlatform"] = true, ["SoulLiteAirPlatform"] = true,
        ["RadiusVisualizerParts"] = true,
    }
    local function hasSafeAncestor(obj)
        local cur = obj
        while cur and cur ~= workspace do
            if safe[cur.Name] or cur.Name:match("^Sun: Tier%d+$") or cur.Name:match("^Wisps: Tier%d+$") then return true end
            cur = cur.Parent
        end
        return false
    end
    local function shouldRemove(obj)
        if safe[obj.Name] or hasSafeAncestor(obj) then return false end
        local cn = obj.ClassName
        if cn == "ParticleEmitter" or cn == "Fire" or cn == "Smoke" or cn == "Sparkles"
           or cn == "Highlight" or cn == "Trail" or cn == "Beam" or cn == "Explosion"
           or cn == "PointLight" or cn == "SurfaceLight" or cn == "SpotLight"
           or cn == "BillboardGui" or cn == "SurfaceGui" then
            return true
        end
        return false
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not hasSafeAncestor(obj) then
            local saved = {obj = obj}
            pcall(function()
                saved.CastShadow = obj.CastShadow
                saved.Material = obj.Material
                saved.Reflectance = obj.Reflectance
                _savedProperties[#_savedProperties + 1] = saved
                obj.CastShadow = false
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            end)
        end
        if shouldRemove(obj) and obj.Parent then
            _removedObjects[#_removedObjects+1] = {obj = obj, parent = obj.Parent}
            pcall(function() obj.Parent = nil end)
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            _removedObjects[#_removedObjects+1] = {obj = char, parent = char.Parent}
            pcall(function() char.Parent = nil end)
        end
    end
end

local function restoreWorldClutter()
    for _, entry in ipairs(_removedObjects) do
        pcall(function()
            if entry.obj then
                if entry.wasVis ~= nil then
                    entry.obj.Enabled = entry.wasVis
                else
                    entry.obj.Parent = entry.parent
                    if entry.obj:IsA("PostEffect") or entry.obj:IsA("Sky") or entry.obj:IsA("Atmosphere") then
                        pcall(function() entry.obj.Enabled = true end)
                    end
                end
            end
        end)
    end
    for sky, starCount in pairs(_savedSkyStarCounts) do
        pcall(function()
            if sky then sky.StarCount = starCount end
        end)
    end
    _removedObjects = {}
    for _, saved in ipairs(_savedProperties) do
        pcall(function()
            if saved.obj and saved.obj.Parent then
                saved.obj.CastShadow = saved.CastShadow
                saved.obj.Material = saved.Material
                saved.obj.Reflectance = saved.Reflectance
            end
        end)
    end
    _savedProperties = {}
    pcall(function()
        if _savedLighting.GlobalShadows ~= nil then
            Lighting.GlobalShadows = _savedLighting.GlobalShadows
        end
        if _savedLighting.Brightness ~= nil then
            Lighting.Brightness = _savedLighting.Brightness
        end
    end)
    _savedLighting = {}
    pcall(function()
        if _savedTerrain.WaterWaveSize ~= nil then workspace.Terrain.WaterWaveSize = _savedTerrain.WaterWaveSize end
        if _savedTerrain.WaterWaveSpeed ~= nil then workspace.Terrain.WaterWaveSpeed = _savedTerrain.WaterWaveSpeed end
        if _savedTerrain.WaterReflectance ~= nil then workspace.Terrain.WaterReflectance = _savedTerrain.WaterReflectance end
        if _savedTerrain.WaterTransparency ~= nil then workspace.Terrain.WaterTransparency = _savedTerrain.WaterTransparency end
    end)
    _savedTerrain = {}
    _savedSkyStarCounts = {}
end

local setFarm

local function showPerfModeModal(onYes, onNo)
    modalOpen = true
    dragActive = false
    local overlay = mk("Frame", {Name = "PerfModalOverlay",
        Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1, BorderSizePixel = 0, Active = true, ZIndex = 200}, ScreenGui)
    applyBlur(20)
    ease(overlay, 0.3, {BackgroundTransparency = 0.62})
    local cw, ch = math.floor(400 * uiScale), math.floor(230 * uiScale)
    local centerPos = UDim2.new(0.5, 0, 0.5, 0)
    local card = mk("Frame", {Name = "PerfCard",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = centerPos,
        Size = UDim2.new(0, cw, 0, ch),
        BackgroundColor3 = Color3.fromRGB(48, 48, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 201}, overlay)
    corner(card, 20)
    stroke(card, 0, Color3.fromRGB(65, 65, 65), 1.2)
    shadow(card, 40, 0.82, 10, Color3.fromRGB(10, 10, 10))
    local cardGlow = mk("Frame", {Name = "CardGlow", Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55), BackgroundTransparency = 0.95,
        BorderSizePixel = 0, ZIndex = 201}, card)
    corner(cardGlow, 20)
    mk("UIGradient", {Rotation = 135,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1,   0.4),
        })
    }, cardGlow)
    card.Position = UDim2.new(0.5, 0, 0.5, 16)
    card.BackgroundTransparency = 1
    ease(card, 0.38, {BackgroundTransparency = 0, Position = centerPos})

    local iconSz = math.floor(40 * uiScale)
    local icon = mk("TextLabel", {Name = "AlertIcon",
        AnchorPoint = Vector2.new(0.5,0), Position = UDim2.new(0.5,0,0,math.floor(16*uiScale)),
        Size = UDim2.new(0,iconSz,0,iconSz),
        BackgroundColor3 = Color3.fromRGB(180, 180, 180),
        Text = "!", Font = F_BOLD, TextSize = math.floor(22*uiScale),
        TextColor3 = Color3.fromRGB(40, 40, 40),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 202}, card)
    corner(icon, iconSz // 2)

    mk("TextLabel", {Name = "Title",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,math.floor(66*uiScale)),
        Size = UDim2.new(0,math.floor(350*uiScale),0,math.floor(28*uiScale)),
        BackgroundTransparency = 1,
        Text = "Enable Performance Mode?",
        Font = F_BOLD, TextSize = math.floor(18*uiScale),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 202}, card)
    mk("TextLabel", {Name = "Subtitle",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,math.floor(100*uiScale)),
        Size = UDim2.new(0,math.floor(330*uiScale),0,math.floor(38*uiScale)),
        BackgroundTransparency = 1,
        Text = "Disable visuals and effects to maximize farming performance.",
        Font = F_REG, TextSize = math.floor(12*uiScale),
        TextColor3 = Color3.fromRGB(140, 140, 140),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 202}, card)
    mk("Frame", {Name = "Divider",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, math.floor(148*uiScale)),
        Size = UDim2.new(0, math.floor(330*uiScale), 0, 1),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        BorderSizePixel = 0, ZIndex = 202}, card)

    local btnW = math.floor(118 * uiScale)
    local btnH = math.floor(42  * uiScale)
    local btnY = math.floor(-18 * uiScale)

    local yesBg  = Color3.fromRGB(180, 180, 180)
    local yesBrd = Color3.fromRGB(135, 135, 135)
    local yesTx  = Color3.fromRGB(40, 40, 40)
    local yesBtn = mk("TextButton", {Name = "YesBtn",
        AnchorPoint = Vector2.new(0.5,1),
      Position = UDim2.new(0.33,0,1,btnY),
        Size = UDim2.new(0, btnW, 0, btnH),
        BackgroundColor3 = yesBg,
        BorderSizePixel = 0, Text = "YES",
        Font = F_BOLD, TextSize = math.floor(16*uiScale),
        TextColor3 = yesTx,
        AutoButtonColor = false, ZIndex = 202}, card)
    corner(yesBtn, 12)
    mk("UIStroke", {Color = yesBrd, Thickness = 1.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0}, yesBtn)
	shadow(yesBtn, 18, 0.72, 6, Color3.fromRGB(10,10,10))

    local noBg  = Color3.fromRGB(56, 56, 56)
    local noBrd = Color3.fromRGB(70, 70, 70)
    local noTx  = Color3.fromRGB(180, 180, 180)
    local noBtn = mk("TextButton", {Name = "NoBtn",
        AnchorPoint = Vector2.new(0.5,1),
Position = UDim2.new(0.67,0,1,btnY),
        Size = UDim2.new(0, btnW, 0, btnH),
        BackgroundColor3 = noBg,
        BorderSizePixel = 0, Text = "NO",
        Font = F_BOLD, TextSize = math.floor(16*uiScale),
        TextColor3 = noTx,
        AutoButtonColor = false, ZIndex = 202}, card)
    corner(noBtn, 12)
    mk("UIStroke", {Color = noBrd, Thickness = 1.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0}, noBtn)

    local yesBgH = Color3.fromRGB(158, 158, 158)
    local noBgH  = Color3.fromRGB(48, 48, 48)

    yesBtn.MouseEnter:Connect(function()
        ease(yesBtn, 0.14, {BackgroundColor3 = yesBgH, Size = UDim2.new(0, btnW+6, 0, btnH+2)})
    end)
    yesBtn.MouseLeave:Connect(function()
        ease(yesBtn, 0.14, {BackgroundColor3 = yesBg,  Size = UDim2.new(0, btnW,   0, btnH)})
    end)
    noBtn.MouseEnter:Connect(function()
        ease(noBtn, 0.14, {BackgroundColor3 = noBgH, Size = UDim2.new(0, btnW+6, 0, btnH+2)})
    end)
    noBtn.MouseLeave:Connect(function()
        ease(noBtn, 0.14, {BackgroundColor3 = noBg,  Size = UDim2.new(0, btnW,   0, btnH)})
    end)

    local function closeModal(cb)
        ease(overlay, 0.28, {BackgroundTransparency = 1})
        local function fadeChildren(parent, duration)
            if not parent then return end
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("TextLabel") then
                    ease(child, duration, {TextTransparency = 1})
                    local ok, bt = pcall(function() return child.BackgroundTransparency end)
                    if ok and bt < 1 then
                        ease(child, duration, {BackgroundTransparency = 1})
                    end
                    fadeChildren(child, duration)
                elseif child:IsA("TextButton") then
                    ease(child, duration, {TextTransparency = 1})
                    local ok, bt = pcall(function() return child.BackgroundTransparency end)
                    if ok and bt < 1 then
                        ease(child, duration, {BackgroundTransparency = 1})
                    end
                    fadeChildren(child, duration)
                elseif child:IsA("UIStroke") then
                    ease(child, duration, {Transparency = 1})
                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    ease(child, duration, {ImageTransparency = 1})
                    fadeChildren(child, duration)
                elseif child:IsA("Frame") then
                    local ok, bt = pcall(function() return child.BackgroundTransparency end)
                    if ok and bt < 1 then
                        ease(child, duration, {BackgroundTransparency = 1})
                    end
                    local ok2, it = pcall(function() return child.ImageTransparency end)
                    if ok2 and it < 1 then
                        ease(child, duration, {ImageTransparency = 1})
                    end
                    fadeChildren(child, duration)
                end
            end
        end
        ease(card, 0.22, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 18)})
        fadeChildren(card, 0.22)
        task.delay(0.45, function()
            removeBlur(function()
                pcall(function() overlay:Destroy() end)
                modalOpen = false
                if cb then cb() end
            end)
        end)
    end

    noBtn.MouseButton1Click:Connect(function() closeModal(onNo) end)
    yesBtn.MouseButton1Click:Connect(function() closeModal(onYes) end)

    overlay.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local clickPos = i.Position
            local cardAbsPos = card.AbsolutePosition
            local cardAbsSize = card.AbsoluteSize
            if clickPos.X < cardAbsPos.X or clickPos.X > cardAbsPos.X + cardAbsSize.X or
               clickPos.Y < cardAbsPos.Y or clickPos.Y > cardAbsPos.Y + cardAbsSize.Y then
                closeModal()
            end
        end
    end)
end

local function showStopFarmModal(onYes, onNo)
    modalOpen = true
    dragActive = false
    local inPerf = perfModeActive
    local host   = _perfScreenGui or ScreenGui
    local overlay = mk("Frame", {Name = "StopModalOverlay",
        Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = inPerf and 0.55 or 0.62,
        BorderSizePixel = 0, Active = true, ZIndex = 500}, host)
    if not inPerf then applyBlur(18) end

    local modalPosition = UDim2.new(0.5, 0, 0.5, 0)
    local cw = math.floor(400 * uiScale)
    local ch = math.floor(230 * uiScale)
    local cardBg = Color3.fromRGB(48, 48, 48)
    local card = mk("Frame", {Name = "StopCard",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5, 0, 0.5, 14),
        Size = UDim2.new(0, cw, 0, ch),
        BackgroundColor3 = cardBg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 501}, overlay)
    corner(card, 20)
    stroke(card, 0, Color3.fromRGB(65, 65, 65), 1.2)
    shadow(card, 40, 0.82, 10, Color3.fromRGB(10, 10, 10))
    ease(card, 0.35, {BackgroundTransparency = 0, Position = modalPosition})

    local iconSz = math.floor(38 * uiScale)
    local icon = mk("TextLabel", {Name = "AlertIcon",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,math.floor(16*uiScale)),
        Size = UDim2.new(0,iconSz,0,iconSz),
        BackgroundColor3 = Color3.fromRGB(180, 180, 180),
        Text = "!", Font = F_BOLD, TextSize = math.floor(22*uiScale),
        TextColor3 = Color3.fromRGB(40,40,40),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 502}, card)
    corner(icon, iconSz // 2)

    mk("TextLabel", {Name = "Title",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,math.floor(62*uiScale)),
        Size = UDim2.new(0,math.floor(350*uiScale),0,math.floor(34*uiScale)),
        BackgroundTransparency = 1,
        Text = "Stop Farm?",
        Font = F_BOLD, TextSize = math.floor(18*uiScale),
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 502}, card)
    mk("TextLabel", {Name = "Subtitle",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,math.floor(101*uiScale)),
        Size = UDim2.new(0,math.floor(340*uiScale),0,math.floor(32*uiScale)),
        BackgroundTransparency = 1,
        Text = "Are you sure you want to stop the farming process?",
        Font = F_REG, TextSize = math.floor(12*uiScale),
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 502}, card)
    mk("Frame", {Name = "Divider",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,math.floor(148*uiScale)),
        Size = UDim2.new(0,math.floor(330*uiScale),0,1),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        BorderSizePixel = 0, ZIndex = 502}, card)

    local btnW = math.floor(118 * uiScale)
    local btnH = math.floor(42  * uiScale)
    local btnY = math.floor(-18 * uiScale)

    local yesBg  = Color3.fromRGB(180, 180, 180)
    local yesBrd = Color3.fromRGB(135,135,135)
    local yesTx  = Color3.fromRGB(40, 40, 40)
    local yesBtn = mk("TextButton", {Name = "YesBtn",
        AnchorPoint = Vector2.new(0.5,1),
 Position = UDim2.new(0.33,0,1,btnY),
        Size = UDim2.new(0, btnW, 0, btnH),
        BackgroundColor3 = yesBg,
        BorderSizePixel = 0, Text = "YES",
        Font = F_BOLD, TextSize = math.floor(16*uiScale),
        TextColor3 = yesTx,
        AutoButtonColor = false, ZIndex = 502}, card)
    corner(yesBtn, 12)
    mk("UIStroke", {Color = yesBrd, Thickness = 1.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0}, yesBtn)
    shadow(yesBtn, 18, 0.72, 6, Color3.fromRGB(10, 10, 10))

    local noBg  = Color3.fromRGB(56, 56, 56)
    local noBrd = Color3.fromRGB(70, 70, 70)
    local noTx  = Color3.fromRGB(180, 180, 180)
    local noBtn = mk("TextButton", {Name = "NoBtn",
        AnchorPoint = Vector2.new(0.5,1),
Position = UDim2.new(0.67,0,1,btnY),
        Size = UDim2.new(0, btnW, 0, btnH),
        BackgroundColor3 = noBg,
        BorderSizePixel = 0, Text = "NO",
        Font = F_BOLD, TextSize = math.floor(16*uiScale),
        TextColor3 = noTx,
        AutoButtonColor = false, ZIndex = 502}, card)
    corner(noBtn, 12)
    mk("UIStroke", {Color = noBrd, Thickness = 1.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0}, noBtn)

    local yesBgH = Color3.fromRGB(158,158,158)
    local noBgH  = Color3.fromRGB(48,48,48)

    yesBtn.MouseEnter:Connect(function()
        ease(yesBtn, 0.14, {BackgroundColor3 = yesBgH, Size = UDim2.new(0, btnW+6, 0, btnH+2)})
    end)
    yesBtn.MouseLeave:Connect(function()
        ease(yesBtn, 0.14, {BackgroundColor3 = yesBg,  Size = UDim2.new(0, btnW,   0, btnH)})
    end)
    noBtn.MouseEnter:Connect(function()
        ease(noBtn, 0.14, {BackgroundColor3 = noBgH, Size = UDim2.new(0, btnW+6, 0, btnH+2)})
    end)
    noBtn.MouseLeave:Connect(function()
        ease(noBtn, 0.14, {BackgroundColor3 = noBg,  Size = UDim2.new(0, btnW,   0, btnH)})
    end)

    local function closeModal(cb)
        ease(overlay, 0.28, {BackgroundTransparency = 1})
        local function fadeChildren(parent, duration)
            if not parent then return end
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("TextLabel") then
                    ease(child, duration, {TextTransparency = 1})
                    local ok, bt = pcall(function() return child.BackgroundTransparency end)
                    if ok and bt < 1 then
                        ease(child, duration, {BackgroundTransparency = 1})
                    end
                    fadeChildren(child, duration)
                elseif child:IsA("TextButton") then
                    ease(child, duration, {TextTransparency = 1})
                    local ok, bt = pcall(function() return child.BackgroundTransparency end)
                    if ok and bt < 1 then
                        ease(child, duration, {BackgroundTransparency = 1})
                    end
                    fadeChildren(child, duration)
                elseif child:IsA("UIStroke") then
                    ease(child, duration, {Transparency = 1})
                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    ease(child, duration, {ImageTransparency = 1})
                    fadeChildren(child, duration)
                elseif child:IsA("Frame") then
                    local ok, bt = pcall(function() return child.BackgroundTransparency end)
                    if ok and bt < 1 then
                        ease(child, duration, {BackgroundTransparency = 1})
                    end
                    local ok2, it = pcall(function() return child.ImageTransparency end)
                    if ok2 and it < 1 then
                        ease(child, duration, {ImageTransparency = 1})
                    end
                    fadeChildren(child, duration)
                end
            end
        end
        ease(card, 0.22, {BackgroundTransparency = 1})
        fadeChildren(card, 0.22)
        task.delay(0.45, function()
            if not inPerf then
                removeBlur(function()
                    pcall(function() overlay:Destroy() end)
                    modalOpen = false
                    if cb then cb() end
                end)
            else
                pcall(function() overlay:Destroy() end)
                modalOpen = false
                if cb then cb() end
            end
        end)
    end

    yesBtn.MouseButton1Click:Connect(function() closeModal(onYes) end)
    noBtn.MouseButton1Click:Connect(function()  closeModal(onNo)  end)

    overlay.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local clickPos = i.Position
            local cardAbsPos = card.AbsolutePosition
            local cardAbsSize = card.AbsoluteSize
            if clickPos.X < cardAbsPos.X or clickPos.X > cardAbsPos.X + cardAbsSize.X or
               clickPos.Y < cardAbsPos.Y or clickPos.Y > cardAbsPos.Y + cardAbsSize.Y then
                closeModal()
            end
        end
    end)
end

local function buildPerfScreen(skipCinematic)
    if _perfScreenGui then pcall(function() _perfScreenGui:Destroy() end) end
    local revealDelay = skipCinematic and 0 or 5.0
    local quickReveal = skipCinematic and 0 or 0.1
    local quickLog    = skipCinematic and 0 or 0.15
    local sg = mk("ScreenGui", {Name = "SoulPerfMode", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
        DisplayOrder = 2147483640}, PG)
    _perfScreenGui = sg
    do
        local function computePerfScale()
            local vp = workspace.CurrentCamera.ViewportSize
            local baseW = 1920
            local s = math.clamp(vp.X / baseW, 0.55, 1.2)
            return s
        end
        local perfScale = Instance.new("UIScale")
        perfScale.Scale = computePerfScale()
        perfScale.Parent = sg
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if sg and sg.Parent then perfScale.Scale = computePerfScale() end
        end)
    end
    local bg = mk("Frame", {Name = "Bg", Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0, BorderSizePixel = 0, Active = true, ZIndex = 1}, sg)
    local perfBackdrop
    if PERF_BACKGROUND_IMAGE ~= "" then
        perfBackdrop = mk("ImageLabel", {Name = "CustomBackdrop",
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
            Image = PERF_BACKGROUND_IMAGE, ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Fit, Active = false, ZIndex = 2}, sg)
        local backdropFade = mk("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,   0.00),
                NumberSequenceKeypoint.new(0.15,0.00),
                NumberSequenceKeypoint.new(0.45,0.55),
                NumberSequenceKeypoint.new(0.70,0.88),
                NumberSequenceKeypoint.new(1,   1.00),
            }),
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,0,0)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
            })}, perfBackdrop)
        local shade = mk("Frame", {Name = "BackdropShade", Size = UDim2.new(1,0,1,0),
            BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.72,
            BorderSizePixel = 0, Active = true, ZIndex = 3}, sg)
    end
    local phaseOverlay = mk("Frame", {Name = "PhaseOverlay",
        Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = skipCinematic and 1 or 0,
        BorderSizePixel = 0, Active = false, ZIndex = 9}, sg)
    if skipCinematic then
        phaseOverlay.Visible = false
        phaseOverlay.Active = false
    end

    local byLabel = mk("TextLabel", {Name = "ByLabel",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.new(0.25,0,0.06,0),
        BackgroundTransparency = 1,
        Text = "BY RGPLUGG",
        Font = F_BOLD, TextSize = 58,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextTransparency = 1,
        Visible = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 10}, sg)
    if skipCinematic then
        byLabel.AnchorPoint = Vector2.new(0,0)
        byLabel.Position = UDim2.new(0.14,0,0.02,0)
        byLabel.Size = UDim2.new(0.08,0,0.025,0)
        byLabel.TextSize = 13
        byLabel.TextTransparency = 1
        byLabel.TextXAlignment = Enum.TextXAlignment.Left
        byLabel.ZIndex = 12
        byLabel.TextColor3 = Color3.fromRGB(180,185,210)
        byLabel.Font = F_SEMI
        task.delay(0.3, function()
            if byLabel and byLabel.Parent then
                ease(byLabel, 0.8, {TextTransparency = 0})
            end
        end)
    end

local animeBackdropBg = mk("Frame", {Name = "AnimeBackdropBg",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, 0, 0.5, 0),
Size = UDim2.new(0.58, 0, 1.06, 0),
BackgroundColor3 = Color3.fromRGB(0, 0, 0),
BackgroundTransparency = 0,
BorderSizePixel = 0, ZIndex = 2}, sg)
local animeBackdrop = mk("ImageLabel", {Name = "AnimeBackdrop",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, 0, 0.5, 0),
Size = UDim2.new(0.58, 0, 1.06, 0),
BackgroundTransparency = 1,
Image = "rbxassetid://113282903729136",
ImageTransparency = 0,
ScaleType = Enum.ScaleType.Crop,
ZIndex = 3}, sg)
local function backdropFade(name, px, sx, keys)
local f = mk("Frame", {Name = name,
Position = UDim2.new(px, 0, 0, 0),
Size = UDim2.new(sx, 0, 1, 0),
BackgroundColor3 = Color3.fromRGB(0,0,0),
BorderSizePixel = 0, ZIndex = 4}, sg)
mk("UIGradient", {Rotation = 0, Transparency = NumberSequence.new(keys)}, f)
return f
end
backdropFade("BackdropFadeLeft", 0.42, 0.16, {
NumberSequenceKeypoint.new(0, 0),
NumberSequenceKeypoint.new(1, 1),
})
backdropFade("BackdropFadeRight", 0.86, 0.14, {
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(1, 0),
})

    local animeShade = mk("Frame", {Name = "AnimeRightShade",
        AnchorPoint = Vector2.new(0, 0.5),
        Position    = UDim2.new(1, 0, 0.5, 0),
        Size        = UDim2.new(0.35, 0, 1.0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 4}, sg)
    local animeShadeGrad = mk("UIGradient", {Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.00),
            NumberSequenceKeypoint.new(0.15,0.00),
            NumberSequenceKeypoint.new(0.45,0.55),
            NumberSequenceKeypoint.new(0.70,0.88),
            NumberSequenceKeypoint.new(1,   1.00),
        }),
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
        })}, animeShade)

      local lineContainer = mk("Frame", {Name = "LineContainer",
          Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0),
          BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 11}, sg)

      local _bloomEff
      if not skipCinematic then
          _bloomEff = Instance.new("BloomEffect")
          _bloomEff.Intensity  = 1.2
          _bloomEff.Size       = 22
          _bloomEff.Threshold  = 0.78
          _bloomEff.Parent     = game:GetService("Lighting")
      end

      local orbCore = mk("Frame", {Name = "OrbCore",
          AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0,0,0,0),
          Size = UDim2.new(0.005,0,0.005,0), BackgroundColor3 = Color3.fromRGB(240,230,255),
          BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4}, lineContainer)
      corner(orbCore, 0.003)
      local orbGlow = mk("Frame", {Name = "OrbGlow",
          AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0,0,0,0),
          Size = UDim2.new(0.01,0,0.01,0), BackgroundColor3 = Color3.fromRGB(155,100,255),
          BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4}, lineContainer)
      corner(orbGlow, 0.005)
      local orbOuter = mk("Frame", {Name = "OrbOuter",
          AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0,0,0,0),
          Size = UDim2.new(0.018,0,0.018,0), BackgroundColor3 = Color3.fromRGB(110,60,210),
          BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4}, lineContainer)
      corner(orbOuter, 0.009)
      local orbBloom = mk("Frame", {Name = "OrbBloom",
          AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0,0,0,0),
          Size = UDim2.new(0.033,0,0.033,0), BackgroundColor3 = Color3.fromRGB(80,30,180),
          BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4}, lineContainer)
      corner(orbBloom, 0.017)

      if not skipCinematic then
          task.delay(0.5, function()
              ease(byLabel,  0.8, {TextTransparency = 0})
              ease(orbCore,  0.6, {BackgroundTransparency = 0.0})
              ease(orbGlow,  0.6, {BackgroundTransparency = 0.50})
              ease(orbOuter, 0.6, {BackgroundTransparency = 0.82})
              ease(orbBloom, 0.6, {BackgroundTransparency = 0.90})
          end)
      end

      local _CAT_RAW = {
          {1821.63,637.76},{1821.35,619.8},{1820.51,602.15},{1819.13,584.8},{1817.21,567.75},
          {1814.76,551.02},{1811.79,534.58},{1808.31,518.45},{1804.33,502.63},{1799.85,487.1},
          {1794.89,471.88},{1789.46,456.96},{1783.56,442.35},{1777.2,428.04},{1770.39,414.02},
          {1763.15,400.31},{1755.47,386.9},{1747.37,373.79},{1738.86,360.98},{1729.94,348.47},
          {1720.63,336.26},{1710.93,324.34},{1706.43,315.83},{1708.52,309.98},{1710.89,302.82},
          {1713.42,294.37},{1716.03,284.68},{1718.61,273.78},{1721.08,261.7},{1723.34,248.49},
          {1725.28,234.18},{1726.82,218.8},{1727.86,202.4},{1728.29,185.01},{1728.03,166.66},
          {1726.98,147.4},{1725.04,127.25},{1722.12,106.26},{1718.12,84.46},{1712.94,61.89},
          {1706.48,38.58},{1698.66,14.57},{1694.2,2.72},{1692.9,2.36},{1690.29,1.78},
          {1686.36,1.12},{1681.11,0.51},{1674.5,0.11},{1666.52,0.04},{1657.16,0.45},
          {1646.4,1.47},{1634.23,3.25},{1620.62,5.92},{1605.56,9.62},{1589.03,14.49},
          {1571.02,20.67},{1551.5,28.3},{1530.47,37.51},{1507.91,48.46},{1483.79,61.27},
          {1458.11,76.08},{1430.84,93.04},{1401.97,112.28},{1377.82,123.12},{1362.47,118.88},
          {1347.01,114.89},{1331.45,111.14},{1315.78,107.65},{1300.03,104.41},{1284.19,101.42},
          {1268.28,98.67},{1252.3,96.18},{1236.26,93.93},{1220.17,91.93},{1204.04,90.18},
          {1187.87,88.68},{1171.67,87.42},{1155.45,86.41},{1139.22,85.64},{1122.98,85.12},
          {1106.74,84.84},{1090.5,84.9},{1074.26,85.26},{1058.01,85.86},{1041.77,86.7},
          {1025.56,87.79},{1009.36,89.13},{993.2,90.72},{977.07,92.55},{961.0,94.63},
          {944.98,96.95},{929.02,99.53},{913.13,102.35},{897.32,105.43},{881.6,108.75},
          {865.97,112.33},{850.45,116.15},{835.03,120.23},{819.74,124.56},{791.0,105.79},
          {762.65,87.31},{735.9,71.07},{710.72,56.93},{687.1,44.74},{665.03,34.37},
          {644.49,25.68},{625.46,18.54},{607.92,12.79},{591.86,8.32},{577.26,4.96},
          {564.1,2.59},{552.37,1.07},{542.06,0.26},{533.13,0.02},{525.59,0.21},
          {519.4,0.69},{514.57,1.32},{511.05,1.97},{508.86,2.5},{507.95,2.76},
          {501.04,22.14},{493.66,45.93},{487.62,69.01},{482.82,91.35},{479.17,112.9},
          {476.57,133.63},{474.93,153.51},{474.14,172.49},{474.12,190.54},{474.76,207.63},
          {475.97,223.71},{477.65,238.76},{479.71,252.73},{482.05,265.59},{484.57,277.31},
          {487.18,287.83},{489.78,297.14},{492.28,305.19},{494.57,311.95},{496.56,317.37},
          {488.42,328.02},{478.85,340.03},{469.67,352.33},{460.88,364.94},{452.49,377.84},
          {444.51,391.04},{436.96,404.54},{429.83,418.34},{423.15,432.45},{416.92,446.85},
          {411.14,461.56},{405.84,476.57},{401.01,491.88},{396.67,507.5},{392.82,523.41},
          {389.48,539.63},{386.66,556.16},{384.36,572.99},{382.59,590.12},{381.37,607.56},
          {380.7,625.31},{380.59,645.48},{381.02,670.04},{381.96,693.89},{383.42,717.06},
          {385.37,739.54},{387.81,761.35},{390.74,782.51},{394.12,803.01},{397.97,822.87},
          {402.27,842.1},{407.0,860.72},{412.16,878.72},{417.73,896.13},{423.72,912.96},
          {430.09,929.2},{436.86,944.88},{444.0,960.0},{451.51,974.58},{459.37,988.62},
          {467.57,1002.14},{476.12,1015.15},{484.98,1027.65},{494.16,1039.66},{503.64,1051.18},
          {513.42,1062.24},{523.48,1072.83},{533.82,1082.97},{544.41,1092.67},{555.26,1101.94},
          {566.36,1110.79},{577.68,1119.23},{589.23,1127.27},{600.99,1134.93},{612.95,1142.2},
          {625.1,1149.11},{637.43,1155.66},{649.93,1161.87},{662.59,1167.74},{675.41,1173.28},
          {688.36,1178.51},{701.44,1183.44},{714.65,1188.07},{727.96,1192.41},{741.37,1196.49},
          {754.87,1200.3},{768.44,1203.85},{782.09,1207.17},{795.79,1210.26},{809.54,1213.12},
          {823.33,1215.77},{837.14,1218.23},{850.98,1220.49},{864.81,1222.58},{878.65,1224.49},
          {892.47,1226.25},{894.32,1227.0},{891.69,1228.72},{887.26,1231.73},{881.24,1236.01},
          {873.81,1241.54},{865.15,1248.3},{855.46,1256.27},{844.94,1265.44},{833.76,1275.78},
          {822.11,1287.28},{810.2,1299.91},{798.19,1313.67},{786.3,1328.53},{774.7,1344.46},
          {763.58,1361.47},{753.14,1379.51},{743.57,1398.58},{735.04,1418.66},{727.76,1439.72},
          {721.91,1461.76},{717.68,1484.75},{715.26,1508.66},{712.76,1526.9},{705.25,1530.27},
          {696.45,1533.95},{686.46,1537.88},{675.36,1541.99},{663.24,1546.18},{650.17,1550.4},
          {636.25,1554.57},{621.56,1558.6},{606.18,1562.43},{590.19,1565.98},{573.69,1569.17},
          {556.76,1571.93},{539.48,1574.19},{521.93,1575.86},{504.2,1576.87},{486.38,1577.15},
          {468.54,1576.62},{450.78,1575.2},{433.18,1572.83},{415.82,1569.42},{398.79,1564.89},
          {382.17,1559.19},{366.05,1552.22},{350.51,1543.91},{335.63,1534.2},{321.5,1522.99},
          {308.21,1510.22},{295.83,1495.82},{284.46,1479.7},{277.31,1467.65},{275.74,1464.81},
          {272.26,1458.98},{266.9,1450.69},{259.67,1440.45},{250.59,1428.77},{239.67,1416.18},
          {226.91,1403.19},{212.35,1390.32},{195.98,1378.09},{177.83,1367.01},{157.9,1357.61},
          {136.21,1350.4},{112.78,1345.89},{102.34,1345.08},{93.05,1345.56},{79.71,1347.4},
          {66.1,1351.49},{56.0,1358.74},{53.2,1370.04},{61.48,1386.31},{84.62,1408.43},
          {97.13,1417.76},{99.77,1419.26},{104.45,1422.23},{110.93,1426.8},{118.98,1433.15},
          {128.37,1441.42},{138.86,1451.78},{150.21,1464.37},{162.2,1479.35},{174.59,1496.88},
          {187.14,1517.11},{199.63,1540.21},{211.81,1566.31},{222.06,1591.8},{222.23,1592.62},
          {222.72,1594.68},{223.56,1597.9},{224.8,1602.18},{226.47,1607.43},{228.62,1613.56},
          {231.29,1620.48},{234.51,1628.08},{238.34,1636.29},{242.81,1645.01},{247.96,1654.15},
          {253.83,1663.61},{260.47,1673.31},{267.92,1683.14},{276.21,1693.03},{285.4,1702.87},
          {295.51,1712.58},{306.59,1722.06},{318.68,1731.23},{331.83,1739.98},{346.08,1748.23},
          {361.45,1755.89},{378.01,1762.85},{395.78,1769.04},{414.81,1774.36},{435.14,1778.72},
          {456.81,1782.02},{479.87,1784.17},{504.35,1785.08},{530.29,1784.67},{557.74,1782.82},
          {586.74,1779.47},{617.32,1774.51},{649.54,1767.84},{683.42,1759.39},{711.39,1751.78},
          {712.38,1757.39},{713.04,1768.89},{713.42,1784.98},{713.58,1804.38},{713.56,1825.79},
          {713.43,1847.93},{713.23,1869.51},{713.01,1889.23},{712.82,1905.8},{712.73,1917.94},
          {725.09,1920.0},{741.24,1920.0},{757.39,1920.0},{773.54,1920.0},{789.68,1920.0},
          {805.83,1920.0},{821.98,1920.0},{838.13,1920.0},{854.28,1920.0},{870.42,1920.0},
          {886.57,1920.0},{902.72,1920.0},{918.87,1920.0},{935.02,1920.0},{951.17,1920.0},
          {967.31,1920.0},{983.46,1920.0},{999.61,1920.0},{1015.76,1920.0},{1031.91,1920.0},
          {1048.05,1920.0},{1064.2,1920.0},{1080.35,1920.0},{1096.5,1920.0},{1112.65,1920.0},
          {1128.79,1920.0},{1144.94,1920.0},{1161.09,1920.0},{1177.24,1920.0},{1193.39,1920.0},
          {1209.53,1920.0},{1225.68,1920.0},{1241.83,1920.0},{1257.98,1920.0},{1274.13,1920.0},
          {1290.27,1920.0},{1306.42,1920.0},{1322.57,1920.0},{1338.72,1920.0},{1354.87,1920.0},
          {1371.01,1920.0},{1387.16,1920.0},{1403.31,1920.0},{1419.46,1920.0},{1435.61,1920.0},
          {1451.75,1920.0},{1467.9,1920.0},{1484.05,1920.0},{1489.9,1919.35},{1489.92,1915.82},
          {1489.94,1909.43},{1489.98,1900.43},{1490.04,1889.06},{1490.1,1875.55},{1490.16,1860.17},
          {1490.24,1843.13},{1490.31,1824.69},{1490.4,1805.09},{1490.48,1784.57},{1490.56,1763.37},
          {1490.65,1741.74},{1490.73,1719.9},{1490.81,1698.12},{1490.89,1676.63},{1490.96,1655.66},
          {1491.02,1635.47},{1491.07,1616.29},{1491.12,1598.37},{1491.15,1581.95},{1491.17,1567.27},
          {1491.18,1554.16},{1490.43,1528.35},{1488.34,1503.9},{1485.01,1480.78},{1480.54,1458.94},
          {1475.03,1438.34},{1468.58,1418.95},{1461.3,1400.71},{1453.28,1383.59},{1444.63,1367.55},
          {1435.46,1352.54},{1425.85,1338.52},{1415.92,1325.45},{1405.76,1313.3},{1395.47,1302.01},
          {1385.17,1291.54},{1374.95,1281.86},{1364.91,1272.93},{1355.15,1264.69},{1345.77,1257.12},
          {1336.89,1250.16},{1328.59,1243.78},{1320.98,1237.93},{1314.17,1232.58},{1308.25,1227.68},
          {1313.49,1224.69},{1327.35,1222.91},{1341.22,1220.98},{1355.09,1218.87},{1368.94,1216.58},
          {1382.78,1214.1},{1396.58,1211.42},{1410.34,1208.53},{1424.05,1205.41},{1437.7,1202.06},
          {1451.28,1198.46},{1464.77,1194.61},{1478.17,1190.49},{1491.46,1186.1},{1504.65,1181.42},
          {1517.71,1176.44},{1530.63,1171.15},{1543.41,1165.55},{1556.04,1159.62},{1568.5,1153.34},
          {1580.79,1146.72},{1592.89,1139.74},{1604.8,1132.38},{1616.5,1124.64},{1627.99,1116.51},
          {1639.25,1107.98},{1650.28,1099.04},{1661.06,1089.67},{1671.58,1079.86},{1681.83,1069.61},
          {1691.81,1058.91},{1701.5,1047.73},{1710.9,1036.08},{1719.98,1023.95},{1728.75,1011.31},
          {1737.19,998.17},{1745.29,984.51},{1753.05,970.32},{1760.44,955.58},{1767.47,940.3},
          {1774.12,924.45},{1780.37,908.04},{1786.23,891.04},{1791.68,873.45},{1796.71,855.25},
          {1801.3,836.44},{1805.46,817.0},{1809.17,796.93},{1812.41,776.22},{1815.19,754.84},
          {1817.48,732.8},{1819.28,710.09},{1820.58,686.68},{1821.36,662.57},{1821.63,637.76},
      }

      local _vp     = workspace.CurrentCamera.ViewportSize
      local _vpW    = _vp.X;  local _vpH = _vp.Y
      local _srcW   = 1768.43; local _srcH = 1919.98
      local _minX   = 53.2;    local _minY = 0.02
       local _cSc    = math.min(_vpW * 0.12 / _srcW, _vpH * 0.28 / _srcH)
       local _rawCX  = _minX + _srcW * 0.5
       local _rawCY  = _srcH * 0.5
       local _cOX    = _vpW * 0.42 - _rawCX * _cSc
       local _cOY    = _vpH * 0.50 - _rawCY * _cSc

      local CAT_POINTS = {}
      for _, p in ipairs(_CAT_RAW) do
          table.insert(CAT_POINTS, {p[1]*_cSc + _cOX, p[2]*_cSc + _cOY})
       end

       local _LINE_THICK = 2
       local _LINE_COL   = Color3.fromRGB(130, 90, 255)
       local _GLOW_COL   = Color3.fromRGB(70,  30, 170)

       local _PCOLS = {
           Color3.fromRGB(100, 70, 180),
           Color3.fromRGB(80,  45, 160),
           Color3.fromRGB(120, 95, 200),
           Color3.fromRGB(65,  30, 140),
           Color3.fromRGB(140, 110, 210),
       }

       local _silhDotRefs = {}
       local _slidingAway = false

       local _N = #CAT_POINTS

      local function drawSegment(i)
          local p1 = CAT_POINTS[i];  local p2 = CAT_POINTS[i+1]
          if not p1 or not p2 then return end
          local dx = p2[1]-p1[1];  local dy = p2[2]-p1[2]
          local ln = math.sqrt(dx*dx + dy*dy)
          if ln < 0.1 then return end
          local ag = math.deg(math.atan2(dy, dx))
          local mx = (p1[1]+p2[1])*0.5;  local my = (p1[2]+p2[2])*0.5
          local prog = i / _N
          local isLeft = prog > 0.52
          local glA = isLeft and (0.83 + math.random()*0.10) or (0.68 + math.random()*0.12)
          local glH = isLeft and (_LINE_THICK*3) or (_LINE_THICK*4 + math.random()*3)
          local gl = mk("Frame", {
              AnchorPoint = Vector2.new(0.5,0.5),
              Position    = UDim2.new(0, mx, 0, my),
              Size        = UDim2.new(0, ln+1, 0, glH),
              Rotation    = ag,
              BackgroundColor3       = _GLOW_COL,
              BackgroundTransparency = glA,
              BorderSizePixel = 0, ZIndex = 11
          }, lineContainer)
          table.insert(_silhDotRefs, {f = gl, base = glA})
          local coreA = isLeft and (0.50 + math.random()*0.35) or (0.10 + math.random()*0.22)
          local coreH = math.max(1, _LINE_THICK - (isLeft and 1 or 0))
          local sg_ = mk("Frame", {
              AnchorPoint = Vector2.new(0.5,0.5),
              Position    = UDim2.new(0, mx + (math.random()-0.5)*(isLeft and 1.8 or 0.4),
                                         0, my + (math.random()-0.5)*(isLeft and 1.8 or 0.4)),
              Size        = UDim2.new(0, ln + (math.random()-0.5)*2, 0, coreH),
              Rotation    = ag + (math.random()-0.5)*(isLeft and 1.5 or 0.2),
              BackgroundColor3       = _LINE_COL,
              BackgroundTransparency = coreA,
              BorderSizePixel = 0, ZIndex = 12
          }, lineContainer)
          table.insert(_silhDotRefs, {f = sg_, base = coreA})
          local scChance = isLeft and 0.88 or 0.35
          local scCount  = isLeft and math.random(3,7) or math.random(1,2)
          local spread   = isLeft and 30 or 12
          if math.random() < scChance then
              for _ = 1, scCount do
                  local spTr = isLeft and (0.08 + math.random()*0.30) or (0.30 + math.random()*0.42)
                  local spSz = isLeft and math.random(1,4) or math.random(1,2)
                  local sp   = mk("Frame", {
                      AnchorPoint = Vector2.new(0.5,0.5),
                      Position    = UDim2.new(0, mx + (math.random()-0.5)*spread,
                                                 0, my + (math.random()-0.5)*spread),
                      Size        = UDim2.new(0, spSz, 0, spSz),
                      BackgroundColor3       = _PCOLS[math.random(1,#_PCOLS)],
                      BackgroundTransparency = spTr,
                      BorderSizePixel = 0, ZIndex = 11
                  }, lineContainer)
                  local crsp = Instance.new("UICorner"); crsp.CornerRadius = UDim.new(0.5,0); crsp.Parent = sp
                  table.insert(_silhDotRefs, {f = sp, base = spTr})
              end
          end
          if math.random() < 0.08 then
              task.spawn(function()
                  while sg_ and sg_.Parent and not _slidingAway do
                      task.wait(1.8 + math.random()*3.5)
                      if not (sg_ and sg_.Parent and not _slidingAway) then break end
                      TweenService:Create(sg_, TweenInfo.new(0.06), {BackgroundTransparency=0.90}):Play()
                      task.wait(0.10)
                      if not (sg_ and sg_.Parent and not _slidingAway) then break end
                      TweenService:Create(sg_, TweenInfo.new(0.20), {BackgroundTransparency=coreA}):Play()
                  end
              end)
          end
      end

      local function spawnParticle(px, py)
          local angle  = math.random() * math.pi * 2
          local speed  = 60 + math.random() * 120
          local driftX =  80 + math.cos(angle) * speed
          local driftY = math.sin(angle) * speed * 0.60
          local sz     = math.random(2, 5)
          local col    = _PCOLS[math.random(1,#_PCOLS)]
          local life   = 2.0 + math.random() * 2.0
          local p = mk("Frame", {
              AnchorPoint = Vector2.new(0.5,0.5),
              Position    = UDim2.new(0, px, 0, py),
              Size        = UDim2.new(0, sz, 0, sz),
              BackgroundColor3       = col,
              BackgroundTransparency = 0.15 + math.random()*0.25,
              BorderSizePixel = 0, ZIndex = 14
          }, lineContainer)
          local cr_ = Instance.new("UICorner"); cr_.CornerRadius = UDim.new(0.5,0); cr_.Parent = p
          TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
              Position    = UDim2.new(0, px + driftX, 0, py + driftY),
              BackgroundTransparency = 1,
              Size        = UDim2.new(0, 1, 0, 1),
          }):Play()
          task.delay(life + 0.05, function() pcall(function() p:Destroy() end) end)
      end

      local function spawnTrail(px, py, dissolveAlpha)
          local sizes   = {10, 7, 4}
          local alphas  = {0.10, 0.28, 0.52}
          local cols    = {
              Color3.fromRGB(210, 170, 255),
              Color3.fromRGB(160, 100, 255),
              Color3.fromRGB(110,  55, 220),
          }
          local life = 0.48
          for k = 1, 3 do
              local sz  = sizes[k]  * (1 - dissolveAlpha * 0.5)
              local tr_ = alphas[k] + dissolveAlpha * (1 - alphas[k])
              if tr_ >= 1 then break end
              local td = mk("Frame", {
                  AnchorPoint = Vector2.new(0.5,0.5),
                  Position    = UDim2.new(0, px, 0, py),
                  Size        = UDim2.new(0, sz, 0, sz),
                  BackgroundColor3       = cols[k],
                  BackgroundTransparency = tr_,
                  BorderSizePixel = 0, ZIndex = 13
              }, lineContainer)
              local cr_ = Instance.new("UICorner"); cr_.CornerRadius = UDim.new(0.5,0); cr_.Parent = td
              local fadeDur = life * (1 - 0.2*(k-1))
              TweenService:Create(td, TweenInfo.new(fadeDur, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                  BackgroundTransparency = 1,
                  Size = UDim2.new(0, math.max(1, sz-2), 0, math.max(1, sz-2)),
              }):Play()
              task.delay(fadeDur + 0.05, function() pcall(function() td:Destroy() end) end)
          end
      end

      for _ = 1, 35 do
          local sx   = 0.03 + math.random()*0.55
          local sy   = 0.06 + math.random()*0.88
          local ssz  = math.random(1,3)
          local str_ = 0.42 + math.random()*0.44
          local col_ = math.random()<0.6 and Color3.fromRGB(170,130,255) or Color3.fromRGB(200,180,255)
          local sf = mk("Frame", {
              AnchorPoint = Vector2.new(0.5,0.5),
              Position    = UDim2.new(sx, 0, sy, 0),
              Size        = UDim2.new(0, ssz, 0, ssz),
              BackgroundColor3       = col_,
              BackgroundTransparency = str_,
              BorderSizePixel = 0, ZIndex = 10
          }, lineContainer)
          local cr_ = Instance.new("UICorner"); cr_.CornerRadius = UDim.new(0.5,0); cr_.Parent = sf
          table.insert(_silhDotRefs, {f = sf, base = str_})
      end

      local _segProg      = 0
      local _lastDrawn    = 0
      local _SPEED        = 75
      local _animRun      = not skipCinematic
      local _trailThr     = 0
      local _partThr      = 0
      local _DISS_START   = 0.55
      local _DISS_END     = 0.88
      local _orbGone      = false
      local _trailExtraT  = 0
      local _TRAIL_EXTRA  = 0.30
      local _orbitConn

      _orbitConn = RunService.Heartbeat:Connect(function(dt)
          if not (lineContainer and lineContainer.Parent) then
              _orbitConn:Disconnect(); return
          end
          if not _animRun then return end

          _segProg = _segProg + dt * _SPEED
          local maxP = _N - 1
          if _segProg > maxP then _segProg = maxP end

          local pR = _segProg / maxP

          local curSeg = math.floor(_segProg)
          while _lastDrawn < curSeg do
              _lastDrawn = _lastDrawn + 1
              drawSegment(_lastDrawn)
          end

          local dissA = 0
          if pR >= _DISS_START then
              dissA = math.min((pR - _DISS_START) / (_DISS_END - _DISS_START), 1)
          end
          if dissA >= 1 then _orbGone = true end

          if _orbGone then
              _trailExtraT = _trailExtraT + dt
              if _trailExtraT > _TRAIL_EXTRA then
                  _animRun = false
                  task.delay(1.0, function()
                      if not (lineContainer and lineContainer.Parent) then return end
                      pcall(function() _bloomEff:Destroy() end)
                      for _, dotInfo in ipairs(_silhDotRefs) do
                          if dotInfo.f and dotInfo.f.Parent then
                              local d = math.random() * 1.2
                              task.delay(d, function()
                                  if not (dotInfo.f and dotInfo.f.Parent) then return end
                                  TweenService:Create(dotInfo.f, TweenInfo.new(0.07),
                                      {BackgroundTransparency = 1}):Play()
                                  task.delay(0.10, function()
                                      if not (dotInfo.f and dotInfo.f.Parent) then return end
                                      TweenService:Create(dotInfo.f, TweenInfo.new(0.12),
                                          {BackgroundTransparency = dotInfo.base}):Play()
                                      task.delay(0.15, function()
                                          if not (dotInfo.f and dotInfo.f.Parent) then return end
                                          TweenService:Create(dotInfo.f,
                                              TweenInfo.new(0.9, Enum.EasingStyle.Quart,
                                                            Enum.EasingDirection.Out),
                                              {BackgroundTransparency = 1}):Play()
                                      end)
                                  end)
                              end)
                          end
                      end
                  end)
                  return
              end
          end

          local i1 = curSeg + 1
          local i2 = math.min(curSeg + 2, _N)
          local fr = _segProg - curSeg
          local p1 = CAT_POINTS[i1];  local p2 = CAT_POINTS[i2]
          local bx  = p1[1] + (p2[1]-p1[1]) * fr
          local by_ = p1[2] + (p2[2]-p1[2]) * fr
          local oUDim = UDim2.new(0, bx, 0, by_)

          if not _orbGone then
              local baseCA, baseGA, baseOA, baseBlA, oS
              if pR < 0.04 then
                  local t_ = pR / 0.04
                  baseCA = 1-t_;  baseGA = 1-t_*0.45; baseOA = 1-t_*0.15
                  baseBlA = 1-t_*0.10; oS = 8 + t_*6
              else
                  baseCA = 0.0; baseGA = 0.50; baseOA = 0.82; baseBlA = 0.90; oS = 14
              end
              local function diss(base) return math.min(1, base + dissA*(1-base)) end
              local cA  = diss(baseCA)
              local gA  = diss(baseGA)
              local oA  = diss(baseOA)
              local blA = diss(baseBlA)
              local sz  = math.max(2, oS * (1 - dissA * 0.8))

              orbCore.Position               = oUDim
              orbCore.BackgroundTransparency  = cA
              orbCore.Size                   = UDim2.new(0, sz, 0, sz)
              orbGlow.Position               = oUDim
              orbGlow.BackgroundTransparency  = gA
              orbGlow.Size                   = UDim2.new(0, sz*2, 0, sz*2)
              orbOuter.Position              = oUDim
              orbOuter.BackgroundTransparency = oA
              orbOuter.Size                  = UDim2.new(0, sz*3.6, 0, sz*3.6)
              orbBloom.Position              = oUDim
              orbBloom.BackgroundTransparency = blA
              orbBloom.Size                  = UDim2.new(0, sz*6.5, 0, sz*6.5)
          else
              orbCore.BackgroundTransparency  = 1
              orbGlow.BackgroundTransparency  = 1
              orbOuter.BackgroundTransparency = 1
              orbBloom.BackgroundTransparency = 1
          end

          _trailThr = _trailThr + dt
          if _trailThr >= 0.028 then
              _trailThr = 0
              spawnTrail(bx, by_, dissA)
          end

          if not _orbGone then
              _partThr = _partThr + dt
              if _partThr >= 0.045 then
                  _partThr = 0
                  local nParts = math.random(1, 3)
                  for _ = 1, nParts do spawnParticle(bx, by_) end
              end
          end
      end)

    local _bgParticles = {}
    local _bgParticleCount = 18
    for i = 1, _bgParticleCount do
        local sz = math.random(1, 3)
        local p = mk("Frame", {
            Name = "BgParticle",
            AnchorPoint = Vector2.new(0.5,0.5),
            Size = UDim2.new(0, sz, 0, sz),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = 4
        }, sg)
        local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0.5, 0); cr.Parent = p
        local startX = math.random(5, 80) / 100
        local startY = math.random(5, 95) / 100
        p.Position = UDim2.new(startX, 0, startY, 0)
        table.insert(_bgParticles, {
            frame = p,
            dx = math.random(-15, 15),
            dy = math.random(-25, -5),
            life = math.random(4, 10),
            maxAlpha = math.random(15, 45) / 100,
            blinkSpeed = math.random(2, 5) / 10,
            phase = math.random(0, 628) / 100,
            active = true
        })
    end
    RunService.Heartbeat:Connect(function(dt)
        if not sg or not sg.Parent then return end
        for _, pt in ipairs(_bgParticles) do
            if not pt.active then continue end
            local p = pt.frame
            if not p.Parent then continue end
            local pos = p.Position
            p.Position = UDim2.new(
                pos.X.Scale + pt.dx * dt / 100, 0,
                pos.Y.Scale + pt.dy * dt / 100, 0
            )
            local t = os.clock()
            local blink = math.sin(t * pt.blinkSpeed * 10 + pt.phase)
            local alpha = pt.maxAlpha * (0.5 + blink * 0.5)
            p.BackgroundTransparency = alpha
            if pos.Y.Scale < -0.05 or pos.X.Scale < -0.05 or pos.X.Scale > 1.05 then
                pt.active = false
                p.BackgroundTransparency = 1
                task.delay(math.random(2, 6), function()
                    if not p or not p.Parent then return end
                    p.Position = UDim2.new(math.random(5, 90)/100, 0, math.random(95, 105)/100, 0)
                    pt.active = true
                end)
            end
        end
    end)

    if not skipCinematic then task.delay(6.5, function()
        _slidingAway = true
        _animRun     = false
        ease(byLabel, 1.2, {TextTransparency = 1})
        ease(orbCore,  0.5, {BackgroundTransparency = 1})
        ease(orbGlow,  0.5, {BackgroundTransparency = 1})
        ease(orbOuter, 0.5, {BackgroundTransparency = 1})
        for _, dotInfo in ipairs(_silhDotRefs) do
            if dotInfo.f and dotInfo.f.Parent then
                local d = math.random()*0.6
                task.delay(d, function()
                    if dotInfo.f and dotInfo.f.Parent then
                        TweenService:Create(dotInfo.f,
                            TweenInfo.new(1.0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                            {BackgroundTransparency = 1}
                        ):Play()
                    end
                end)
            end
        end
        ease(phaseOverlay, 1.4, {BackgroundTransparency = 1})
        task.delay(2.5, function()
            pcall(function() phaseOverlay:Destroy() end)
            pcall(function() lineContainer:Destroy() end)
        end)
    end)
    end

    local leftPanel = mk("Frame", {Name = "LeftPanel",
        AnchorPoint = Vector2.new(0,0),
        Position = UDim2.new(0,23,0,48),
        Size = UDim2.new(0,250,1,-100),
        BackgroundColor3 = Color3.fromRGB(12,14,26),
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 5}, sg)
    corner(leftPanel, 18)
    stroke(leftPanel, 0.6, Color3.fromRGB(192,192,192), 1)
    if skipCinematic then
        if perfBackdrop then perfBackdrop.ImageTransparency = 0.12 end
        leftPanel.BackgroundTransparency = 0.5
    else
        task.delay(revealDelay, function()
            if perfBackdrop then ease(perfBackdrop, 1.2, {ImageTransparency = 0.12}) end
            ease(leftPanel, 0.6, {BackgroundTransparency = 0.5})
        end)
    end
    local perfAvatar = mk("ImageLabel", {Name = "PerfAvatar",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,21),
        Size = UDim2.new(0,69,0,69),
        BackgroundColor3 = Color3.fromRGB(22,25,38),
        BorderSizePixel = 0, Image = "", ScaleType = Enum.ScaleType.Crop,
        BackgroundTransparency = 0, ZIndex = 6}, leftPanel)
    corner(perfAvatar, 28)
    pcall(function()
        local u = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        if u and u ~= "" then perfAvatar.Image = u end
    end)
    if skipCinematic then
        perfAvatar.BackgroundTransparency = 0
    else
        task.delay(revealDelay, function() ease(perfAvatar, 0.5, {BackgroundTransparency = 0}) end)
    end
    local perfDisplay = mk("TextButton", {Name = "PerfDisplay",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,105),
        Size = UDim2.new(1,-16,0,22),
        BackgroundTransparency = 1,
        Text = LP.DisplayName, Font = F_BOLD, TextSize = 14,
        TextColor3 = Color3.fromRGB(255,255,255), TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6,
        AutoButtonColor = false, BorderSizePixel = 0}, leftPanel)
    local perfHandle = mk("TextLabel", {Name = "PerfHandle",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,124),
        Size = UDim2.new(1,-16,0,16),
        BackgroundTransparency = 1,
        Text = "@" .. LP.Name, Font = F_REG, TextSize = 11,
        TextColor3 = Color3.fromRGB(160,160,180), TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6}, leftPanel)
    local hideBtn = mk("TextButton", {Name = "HideBtn",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,149),
        Size = UDim2.new(1,-24,0,24),
        BackgroundColor3 = C.VeryLight,
        BackgroundTransparency = 0,
        BorderSizePixel = 0, Text = "🔒  Hide Username",
        Font = F_MED, TextSize = 11,
        TextColor3 = Color3.fromRGB(165,165,200),
        TextTransparency = 1,
        AutoButtonColor = false, ZIndex = 6}, leftPanel)
    corner(hideBtn, 12)
    if skipCinematic then
        perfDisplay.TextTransparency = 0
        perfHandle.TextTransparency = 0
        hideBtn.TextTransparency = 0
    else
        task.delay(revealDelay, function()
            ease(perfDisplay, 0.5, {TextTransparency = 0})
            ease(perfHandle, 0.5, {TextTransparency = 0})
            ease(hideBtn, 0.5, {TextTransparency = 0})
        end)
    end
    local _handleHiddenByBtn = false
    local _displayMasked = false
    local function dotsFor(str)
        local n = utf8.len(str) or #str
        return string.rep("•", n)
    end
    local function refreshProfileLabels()
        if _displayMasked then
            perfDisplay.Text = dotsFor(LP.DisplayName)
            perfDisplay.TextColor3 = Color3.fromRGB(110, 115, 140)
        else
            perfDisplay.Text = LP.DisplayName
            perfDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        if _handleHiddenByBtn then
            perfHandle.Text = dotsFor(LP.Name)
            hideBtn.Text = "🔓  Show Username"
        else
            perfHandle.Text = "@" .. LP.Name
            hideBtn.Text = "🔒  Hide Username"
        end
    end
    perfHandle.Active = false
    hideBtn.MouseButton1Click:Connect(function()
        _handleHiddenByBtn = not _handleHiddenByBtn
        refreshProfileLabels()
    end)
    perfDisplay.MouseButton1Click:Connect(function()
        _displayMasked = not _displayMasked
        refreshProfileLabels()
    end)
    refreshProfileLabels()
    local sep = mk("Frame", {Name = "Sep",
        Position = UDim2.new(0,12,0,185),
        Size = UDim2.new(1,-24,0,1),
        BackgroundColor3 = Color3.fromRGB(50,52,70),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0, ZIndex = 6}, leftPanel)
    local statDefs = {
        {name="Rounds",     key="perfRounds",    y=195, icon="rbxassetid://128365903433055"},
        {name="Wisps",      key="perfWisps",     y=223, icon="rbxassetid://139834822754994"},
        {name="Skips",      key="perfSkips",     y=251, icon="rbxassetid://79386007555350"},
        {name="Downed",     key="perfDowned",    y=279, icon="rbxassetid://134858476610128"},
        {name="Round Time", key="perfRoundTime", y=307, icon="rbxassetid://128970009745093"},
        {name="Total Time", key="perfTotalTime", y=333, icon="rbxassetid://130470294225953"},
    }

    local statsBgFrame = mk("Frame", {
        Name = "StatsBgFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4}, leftPanel)
mk("ImageLabel", {Name = "StatsBg",Size = UDim2.new(1, 0, 1, 0),BackgroundTransparency = 1,
Image = "rbxassetid://89130962236709",ImageTransparency = 1,ScaleType = Enum.ScaleType.Crop,ZIndex = 5}, statsBgFrame)
    local perfStatLabels = {}
    for _, sd2 in ipairs(statDefs) do
        local row = mk("Frame", {
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.new(0,12,0,sd2.y),
            Size = UDim2.new(1,-24,0,22),
            BackgroundTransparency = 1, ZIndex = 6}, leftPanel)
        mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0,8), VerticalAlignment = Enum.VerticalAlignment.Center}, row)
        mk("ImageLabel", {
            Size = UDim2.new(0,16,0,16),
            BackgroundTransparency = 1,
            Image = sd2.icon,
            ImageColor3 = Color3.fromRGB(255,255,255),
            ImageTransparency = 0.4,
            ScaleType = Enum.ScaleType.Fit, ZIndex = 6}, row)
        mk("TextLabel", {
            Size = UDim2.new(0,90,1,0),
            BackgroundTransparency = 1,
            Text = sd2.name, Font = F_MED, TextSize = 11,
            TextColor3 = Color3.fromRGB(140,140,165), TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, row)
        local val = mk("TextLabel", {
            Size = UDim2.new(1,-114,1,0),
            BackgroundTransparency = 1,
            Text = "0", Font = F_BOLD, TextSize = 13,
            TextColor3 = Color3.fromRGB(255,255,255), TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6}, row)
        perfStatLabels[sd2.key] = val
    end
    if skipCinematic then
        for _, lbl in pairs(perfStatLabels) do
            lbl.TextTransparency = 0
        end
        for _, child in ipairs(leftPanel:GetDescendants()) do
            if child:IsA("TextLabel") then
                child.TextTransparency = 0
            end
        end
    else
        task.delay(revealDelay, function()
            for _, lbl in pairs(perfStatLabels) do
                ease(lbl, 0.5, {TextTransparency = 0})
            end
            for _, child in ipairs(leftPanel:GetDescendants()) do
                if child:IsA("TextLabel") then
                    ease(child, 0.5, {TextTransparency = 0})
                end
            end
        end)
    end
    local function updatePerfStats()
        if perfStatLabels["perfRounds"]  then perfStatLabels["perfRounds"].Text  = tostring(GAME_STATS.rounds)  end
    if perfStatLabels["perfWisps"] then perfStatLabels["perfWisps"].Text = tostring(GAME_STATS.wisps) end
        if perfStatLabels["perfSkips"]   then perfStatLabels["perfSkips"].Text   = tostring(GAME_STATS.skips)   end
        if perfStatLabels["perfDowned"]  then perfStatLabels["perfDowned"].Text  = tostring(GAME_STATS.downed)  end
        if perfStatLabels["perfRoundTime"] then
            if _perfRoundTimerConn then
            elseif GAME_STATS.roundTime and GAME_STATS.roundTime > 0 then
                perfStatLabels["perfRoundTime"].Text = formatTime(GAME_STATS.roundTime)
            else
                perfStatLabels["perfRoundTime"].Text = "–:––"
            end
        end
        if perfStatLabels["perfTotalTime"] then
            local elapsed = _perfTotalElapsed
            if _perfModeStartTime then
                elapsed = elapsed + math.max(0, os.clock() - _perfModeStartTime)
            end
            local tot = math.floor(elapsed)
            GAME_STATS.totalTime = tot
            perfStatLabels["perfTotalTime"].Text = formatTime(tot)
        end
    end
    RunService.Heartbeat:Connect(function()
        if perfModeActive then updatePerfStats() end
    end)
    local rightPanel = mk("Frame", {Name = "RightPanel",
        AnchorPoint = Vector2.new(0,0),
        Position = UDim2.new(0,300,0,48),
        Size = UDim2.new(1,-999,0,650),
        BackgroundColor3 = Color3.fromRGB(12,14,26),
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 5}, sg)
    corner(rightPanel, 12)
    stroke(rightPanel, 0.6, Color3.fromRGB(192,192,192), 1)
    if skipCinematic then
        rightPanel.BackgroundTransparency = 0.5
    else
        task.delay(revealDelay + quickReveal, function() ease(rightPanel, 0.3, {BackgroundTransparency = 0.5}) end)
    end
    mk("TextLabel", {Name = "ConsoleHeader",
        Position = UDim2.new(0,14,0,10),
        Size = UDim2.new(1,-28,0,18),
        BackgroundTransparency = 1,
        Text = "SOUL LITE  //  PERFORMANCE TERMINAL",
        Font = F_CODE, TextSize = 12,
        TextColor3 = Color3.fromRGB(215,220,235), TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, rightPanel)
    local consoleSep = mk("Frame", {Name = "ConSep",
        Position = UDim2.new(0,10,0,32),
        Size = UDim2.new(1,-20,0,1),
        BackgroundColor3 = Color3.fromRGB(60,70,100),
        BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 6}, rightPanel)
    if skipCinematic then
        for _, ch in ipairs(rightPanel:GetDescendants()) do
            if ch:IsA("TextLabel") or ch:IsA("TextButton") then
                ch.TextTransparency = 0
            end
        end
    else
        task.delay(revealDelay, function()
            for _, ch in ipairs(rightPanel:GetDescendants()) do
                if ch:IsA("TextLabel") or ch:IsA("TextButton") then
                    ease(ch, 0.5, {TextTransparency = 0})
                end
            end
        end)
    end
    local conView = mk("Frame", {Name = "ConView",
        Position = UDim2.new(0,10,0,40),
        Size = UDim2.new(1,-20,1,-50),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 7}, rightPanel)
    local conMover = mk("Frame", {Name = "ConMover",
        Size = UDim2.new(1,0,0,0),
        BackgroundTransparency = 1, ZIndex = 7}, conView)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0,3),
        VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder}, conMover)
    local PERF_MAXLINES = 60
    local perfLineOrder = 0
    local PERF_LINE_H = 18
    _perfLogFn = function(msg, kind)
        task.spawn(function()
            perfLineOrder = perfLineOrder + 1
            local line = mk("Frame", {Name = "PLine", LayoutOrder = -perfLineOrder,
                Size = UDim2.new(1,0,0,PERF_LINE_H), BackgroundTransparency = 1}, conMover)
            mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0,6), VerticalAlignment = Enum.VerticalAlignment.Center}, line)
            mk("TextLabel", {Name = "B", Size = UDim2.new(1,-74,1,0),
                BackgroundTransparency = 1, Text = msg, Font = F_CODE, TextSize = 11,
                TextColor3 = Color3.fromRGB(200,210,220), TextTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd}, line)
            mk("TextLabel", {Name = "T", Size = UDim2.new(0,68,1,0), BackgroundTransparency = 1,
                Text = os.date("[%H:%M:%S]"), Font = F_CODE, TextSize = 11,
                TextColor3 = Color3.fromRGB(200,210,220), TextTransparency = 0.25,
                TextXAlignment = Enum.TextXAlignment.Right}, line)
            local body = line:FindFirstChild("B")
            if body then ease(body, 0.3, {TextTransparency = 0.05}) end
            local lines = {}
            for _, l in ipairs(conMover:GetChildren()) do if l:IsA("Frame") then table.insert(lines, l) end end
            table.sort(lines, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
            while #lines > PERF_MAXLINES do lines[#lines]:Destroy(); table.remove(lines) end
            local n = #conMover:GetChildren() - 1
            local contentH = math.max(n,0) * (PERF_LINE_H + 3)
            conMover.Size = UDim2.new(1,0,0,contentH)
            local viewH = conView.AbsoluteSize.Y
            if contentH > viewH then
                conMover.Position = UDim2.new(0,0,0,-(contentH - viewH))
            end
        end)
    end
    local logPanel = mk("Frame", {Name = "LogPanel",
        AnchorPoint = Vector2.new(0,0),
        Position = UDim2.new(0,300,0,727),
        Size = UDim2.new(1,-999,1,-830),
        BackgroundColor3 = Color3.fromRGB(12,14,26),
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 5}, sg)
    corner(logPanel, 12)
    stroke(logPanel, 0.6, Color3.fromRGB(192,192,192), 1)
    if skipCinematic then
        logPanel.BackgroundTransparency = 0.5
    else
        task.delay(revealDelay + quickLog, function() ease(logPanel, 0.3, {BackgroundTransparency = 0.5}) end)
    end
    local logMover = mk("Frame", {Name = "LogMover",
        Position = UDim2.new(0,12,0,12),
        Size = UDim2.new(1,-24,1,-16),
        BackgroundTransparency = 1, ZIndex = 6}, logPanel)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}, logMover)

    local initLines = {
        {t="[OK] Initializing core systems...",   c=Color3.fromRGB(200,210,220), d=0.0},
        {t="[OK] Loading map: Workfacility",       c=Color3.fromRGB(200,210,220), d=0.08},
        {t="[OK] Spawning environment...",         c=Color3.fromRGB(200,210,220), d=0.16},
        {t="[OK] Loading assets (94%)...",         c=Color3.fromRGB(200,210,220), d=0.24},
        {t="[OK] Compiling shaders...",            c=Color3.fromRGB(200,210,220), d=0.32},
        {t=">  Finalizing setup...",               c=Color3.fromRGB(200,210,220), d=0.40},
        {t="    Waiting for player...",            c=Color3.fromRGB(160,170,185), d=0.48},
        {t="    Synchronizing data...",            c=Color3.fromRGB(160,170,185), d=0.56},
        {t="    Almost ready...",                  c=Color3.fromRGB(160,170,185), d=0.64},
    }
    for i, line in ipairs(initLines) do
        local lbl = mk("TextLabel", {Name = "L"..i, LayoutOrder = i,
            Size = UDim2.new(1,0,0,18),
            BackgroundTransparency = 1,
            Text = line.t,
            Font = F_CODE, TextSize = 11,
            TextColor3 = line.c, TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7}, logMover)
        task.delay(revealDelay + 0.6 + line.d, function()
            ease(lbl, 0.4, {TextTransparency = 0.05})
        end)
    end
    _perfRoundTimerConn = nil
    local function subscribeRoundTimer()
        if _perfRoundTimerConn then
            pcall(function() _perfRoundTimerConn:Disconnect() end)
            _perfRoundTimerConn = nil
        end
        local ok, timerLbl = pcall(function()
            return LP.PlayerGui.Game.HUD.Overlay.RoundOverlay.RoundTimer.IngameRoundTimer.Timer
        end)
        if ok and timerLbl and timerLbl:IsA("TextLabel") then
            if perfStatLabels["perfRoundTime"] then
                perfStatLabels["perfRoundTime"].Text = timerLbl.Text
            end
            GAME_STATS.roundTime = parseTime(timerLbl.Text)
            _perfRoundTimerConn = timerLbl:GetPropertyChangedSignal("Text"):Connect(function()
                if perfModeActive and perfStatLabels["perfRoundTime"] then
                    perfStatLabels["perfRoundTime"].Text = timerLbl.Text
                end
                GAME_STATS.roundTime = parseTime(timerLbl.Text)
            end)
        end
    end
    subscribeRoundTimer()
    local _rtRetryThrottle = 0
    RunService.Heartbeat:Connect(function()
        if not perfModeActive then return end
        if _perfRoundTimerConn then return end
        local now = os.clock()
        if now - _rtRetryThrottle < 3 then return end
        _rtRetryThrottle = now
        subscribeRoundTimer()
    end)

    local returnBtn = mk("TextButton", {Name = "ReturnBtn",
        AnchorPoint = Vector2.new(0.5,1),
        Position = UDim2.new(0.5,0,1,-14),
        Size = UDim2.new(1,-24,0,40),
        BackgroundColor3 = Color3.fromRGB(25,28,48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "← Return to Game",
        Font = F_SEMI, TextSize = 13,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextTransparency = 1,
        AutoButtonColor = false, ZIndex = 8}, leftPanel)
    corner(returnBtn, 12)
    stroke(returnBtn, 0, Color3.fromRGB(60,65,90), 1.2)
    shadow(returnBtn, 20, 0.8, 6, Color3.fromRGB(0,0,0))
    task.delay(revealDelay, function()
        ease(returnBtn, 0.6, {BackgroundTransparency = 0.35, TextTransparency = 0})
    end)
    bg.Active = true
    returnBtn.MouseEnter:Connect(function()
        ease(returnBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(40,45,70)})
    end)
    returnBtn.MouseLeave:Connect(function()
        ease(returnBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(25,28,48)})
    end)
    returnBtn.MouseButton1Click:Connect(function()
        if not perfModeActive then return end
        if transitionBusy then return end
        transitionBusy = true
        task.spawn(function()
            local restoreOverlay = mk("Frame", {Name = "RestoreOverlay",
                Size = UDim2.new(1,0,1,0),
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0, ZIndex = 100}, _perfScreenGui)
            local restLines = {"Preparing game...", "Restoring graphics...",
                               "Restoring effects...", "Restoring interface..."}
            local rLineY = UDim2.new(0.5,0,0.45,0)
            for i, txt in ipairs(restLines) do
                local lbl = mk("TextLabel", {
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = rLineY,
                    Size = UDim2.new(0,400,0,28),
                    BackgroundTransparency = 1,
                    Text = txt, Font = F_CODE, TextSize = 18,
                    TextColor3 = Color3.fromRGB(200,220,200),
                    TextTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 101}, restoreOverlay)
                ease(lbl, 0.4, {TextTransparency = 0})
                task.wait(0.9)
                ease(lbl, 0.3, {TextTransparency = 1})
                task.wait(0.35)
                rLineY = UDim2.new(0.5,0,0.45,0)
            end
            task.wait(0.3)
            restoreWorldClutter()
            removeBlur()
            ease(restoreOverlay, 0.3, {BackgroundTransparency = 1})
            task.wait(0.15)
            MainWindow.Visible = true
            _guiShown = true
            ease(MainWindow, 0.4, {BackgroundTransparency = 0})
            task.wait(0.3)
            pcall(function()
                if _perfScreenGui then _perfScreenGui:Destroy() end
                _perfScreenGui = nil
            end)
            if _perfModeStartTime then
                _perfTotalElapsed = _perfTotalElapsed + math.max(0, os.clock() - _perfModeStartTime)
                _perfModeStartTime = nil
            end
            perfModeActive = false
            perfModeBlocking = false
            transitionBusy = false
            _perfLogFn = nil
            _returnPerfMode = true
        end)
    end)
end

local runCinematicIntro
local function activatePerfMode()
    transitionBusy = true
    perfModeBlocking = true
    pcall(removeWorldClutter)
    _perfModeStartTime = nil
    MainWindow.Visible = true
    local blurObj = applyBlur(28)
    task.wait(0.5)
    local loadSg = mk("ScreenGui", {Name = "SoulPerfLoad", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
        DisplayOrder = 2147483645}, PG)
    local loadBg = mk("Frame", {Name = "Bg", Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 1}, loadSg)
    task.wait(0.55)
    local waitLbl = mk("TextLabel", {Name = "WaitLabel",
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0.28,0),
        Size = UDim2.new(0,300,0,50),
        BackgroundTransparency = 1,
        Text = "Wait...", Font = F_BOLD, TextSize = 36,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5}, loadSg)
    ease(waitLbl, 0.5, {TextTransparency = 0})
    task.wait(0.5)
local conHolder = mk("Frame", {Name = "ConHolder",AnchorPoint = Vector2.new(0.5,0),Position = UDim2.new(0.5,0,0.42,0),Size = UDim2.new(0,530,0,400),BackgroundColor3 = Color3.fromRGB(8,10,14),BackgroundTransparency = 0.08, BorderSizePixel = 0, ZIndex = 5}, loadSg)
    corner(conHolder, 14)
    stroke(conHolder, 0.25, Color3.fromRGB(65,75,80), 1)
    shadow(conHolder, 28, 0.72, 8, Color3.fromRGB(0,0,0))
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, conHolder)
    local loadLines = {
        "Removing unnecessary visual effects...",
        "Disabling particles...",
        "Disabling shadows...",
        "Disabling post-processing...",
        "Disabling cosmetic map decorations...",
        "Optimizing rendering...",
        "Optimizing Workspace...",
        "Optimizing graphics...",
        "Preparing farm...",
        "Loading Performance Mode...",
    }
    local lineLabels = {}
    for i, txt in ipairs(loadLines) do
        local lbl = mk("TextLabel", {Name = "L"..i, LayoutOrder = i,
            Size = UDim2.new(1,0,0,22),
            BackgroundTransparency = 1,
            Text = ((i <= 5) and "[OK] " or "> ") .. txt,
            Font = F_CODE, TextSize = 13,
            TextColor3 = Color3.fromRGB(160,200,160),
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, conHolder)
        lineLabels[i] = lbl
        ease(lbl, 0.4, {TextTransparency = 0.1})
        if i == 3 then
            pcall(function() Lighting.GlobalShadows = false end)
        end
        task.wait(0.38)
    end
    task.wait(0.5)
    ease(waitLbl, 0.4, {TextTransparency = 1})
    task.wait(0.3)
    removeBlur()
    task.wait(0.15)
    MainWindow.Visible = false
    local cinematicOverlay = runCinematicIntro(loadSg, loadBg)
    buildPerfScreen(true)
    ease(cinematicOverlay, 0.85, {BackgroundTransparency = 1})
    ease(loadBg, 0.85, {BackgroundTransparency = 1})
    task.wait(0.9)
    if cinematicOverlay and cinematicOverlay.Parent then
        cinematicOverlay.Active = false
        cinematicOverlay.Visible = false
    end
    if loadBg and loadBg.Parent then
        loadBg.Active = false
    end
    if loadSg and loadSg.Parent then
        pcall(function() loadSg:Destroy() end)
    end
    _perfModeStartTime = os.clock()
    perfModeActive = true
    transitionBusy = false
    if _perfLogFn then _perfLogFn("Performance Mode active", "good") end
end

local function captureFade(root, t)
    t = t or {}
    local function g(o)
        local r = {}
        if o:IsA("GuiObject") then r.bg = o.BackgroundTransparency end
        if o:IsA("TextLabel") or o:IsA("TextBox") or o:IsA("TextButton") then r.tx = o.TextTransparency end
        if o:IsA("ImageLabel") or o:IsA("ImageButton") then r.im = o.ImageTransparency end
        if o:IsA("UIStroke") then r.st = o.Transparency end
        if o:IsA("UIShadow") then r.sh = o.Transparency end
        t[o] = r
    end
    g(root)
    for _, d in ipairs(root:GetDescendants()) do g(d) end
    return t
end
local function fadeGui(hide)
    if _fading then return end
    _fading = true
    _fadeSeq = _fadeSeq + 1
    local mySeq = _fadeSeq
    if not _fadeBase then _fadeBase = captureFade(MainWindow) end
    if not hide then MainWindow.Visible = true end
    local last
    for o, b in pairs(_fadeBase) do
        local p = {}
        if hide then
            if b.bg then p.BackgroundTransparency = 1 end
            if b.tx then p.TextTransparency = 1 end
            if b.im then p.ImageTransparency = 1 end
            if b.st then p.Transparency = 1 end
            if b.sh then p.Transparency = 1 end
        else
            if b.bg then p.BackgroundTransparency = b.bg end
            if b.tx then p.TextTransparency = b.tx end
            if b.im then p.ImageTransparency = b.im end
            if b.st then p.Transparency = b.st end
            if b.sh then p.Transparency = b.sh end
        end
        if next(p) then
            local ok, tr = pcall(TweenService.Create, TweenService, o, TweenInfo.new(FADE_DUR, QU, Enum.EasingDirection.Out), p)
            if ok then tr:Play(); last = tr end
        end
    end
    task.delay(0.1, function() if _fadeSeq == mySeq then _fading = false end end)
    if hide then
        local function doHide()
            if _fadeSeq == mySeq then MainWindow.Visible = false end
        end
        if last then last.Completed:Connect(doHide) end
        task.delay(FADE_DUR + 0.05, doHide)
    end
end
local function buildGlass()
    local glass = mk("Frame", {Name = "AutoFarmGlass", Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(0, LEFT_STRIP - 24, 1, -80), BackgroundColor3 = GLASS.Bg,
        BackgroundTransparency = GLASS.BgTransparency, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 1}, ScaleFrame)
    corner(glass, 32)
    stroke(glass, GLASS.StrokeTransparency, GLASS.Stroke, 1)
    shadow(glass, 34, GLASS.ShadowTransparency, 8, GLASS.Shadow)
    autoRedShadow = mk("Frame", {Name = "RedShadow", Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = C.BlueAccent, BackgroundTransparency = 0.94,
        BorderSizePixel = 0, ZIndex = 1}, glass)
    corner(autoRedShadow, 32)
    local hi = mk("Frame", {Name = "InnerLight", Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = GLASS.InnerLight, BackgroundTransparency = GLASS.InnerLightTransparency,
        BorderSizePixel = 0, ZIndex = 2}, glass)
    corner(hi, 32)
    mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}, hi)
    local af = mk("TextLabel", {Name = "AutoFarmDecor", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 720, 0, 120),
        BackgroundTransparency = 1, Text = "AUTO  FARM", Font = F_BOLD, TextSize = 104,
        TextColor3 = GLASS.Text, TextTransparency = GLASS.TextTransparency,
        Rotation = -90, ZIndex = 3}, glass)
    autoGrad = mk("UIGradient", {Rotation = 90, Color = seq3(C.Deep, GLASS.Text, C.VeryLight)}, af)
end
local function buildContent()
    ContentPanel = mk("Frame", {Name = "ContentPanel", Position = UDim2.new(0, CP_X, 0, CP_Y),
        Size = UDim2.new(0, CP_W, 0, CP_H), BackgroundColor3 = C.Card, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 2}, ScaleFrame)
    corner(ContentPanel, 30); shadow(ContentPanel, 50, 0.9, 8, C.Shadow)
    ContentPanel.BackgroundColor3 = C.Card
    BgGlow = mk("Frame", {Name = "BgGlow", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.Deep,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1}, ContentPanel)
    mk("UIGradient", {Rotation = 135, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 1.0), NumberSequenceKeypoint.new(0.62, 1.0),
        NumberSequenceKeypoint.new(1.0, 0.55)})}, BgGlow)
    Toast = mk("TextLabel", {Name = "Toast", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 96), Size = UDim2.new(0, 220, 0, 34),
        BackgroundColor3 = C.Text, BackgroundTransparency = 1, Text = "", Font = F_MED,
        TextSize = 13, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center, TextTransparency = 1, ZIndex = 30}, ContentPanel)
    corner(Toast, 12); shadow(Toast, 20, 0.6, 4, C.Shadow)
    DragZone = mk("Frame", {Name = "DragZone", Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, BAN_Y - 6), BackgroundColor3 = C.Card,
        BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 2}, ContentPanel)
    corner(DragZone, 30)
end
local function buildHeader()
    local Header = mk("Frame", {Name = "Header", Position = UDim2.new(0, PAD, 0, 26),
        Size = UDim2.new(1, -PAD*2, 0, HEADER_H), BackgroundTransparency = 1, ZIndex = 3}, ContentPanel)
    local HeaderLeft = mk("Frame", {Name = "HeaderLeft", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 3}, Header)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 22), SortOrder = Enum.SortOrder.LayoutOrder}, HeaderLeft)
    local AvatarAndName = mk("Frame", {Name = "AvatarAndName", LayoutOrder = 1,
        Size = UDim2.new(0, 64+12+180, 0, 64), BackgroundTransparency = 1}, HeaderLeft)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}, AvatarAndName)
    Avatar = mk("ImageLabel", {Name = "Avatar", LayoutOrder = 1, Size = UDim2.new(0, 64, 0, 64),
	BackgroundColor3 = C.Blue, BorderSizePixel = 0, Image = "", ScaleType = Enum.ScaleType.Crop, ZIndex = 3}, AvatarAndName)
    corner(Avatar, 32); shadow(Avatar, 14, 0.8, 4, C.Shadow)
    pcall(function()
        local u = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        if u and u ~= "" then Avatar.Image = u end
    end)
    local UsernameBlock = mk("Frame", {Name = "UsernameBlock", LayoutOrder = 2,
        Size = UDim2.new(0, 180, 0, 46), BackgroundTransparency = 1}, AvatarAndName)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, UsernameBlock)
    mk("TextLabel", {Name = "DisplayName", LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1, Text = LP.DisplayName, Font = F_BOLD, TextSize = 24,
        TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left}, UsernameBlock)
    Handle = mk("TextLabel", {Name = "Handle", LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1, Text = "@" .. LP.Name, Font = F_REG, TextSize = 15,
        TextColor3 = C.Text2, TextXAlignment = Enum.TextXAlignment.Left}, UsernameBlock)
    EyeButton = mk("TextButton", {Name = "EyeButton", LayoutOrder = 2, Size = UDim2.new(0, 34, 0, 34),
        BackgroundColor3 = C.HeaderButton, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 4}, HeaderLeft)
    corner(EyeButton, 10)
    eyeIcon = mk("ImageLabel", {Name = "EyeIcon", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1, Image = ICON_OPEN, 	ImageColor3 = C.Blue,
        ScaleType = Enum.ScaleType.Fit, ZIndex = 4}, EyeButton)
    local GithubGroup = mk("Frame", {Name = "GithubGroup", LayoutOrder = 3,
        Size = UDim2.new(0, 22+4+130, 0, 26), BackgroundTransparency = 1, ZIndex = 3}, HeaderLeft)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, GithubGroup)
    local GithubIcon = mk("Frame", {Name = "GithubIcon", LayoutOrder = 1, Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 3}, GithubGroup)
    corner(GithubIcon, 7)
    mk("ImageLabel", {Name = "GithubAsset", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Image = "rbxassetid://98836262038158", ScaleType = Enum.ScaleType.Fit, ZIndex = 3}, GithubIcon)
    GithubBtn = mk("TextButton", {Name = "GithubBtn", LayoutOrder = 2, Size = UDim2.new(0, 130, 0, 24),
        BackgroundTransparency = 1, Text = "by @rgplugg", Font = F_MED, TextSize = 16,
	TextColor3 = C.Blue, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center, AutoButtonColor = false, ZIndex = 4}, GithubGroup)
    GithubBtn.MouseEnter:Connect(function() ease(GithubBtn, 0.18, {TextTransparency = 0.35}) end)
    GithubBtn.MouseLeave:Connect(function() ease(GithubBtn, 0.18, {TextTransparency = 0}) end)
    GithubBtn.MouseButton1Click:Connect(function()
        pcall(function() if setclipboard then setclipboard("https://github.com/rgplugg") end end)
        showToast("Copied GitHub link")
    end)
end
local function buildBanner()
    local oldCard = ContentPanel:FindFirstChild("ImageCard")
    if oldCard then oldCard:Destroy() end
    local ImageCard = mk("Frame", {Name = "ImageCard", Position = UDim2.new(0, PAD, 0, BAN_Y),
        Size = UDim2.new(0, BAN_W, 0, BAN_H), BackgroundColor3 = Color3.fromRGB(14,18,34),
        BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 3}, ContentPanel)
shadow(ImageCard, 50, 0.9, 12, C.Shadow)
ImageContainer = mk("Frame", {Name = "ImageContainer", Size = UDim2.new(1, 0, 1, 0),
BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2}, ImageCard)
    mk("ImageLabel", {Name = "ImageAsset", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Image = "rbxassetid://128212423371160", ScaleType = Enum.ScaleType.Crop, ZIndex = 2}, ImageContainer)
    local VIG = Color3.fromRGB(6,10,24)
local function vig(name, keys, rot)
local f = mk("Frame", {Name = name, Size = UDim2.new(1, 0, 1, 0),
BackgroundColor3 = VIG, BorderSizePixel = 0, ZIndex = 3}, ImageContainer)
mk("UIGradient", {Rotation = rot, Transparency = NumberSequence.new(keys)}, f)
return f
end
vig("VignetteTop", {NumberSequenceKeypoint.new(0,0.45), NumberSequenceKeypoint.new(0.12,1), NumberSequenceKeypoint.new(1,1)}, 90)
vig("VignetteBottom", {NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.88,1), NumberSequenceKeypoint.new(1,0.40)}, 90)
vig("VignetteLeft", {NumberSequenceKeypoint.new(0,0.45), NumberSequenceKeypoint.new(0.04,1), NumberSequenceKeypoint.new(1,1)}, 0)
vig("VignetteRight", {NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.96,1), NumberSequenceKeypoint.new(1,0.45)}, 0)
    local dg = mk("Frame", {Name = "DarkGradient", Size = UDim2.new(1, 0, 1, 0),
BackgroundColor3 = Color3.fromRGB(8,12,28), BorderSizePixel = 0, ZIndex = 4}, ImageContainer)
    mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(1, 0.78)})}, dg)
    local tg = mk("Frame", {Name = "TopGlow", Size = UDim2.new(1, 0, 1, 0),
BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 5}, ImageContainer)
    mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.88), NumberSequenceKeypoint.new(0.3, 1), NumberSequenceKeypoint.new(1, 1)})}, tg)
    if NOISE_ID ~= "" then
        mk("ImageLabel", {Name = "Noise", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Image = "rbxassetid://" .. NOISE_ID, ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.new(0, 256, 0, 256), ImageTransparency = 0.97, ZIndex = 6}, ImageContainer)
    end
end
local function buildSlider()
    local SL_TRACK_H = 200
    local SL_TRACK_Y = (BAN_H - SL_TRACK_H) / 2
    local SliderBox = mk("Frame", {Name = "AvoidSlider", Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1, ZIndex = 7}, ImageContainer)
    mk("TextLabel", {Name = "AvoidLabel", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.new(0, 120, 0, 16),
        BackgroundTransparency = 1, Text = "AVOID  NEXTBOTS", Font = F_MED, TextSize = 11,
        TextColor3 = C.White, TextTransparency = 0.25, Rotation = -90, ZIndex = 7}, SliderBox)
    local function slLab(t, y)
        return mk("TextLabel", {Name = "L_" .. t, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 52, 0, y), Size = UDim2.new(0, 30, 0, 14),
            BackgroundTransparency = 1, Text = t, Font = F_MED, TextSize = 12,
            TextColor3 = C.White, TextTransparency = 0.15,
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 7}, SliderBox)
    end
    slLab("100", SL_TRACK_Y - 12)
    slLab("0", SL_TRACK_Y + SL_TRACK_H + 12)
    local track = mk("Frame", {Name = "Track", Position = UDim2.new(0, 46, 0, SL_TRACK_Y),
        Size = UDim2.new(0, 8, 0, SL_TRACK_H), BackgroundColor3 = C.White,
        BackgroundTransparency = 0.65, BorderSizePixel = 0, ZIndex = 7}, SliderBox)
    corner(track, 4)
    local fill = mk("Frame", {Name = "Fill", AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, 0, 0.5, 0),
	BackgroundColor3 = C.Blue, BorderSizePixel = 0, ZIndex = 7}, track)
    corner(fill, 4)
	fillGradObj = mk("UIGradient", {Rotation = 90, Color = seq2(C.BlueAccent, C.BlueHover)}, fill)
    local thumb = mk("Frame", {Name = "Thumb", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 8}, track)
    corner(thumb, 10)
	thumbStroke = stroke(thumb, 0, C.Blue, 1.5)
	thumbGlow = shadow(thumb, 14, 0.5, 0, C.Blue)
    local thumbBase = thumb.Size
    local function thumbSz(f)
        return UDim2.new(thumbBase.X.Scale*f, thumbBase.X.Offset*f, thumbBase.Y.Scale*f, thumbBase.Y.Offset*f)
    end
    thumb.MouseEnter:Connect(function() ease(thumb, 0.18, {Size = thumbSz(1.18)}) end)
    tip = mk("Frame", {Name = "Tooltip", AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 20, 0.5, 0), Size = UDim2.new(0, 46, 0, 26),
	BackgroundColor3 = C.Blue, BackgroundTransparency = 1, BorderSizePixel = 0,
        Visible = false, ZIndex = 9}, track)
    corner(tip, 8); shadow(tip, 12, 0.6, 2, C.Shadow)
    local tipTxt = mk("TextLabel", {Name = "TipText", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Text = "35", Font = F_BOLD, TextSize = 13,
        TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center}, tip)
    local sliderDragging = false
    local function setFrac(f)
        f = math.clamp(f, 0, 1)
        fill.Size = UDim2.new(1, 0, 1 - f, 0)
        thumb.Position = UDim2.new(0.5, 0, f, 0)
        avoidValue = math.floor((1 - f) * 100)
        tipTxt.Text = tostring(avoidValue)
        tip.Position = UDim2.new(0, 20, f, 0)
    end
    local function showTip() tip.Visible = true; ease(tip, 0.18, {BackgroundTransparency = 0}) end
    local function hideTip()
        local tw = ease(tip, 0.25, {BackgroundTransparency = 1})
        tw.Completed:Connect(function() tip.Visible = false end)
    end
    local function fromY(y) setFrac((y - track.AbsolutePosition.Y) / track.AbsoluteSize.Y) end
    setFrac(0.65)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true; showTip(); fromY(i.Position.Y)
            if setRingRadius then setRingRadius(avoidValue) end
            if showRing then showRing() end
        end
    end)
    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true; showTip()
            if setRingRadius then setRingRadius(avoidValue) end
            if showRing then showRing() end
        end
    end)
    thumb.MouseLeave:Connect(function() if not sliderDragging then ease(thumb, 0.18, {Size = thumbSz(1)}) end end)
    UserInputService.InputChanged:Connect(function(i)
        if sliderDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            fromY(i.Position.Y)
            if setRingRadius then setRingRadius(avoidValue) end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and sliderDragging then
            sliderDragging = false; ease(thumb, 0.18, {Size = thumbSz(1)})
            task.delay(0.4, function() if not sliderDragging then hideTip() end end)
            if hideRing then hideRing() end
        end
    end)
end
local function buildConsole()
    local CON_W, CON_H = math.floor(BAN_W * 0.34), 210
    local Console = mk("Frame", {Name = "Console", Position = UDim2.new(0, 120, 0, 72),
        Size = UDim2.new(0, CON_W, 0, CON_H), BackgroundColor3 = C.Console,
        BackgroundTransparency = 0.45, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 7}, ImageContainer)
    corner(Console, 16); stroke(Console, 0.7, Color3.fromRGB(65,65,65), 1); shadow(Console, 30, 0.7, 6, C.Shadow)
    local cL = mk("Frame", {Name = "InnerLight", Size = UDim2.new(1, 0, 0.4, 0),
        BackgroundColor3 = C.White, BackgroundTransparency = 0.9, BorderSizePixel = 0, ZIndex = 8}, Console)
    corner(cL, 16)
    mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}, cL)
    local cD = mk("Frame", {Name = "InnerDark", AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0.55, 0),
        BackgroundColor3 = Color3.fromRGB(8,10,24), BackgroundTransparency = 0.5,
        BorderSizePixel = 0, ZIndex = 8}, Console)
    corner(cD, 16)
    mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})}, cD)
    local CP_T, CP_B, CP_L, CP_R = 12, 12, 14, 22
    local conView = mk("Frame", {Name = "ConView", Position = UDim2.new(0, CP_L, 0, CP_T),
        Size = UDim2.new(1, -(CP_L + CP_R + 8), 1, -(CP_T + CP_B)),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 9}, Console)
    local conMover = mk("Frame", {Name = "ConMover", Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1, ZIndex = 9}, conView)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 3),
        VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder}, conMover)
    local MAXLINES, lineOrder, scrollFrac, LINE_H = 40, 0, 0, 18
    local function ts() return os.date("[%H:%M:%S]") end
    local sb = mk("TextButton", {Name = "ScrollTrack", AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 12), Size = UDim2.new(0, 4, 1, -24),
        BackgroundColor3 = C.White, BackgroundTransparency = 0.82, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false, ZIndex = 10}, Console)
    corner(sb, 2)
    local sbk = mk("TextButton", {Name = "ScrollKnob", AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.White, BackgroundTransparency = 0.4, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false, ZIndex = 10}, sb)
    corner(sbk, 2)
    local function applyScroll()
        local n = 0
        for _, l in ipairs(conMover:GetChildren()) do if l:IsA("Frame") then n = n + 1 end end
        local contentH = n * LINE_H + math.max(0, n - 1) * 3
        conMover.Size = UDim2.new(1, 0, 0, contentH)
        local viewH = conView.AbsoluteSize.Y
        if viewH <= 0 then viewH = CON_H - CP_T - CP_B end
        local overflow = math.max(0, contentH - viewH)
        conMover.Position = UDim2.new(0, 0, 0, -scrollFrac * overflow)
        local trackH = sb.AbsoluteSize.Y
        if trackH > 0 then
            local knobH = math.clamp(trackH * (viewH / math.max(contentH, 1)), 22, trackH)
            sbk.Size = UDim2.new(1, 0, 0, knobH)
            sbk.Position = UDim2.new(0, 0, 0, scrollFrac * (trackH - knobH))
        end
    end
    log = function(msg, kind)
        lineOrder = lineOrder + 1
        local line = mk("Frame", {Name = "Line", LayoutOrder = -lineOrder,
            Size = UDim2.new(1, 0, 0, LINE_H), BackgroundTransparency = 1}, conMover)
        mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
            VerticalAlignment = Enum.VerticalAlignment.Center}, line)
        mk("TextLabel", {Name = "T", Size = UDim2.new(0, 72, 1, 0), BackgroundTransparency = 1,
            Text = ts(), Font = F_CODE, TextSize = 11, TextColor3 = Color3.fromRGB(200, 210, 220),
            TextTransparency = 0.55, TextXAlignment = Enum.TextXAlignment.Left}, line)
        local body = mk("TextLabel", {Name = "B", Size = UDim2.new(1, -78, 1, 0),
            BackgroundTransparency = 1, Text = msg, Font = F_CODE, TextSize = 11,
            TextColor3 = Color3.fromRGB(200, 210, 220), TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd}, line)
        ease(body, 0.25, {TextTransparency = 0.1})
        local real = {}
        for _, l in ipairs(conMover:GetChildren()) do if l:IsA("Frame") then table.insert(real, l) end end
        table.sort(real, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        while #real > MAXLINES do real[#real]:Destroy(); table.remove(real) end
        scrollFrac = 0; applyScroll()
        if perfModeActive then
            pcall(function()
                if _perfLogFn then _perfLogFn(msg, kind) end
            end)
        end
    end
    local knobDrag = false
    local function knobFromY(y)
        local tH = sb.AbsoluteSize.Y; local kH = sbk.Size.Y.Offset
        local usable = math.max(1, tH - kH)
        scrollFrac = math.clamp((y - sb.AbsolutePosition.Y - kH/2) / usable, 0, 1)
        applyScroll()
    end
    sbk.MouseButton1Down:Connect(function() knobDrag = true end)
    sb.MouseButton1Down:Connect(function()
        knobDrag = true; local tH = sb.AbsoluteSize.Y; local m = UserInputService:GetMouseLocation()
        scrollFrac = math.clamp((m.Y - sb.AbsolutePosition.Y) / math.max(1, tH), 0, 1); applyScroll()
    end)
    UserInputService.InputChanged:Connect(function(i)
        if knobDrag and i.UserInputType == Enum.UserInputType.MouseMovement then knobFromY(i.Position.Y) end
        if i.UserInputType == Enum.UserInputType.MouseWheel then
            local m = UserInputService:GetMouseLocation()
            local ap = Console.AbsolutePosition; local asz = Console.AbsoluteSize
            if m.X >= ap.X and m.X <= ap.X + asz.X and m.Y >= ap.Y and m.Y <= ap.Y + asz.Y then
                scrollFrac = math.clamp(scrollFrac - i.Position.Z * 0.12, 0, 1); applyScroll()
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then knobDrag = false end
    end)
end
local function buildStats()
    local Stats = mk("Frame", {Name = "Stats", AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -30, 1, -30), Size = UDim2.new(0, 520, 0, 100),
        BackgroundTransparency = 1, ZIndex = 7}, ImageContainer)
    local statDefs = {{"Rounds","0",30,-3},{"Wisps","0",44,0},{"Skips","0",30,-3}}
    local statW, BASE_Y, LABEL_Y = 130, 60, 66
    for i, d in ipairs(statDefs) do
        local g = mk("Frame", {Name = d[1], Position = UDim2.new(0, (i-1)*(statW+40), 0, d[4]),
            Size = UDim2.new(0, statW, 0, 100), BackgroundTransparency = 1}, Stats)
        local sh = mk("TextLabel", {Name = "ValueShadow", AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 0, BASE_Y + 2), Size = UDim2.new(1, 0, 0, d[3] + 8),
            BackgroundTransparency = 1, Text = d[2], Font = F_OSWALD, TextSize = d[3],
            TextColor3 = Color3.fromRGB(0,0,0), TextTransparency = 0.75,
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 1}, g)
        local num = mk("TextLabel", {Name = "Value", AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 0, BASE_Y), Size = UDim2.new(1, 0, 0, d[3]+8),
            BackgroundTransparency = 1, Text = d[2], Font = F_OSWALD, TextSize = d[3],
            TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 2}, g)
        statVals[d[1]] = num; statShadows[d[1]] = sh
        shadow(num, 8, 0.45, 2, Color3.fromRGB(0,0,0))
        mk("TextLabel", {Name = "Label", AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, LABEL_Y), Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1, Text = d[1]:upper(), Font = F_MED, TextSize = 12,
            TextColor3 = C.White, TextTransparency = 0.15,
            TextXAlignment = Enum.TextXAlignment.Center}, g)
        if i < 3 then
            local dv = mk("Frame", {Name = "Div", Position = UDim2.new(0, i*(statW+40) - 20, 0, 26),
                Size = UDim2.new(0, 1.5, 0, 40), BackgroundColor3 = C.White,
                BackgroundTransparency = 0.55, BorderSizePixel = 0}, Stats)
            local dot = mk("Frame", {Name = "Dot", AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 5, 0, 5),
                BackgroundColor3 = C.White, BorderSizePixel = 0}, dv)
            corner(dot, 3)
        end
    end
    local pag = mk("Frame", {Name = "Pagination", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, -25, 0, 80), Size = UDim2.new(0, 220, 0, 30),
        BackgroundTransparency = 1}, Stats)
    local pagSpec = {{8,false},{16,false},{22,false},{11,false},{15,true}}
    local pagDx = {-80, -40, 0, 40, 80}
    for i, sp in ipairs(pagSpec) do
        local sz, filled = sp[1], sp[2]
        local dd = mk("Frame", {Name = "P" .. i, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, pagDx[i], 0.5, 0), Size = UDim2.new(0, sz, 0, sz),
            BackgroundColor3 = C.Pagination, BackgroundTransparency = filled and 0 or 1,
            BorderSizePixel = 0}, pag)
        corner(dd, math.floor(sz/2))
        if not filled then stroke(dd, 0.55, C.Pagination, 1.2) end
    end
end
local function buildPetals()
local PETAL_PNG, PETAL_N = "rbxassetid://110994357799231", 20
    local function makePetal()
        local sz = math.random(8, 18)
        local h = mk("Frame", {Name = "Petal", AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, sz, 0, sz), BackgroundTransparency = 1, Visible = false, ZIndex = 6}, ImageContainer)
        local s = mk("Frame", {Name = "Sway", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1}, h)
        local im = mk("ImageLabel", {Name = "Img", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Image = PETAL_PNG, ScaleType = Enum.ScaleType.Fit,
            ImageTransparency = 1, ZIndex = 6}, s)
        return h, s, im
    end
    local petals = {}
    for i = 1, PETAL_N do
        local h, s, im = makePetal()
        petals[i] = {h = h, s = s, im = im, baseTr = math.random(10, 30) / 100,
            state = "wait", t = -math.random(0, 90) / 10,
            x = 0, y = 0, vx = 0, vy = 0, rot = 0, vr = 0, wt = 0}
    end
    local function setTr(p, v) p.im.ImageTransparency = v end
    local respawn, fadeOut, beginFly
    function respawn(p, first)
        p.state = "wait"
p.t = first and -math.random(0, 240)/10 or -math.random(7, 16)/10
        p.h.Visible = false
    end
    function fadeOut(p)
        local tw = ease(p.im, 0.8, {ImageTransparency = 1})
        tw.Completed:Connect(function() respawn(p, false) end)
    end
    function beginFly(p)
p.x = math.random(BAN_W*0.95, BAN_W*1.25)
p.y = math.random(BAN_H*0.0, BAN_H*0.35)
p.vx = -math.random(22, 38); p.vy = math.random(6, 14)
p.ph = math.random(0, 628)/100; p.phSp = math.random(8, 20)/10
p.rot = math.random(0, 360)
        p.vr = math.random(2, 8) * (math.random() < 0.5 and 1 or -1)
        p.wt = math.random(2, 5) / 10; p.state = "fly"
        p.h.Visible = true
        p.h.Position = UDim2.new(0, p.x, 0, p.y)
        p.s.Position = UDim2.new(0.5, 0, 0.5, 0); p.im.Rotation = p.rot
        setTr(p, 1); ease(p.im, 0.4, {ImageTransparency = p.baseTr})
    end
    for _, p in ipairs(petals) do respawn(p, true) end
    RunService.Heartbeat:Connect(function(dt)
        if not MainWindow.Visible then return end
        dt = math.min(dt, 0.05)
        for _, p in ipairs(petals) do
            if p.state == "wait" then
                p.t = p.t + dt; if p.t >= 0 then beginFly(p) end
            elseif p.state == "fly" then
                p.wt = p.wt - dt
                if p.wt <= 0 then
                    p.wt = math.random(2, 5) / 10
p.vx = math.clamp(p.vx + math.random(-4, 4), -42, -10)
p.vy = math.clamp(p.vy + math.random(-3, 3), -6, 20)
                    p.vr = p.vr + math.random(-2, 2)
                end
p.x = p.x + p.vx * dt; p.y = p.y + p.vy * dt
p.ph = p.ph + p.phSp * dt
p.rot = p.rot + p.vr * dt
p.im.Rotation = p.rot + math.sin(p.ph) * 14
p.h.Position = UDim2.new(0, p.x + math.sin(p.ph) * 10, 0, p.y + math.cos(p.ph * 0.8) * 4)
                if p.x < -50 or p.y > BAN_H + 50 then fadeOut(p) end
            end
        end
    end)
end
local function buildSoul()
    SoulShadow2 = mk("TextLabel", {Name = "SoulShadow2", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, SOUL_Y + 4), Size = UDim2.new(0, 440, 0, 50),
        BackgroundTransparency = 1, Text = "Soul Lite", Font = SOUL_FONT, TextSize = 40,
        TextColor3 = C.Deep, TextTransparency = 0.85,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 1}, ContentPanel)
    SoulShadow = mk("TextLabel", {Name = "SoulShadow", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, SOUL_Y + 2), Size = UDim2.new(0, 440, 0, 50),
        BackgroundTransparency = 1, Text = "Soul Lite", Font = SOUL_FONT, TextSize = 40,
        TextColor3 = C.Deep, TextTransparency = 0.7,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 2}, ContentPanel)
    SoulTitle = mk("TextLabel", {Name = "SoulTitle", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, SOUL_Y), Size = UDim2.new(0, 440, 0, 50),
        BackgroundTransparency = 1, Text = "Soul Lite", Font = SOUL_FONT, TextSize = 40,
        TextColor3 = C.Soul, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 3}, ContentPanel)
	soulGrad = mk("UIGradient", {Rotation = 90, Color = seq3(Color3.fromRGB(100,160,200),
		Color3.fromRGB(130,190,220), Color3.fromRGB(200,235,250))}, SoulTitle)
    mk("UIStroke", {Color = Color3.fromRGB(180,180,180), Thickness = 4, Transparency = 0.9, Parent = SoulTitle})
    mk("UIStroke", {Color = Color3.fromRGB(180,180,180), Thickness = 2, Transparency = 0.8, Parent = SoulTitle})
    slL = mk("Frame", {Name = "SoulLineL", AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.5, -160, 0, SOUL_Y + 25), Size = UDim2.new(0, 80, 0, 1.5),
	BackgroundColor3 = C.Blue, BackgroundTransparency = 0.55, ZIndex = 2}, ContentPanel)
	mk("UIGradient", {Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.3)})}, slL)
	slR = mk("Frame", {Name = "SoulLineR", AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.5, 160, 0, SOUL_Y + 25), Size = UDim2.new(0, 80, 0, 1.5),
		BackgroundColor3 = C.Blue, BackgroundTransparency = 0.55, ZIndex = 2}, ContentPanel)
    mk("UIGradient", {Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})}, slR)
end
local function buildToggles()
    local TogglePanel = mk("Frame", {Name = "TogglePanel", Position = UDim2.new(0, PAD, 0, GRID_Y),
        Size = UDim2.new(0, INNER_W, 0, GRID_H), BackgroundTransparency = 1, ZIndex = 3}, ContentPanel)
    mk("UIGridLayout", {CellSize = UDim2.new(0, (INNER_W - 3*16)/4, 0, CELL_H),
        CellPadding = UDim2.new(0, 16, 0, 16), FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center}, TogglePanel)
    local featureDefs = {"Collect Wisps", "Avoid Nextbots", "Auto Revive", "Auto Plushie Hell",
        "Auto Gamemode Pro", "Auto TP Under Map", "Auto Skip Timer", "Auto Skip Vote"}
    for i, name in ipairs(featureDefs) do
        featureStates[name] = false
        local slot = mk("Frame", {Name = "Slot_" .. i, LayoutOrder = i,
            BackgroundTransparency = 1, ZIndex = 2}, TogglePanel)
        local card = mk("TextButton", {Name = "Card", AutoButtonColor = false,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.CardBg, BorderSizePixel = 0,
            Text = "", ZIndex = 3}, slot)
        corner(card, 16)
        local cS = stroke(card, 0, C.CardBorder, 1)
        local cSh = shadow(card, 45, 0.88, 6, C.Shadow)
        mk("TextLabel", {Name = "Label", Position = UDim2.new(0, 18, 0, 0),
            Size = UDim2.new(1, -58, 1, 0), BackgroundTransparency = 1, Text = name, Font = F_MED,
            TextSize = 15, TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 4}, card)
        local tog = mk("Frame", {Name = "Toggle", AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.new(0, 22, 0, 22),
            BackgroundColor3 = C.CardBg, BorderSizePixel = 0, ZIndex = 4}, card)
        corner(tog, 11)
	local togStroke = stroke(tog, 0, C.BlueHover, 1.6)
	local tG = shadow(tog, 10, 1, 0, C.BlueHover)
        local core = mk("Frame", {Name = "Core", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 9, 0, 9),
            BackgroundColor3 = C.White, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5}, tog)
        corner(core, 5)
        toggleRegs[#toggleRegs + 1] = {name = name}
        local base = card.Size
        local function sz(f)
            return UDim2.new(base.X.Scale*f, base.X.Offset*f, base.Y.Scale*f, base.Y.Offset*f)
        end
        card.MouseEnter:Connect(function()
            ease(card, 0.18, {Size = sz(1.02), BackgroundColor3 = C.CardHover})
		ease(cS, 0.18, {Transparency = 0, Color = C.BlueHover})
            if cSh then ease(cSh, 0.18, {Transparency = 0.7}) end
        end)
        card.MouseLeave:Connect(function()
            ease(card, 0.18, {Size = sz(1), BackgroundColor3 = C.CardBg})
            ease(cS, 0.18, {Transparency = 0, Color = C.CardBorder})
            if cSh then ease(cSh, 0.18, {Transparency = 0.88}) end
        end)
        card.MouseButton1Down:Connect(function() ease(card, 0.1, {Size = sz(0.98)}) end)
        local function paint(on)
		ease(tog, 0.22, {BackgroundColor3 = on and C.BlueHover or C.CardBg})
			ease(togStroke, 0.22, {Color = C.BlueHover, Transparency = on and 1 or 0})
            ease(core, 0.22, {BackgroundTransparency = on and 0 or 1,
                Size = on and UDim2.new(0, 9, 0, 9) or UDim2.new(0, 11, 0, 11)})
	if tG then ease(tG, 0.22, {Color = C.BlueHover, Transparency = on and 0.45 or 1}) end
        end
        paint(false); featurePaint[name] = paint
        card.MouseButton1Click:Connect(function()
            featureStates[name] = not featureStates[name]
            paint(featureStates[name]); ease(card, 0.18, {Size = sz(1.02)})
            log(name .. ": ", featureStates[name] and "on" or "off")
            if onFeatureToggled then onFeatureToggled(name, featureStates[name]) end
        end)
    end
end
local function buildStart()
    StartBtn = mk("TextButton", {Name = "StartButton", AutoButtonColor = false,
        Position = UDim2.new(0, PAD, 0, START_Y), Size = UDim2.new(0, INNER_W, 0, 70),
        BackgroundColor3 = C.StartBtn, BorderSizePixel = 0, Text = "", ZIndex = 3}, ContentPanel)
    corner(StartBtn, 22); sS = stroke(StartBtn, 0, C.CardBorder, 1)
    shadow(StartBtn, 50, 0.8, 14, C.Shadow)
    local startInner = mk("Frame", {Name = "Inner", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 230, 0, 40),
        BackgroundTransparency = 1, ZIndex = 4}, StartBtn)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder}, startInner)
	sDot = mk("Frame", {Name = "Dot", LayoutOrder = 1, Size = UDim2.new(0, 22, 0, 22),
		BackgroundColor3 = C.BlueHover, BorderSizePixel = 0}, startInner)
    corner(sDot, 11)
    sDotCore = mk("Frame", {Name = "Core", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 5}, sDot)
    corner(sDotCore, 4)
    sLabel = mk("TextLabel", {Name = "Label", LayoutOrder = 2, Size = UDim2.new(0, 160, 0, 30),
        BackgroundTransparency = 1, Text = "START FARM", Font = F_BOLD, TextSize = 20,
        TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center}, startInner)
    local sBase = StartBtn.Size
    local function sSz(f)
        return UDim2.new(sBase.X.Scale*f, sBase.X.Offset*f, sBase.Y.Scale*f, sBase.Y.Offset*f)
    end
    StartBtn.MouseEnter:Connect(function()
		ease(StartBtn, 0.18, {Size = sSz(1.02), BackgroundColor3 = farmRunning and C.StartOn or C.CardHover})
		if not farmRunning then ease(sS, 0.18, {Color = C.BlueHover}) end
    end)
    StartBtn.MouseLeave:Connect(function()
        ease(StartBtn, 0.18, {Size = sSz(1), BackgroundColor3 = farmRunning and C.StartOn or C.StartBtn})
        if not farmRunning then ease(sS, 0.18, {Color = C.CardBorder}) end
    end)
    StartBtn.MouseButton1Down:Connect(function() ease(StartBtn, 0.1, {Size = sSz(0.98)}) end)
    StartBtn.MouseButton1Click:Connect(function()
        if modalOpen or transitionBusy then return end
        ease(StartBtn, 0.1, {Size = sSz(0.98)})
        task.delay(0.1, function() ease(StartBtn, 0.18, {Size = sSz(1)}) end)
        if farmRunning then
            if perfModeActive then
                showStopFarmModal(
                    function()
                        transitionBusy = true
                        task.spawn(function()
                            if _perfScreenGui then
                                local restoreOverlay = mk("Frame", {Name = "StopRestoreOverlay",
                                    Size = UDim2.new(1,0,1,0),
                                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                                    BackgroundTransparency = 0.3,
                                    BorderSizePixel = 0, ZIndex = 100}, _perfScreenGui)
                                local rlines = {"Preparing game...", "Restoring graphics...",
                                                "Restoring effects...", "Restoring interface..."}
                                for i, txt in ipairs(rlines) do
                                    local lbl = mk("TextLabel", {
                                        AnchorPoint = Vector2.new(0.5,0.5),
                                        Position = UDim2.new(0.5,0,0.45,0),
                                        Size = UDim2.new(0,400,0,28),
                                        BackgroundTransparency = 1,
                                        Text = txt, Font = F_CODE, TextSize = 18,
                                        TextColor3 = Color3.fromRGB(200,220,200),
                                        TextTransparency = 1,
                                        TextXAlignment = Enum.TextXAlignment.Center,
                                        ZIndex = 101}, restoreOverlay)
                                    ease(lbl, 0.4, {TextTransparency = 0})
                                    task.wait(0.85)
                                    ease(lbl, 0.3, {TextTransparency = 1})
                                    task.wait(0.3)
                                end
                            end
                            restoreWorldClutter()
                            removeBlur()
                            MainWindow.Visible = true
                            _guiShown = true
                            ease(MainWindow, 0.4, {BackgroundTransparency = 0})
                            task.wait(0.3)
                            pcall(function()
                                if _perfScreenGui then _perfScreenGui:Destroy() end
                                _perfScreenGui = nil
                            end)
                            if _perfModeStartTime then
                                _perfTotalElapsed = _perfTotalElapsed + math.max(0, os.clock() - _perfModeStartTime)
                                _perfModeStartTime = nil
                            end
                            perfModeActive = false
                            perfModeBlocking = false
                            transitionBusy = false
                            _perfLogFn = nil
                            setFarm(false)
                        end)
                    end,
                    function()
                        applyBlur(24)
                        _returnPerfMode = true
                    end
                )
            else
                showStopFarmModal(
                    function()
                        setFarm(false)
                    end,
                    function()
                        if _returnPerfMode then
                            _returnPerfMode = false
                            task.spawn(activatePerfMode)
                        end
                    end
                )
            end
        else
            showPerfModeModal(
                function()
                    task.spawn(function()
                        transitionBusy = true
                        applyBlur(20)
                        task.wait(0.3)
                        farmRunning = true
                        sLabel.Text = "STOP FARM"
                        for nm in pairs(featureStates) do
                            featureStates[nm] = true
                            if featurePaint[nm] then featurePaint[nm](true) end
                            if onFeatureToggled then onFeatureToggled(nm, true) end
                        end
                        pcall(ease, StartBtn, 0.25, {BackgroundColor3 = C.StartOn})
                        pcall(ease, sLabel, 0.25, {TextColor3 = C.White})
                        pcall(ease, sS, 0.25, {Transparency = 1})
                        paintStart(true)
                        pcall(function() if startWispCounter then startWispCounter() end end)
                        pcall(function() log("Performance Mode farm started", "info") end)
                        pcall(function() if startFarmLogic then startFarmLogic() end end)
                        removeBlur()
                        task.wait(0.1)
                        activatePerfMode()
                    end)
                end,
                function()
                    transitionBusy = true
                    setFarm(true)
                    transitionBusy = false
                end
            )
        end
    end)
end
local function buildBottom()
    local BottomBar = mk("Frame", {Name = "BottomBar", Position = UDim2.new(0, PAD, 0, BAR_Y),
        Size = UDim2.new(0, INNER_W, 0, 40), BackgroundTransparency = 1, ZIndex = 3}, ContentPanel)
    local LeftIcons = mk("Frame", {Name = "LeftIcons", Size = UDim2.new(0, 260, 1, 0),
        BackgroundTransparency = 1}, BottomBar)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12)}, LeftIcons)
    local function pill()
        local p = mk("Frame", {Name = "Pill", Size = UDim2.new(0, 42, 0, 32),
            BackgroundColor3 = C.BottomBar, BorderSizePixel = 0}, LeftIcons)
        corner(p, 12); shadow(p, 14, 0.88, 3, C.Shadow); return p
    end
    local p1 = pill()
    local tb = mk("Frame", {Name = "Tag", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 1, 0.5, 0), Size = UDim2.new(0, 13, 0, 13),
        BackgroundColor3 = C.Text2, BorderSizePixel = 0, Rotation = 45, ZIndex = 3}, p1)
    corner(tb, 3)
    mk("Frame", {Name = "Hole", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, -2, 0.5, -2), Size = UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = C.Card, BorderSizePixel = 0, ZIndex = 4}, tb)
    local p2 = pill()
    mk("TextLabel", {Size = UDim2.new(1, 0, 1, 2), BackgroundTransparency = 1, Text = "△",
        Font = F_MED, TextSize = 18, TextColor3 = C.Text2,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 3}, p2)
    mk("TextLabel", {Size = UDim2.new(1, 0, 1, 2), BackgroundTransparency = 1, Text = "!",
        Font = F_BOLD, TextSize = 11, TextColor3 = C.Text2,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 4}, p2)
    local p3 = pill()
    mk("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "✓",
        Font = F_MED, TextSize = 16, TextColor3 = C.Text2,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 3}, p3)
    local p4 = pill()
    mk("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "↑",
        Font = F_MED, TextSize = 16, TextColor3 = C.Text2,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 3}, p4)
    local HintBar = mk("Frame", {Name = "HintBar", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 520, 0, 16),
        BackgroundTransparency = 1, ZIndex = 3}, BottomBar)
    mk("TextLabel", {Name = "HintText", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 300, 0, 16),
        BackgroundTransparency = 1, Text = "Press LCtrl to hide  ·  R to reset position", Font = F_REG,
        TextSize = 12, TextColor3 = C.HintBar, TextTransparency = 0.2,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 3}, HintBar)
    local hlL = mk("Frame", {Name = "LineL", AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.5, -160, 0.5, 0), Size = UDim2.new(0, 90, 0, 1),
        BackgroundColor3 = C.HintBar, BackgroundTransparency = 0.5, ZIndex = 3}, HintBar)
    mk("UIGradient", {Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.3)})}, hlL)
    local hlR = mk("Frame", {Name = "LineR", AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0.5, 160, 0.5, 0), Size = UDim2.new(0, 90, 0, 1),
        BackgroundColor3 = C.HintBar, BackgroundTransparency = 0.5, ZIndex = 3}, HintBar)
    mk("UIGradient", {Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})}, hlR)
    local RightInfo = mk("Frame", {Name = "RightInfo", AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 300, 1, 0),
        BackgroundTransparency = 1}, BottomBar)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder}, RightInfo)
    n1 = mk("Frame", {Name = "N_110", LayoutOrder = 1, Size = UDim2.new(0, 46, 0, 30),
        BackgroundColor3 = C.StatBadge, BackgroundTransparency = 0.4, BorderSizePixel = 0}, RightInfo)
    corner(n1, 10)
    mk("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "110",
        Font = F_REG, TextSize = 13, TextColor3 = C.Text2,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center}, n1)
    n2 = mk("Frame", {Name = "N_385", LayoutOrder = 2, Size = UDim2.new(0, 46, 0, 30),
        BackgroundColor3 = C.StatBadge, BackgroundTransparency = 0.4, BorderSizePixel = 0}, RightInfo)
    corner(n2, 10)
    mk("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "385",
        Font = F_REG, TextSize = 13, TextColor3 = C.Text2,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center}, n2)
    local soulG = mk("Frame", {Name = "SoulG", LayoutOrder = 3, Size = UDim2.new(0, 62, 0, 20),
        BackgroundTransparency = 1}, RightInfo)
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6)}, soulG)
    sd = mk("Frame", {Name = "D", Size = UDim2.new(0, 6, 0, 6),
		BackgroundColor3 = C.Blue, BorderSizePixel = 0}, soulG)
    corner(sd, 3)
    mk("TextLabel", {Name = "T", Size = UDim2.new(0, 46, 0, 18), BackgroundTransparency = 1,
        Text = "SOUL", Font = F_MED, TextSize = 12, TextColor3 = C.Text2,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center}, soulG)
    local Smiley = mk("TextButton", {Name = "Smiley", LayoutOrder = 4, AutoButtonColor = false,
        Size = UDim2.new(0, 40, 0, 40), BackgroundColor3 = C.BottomBar, BorderSizePixel = 0,
        Text = "", ZIndex = 4}, RightInfo)
    corner(Smiley, 20); shadow(Smiley, 14, 0.88, 3, C.Shadow)
    local smImg = mk("ImageLabel", {Name = "SmileyImg", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 28, 0, 28),
        BackgroundTransparency = 1, Image = "rbxassetid://130834533551123",
        ScaleType = Enum.ScaleType.Fit, BorderSizePixel = 0, ZIndex = 5}, Smiley)
    local smBase = Smiley.Size
    local function smSz(f)
        return UDim2.new(smBase.X.Scale*f, smBase.X.Offset*f, smBase.Y.Scale*f, smBase.Y.Offset*f)
    end
    Smiley.MouseEnter:Connect(function() ease(Smiley, 0.18, {Size = smSz(1.06)}) end)
    Smiley.MouseLeave:Connect(function() ease(Smiley, 0.18, {Size = smSz(1)}) end)
    Smiley.MouseButton1Click:Connect(function()
        if modalOpen or transitionBusy then return end
        settingsOpen = not settingsOpen
        if settingsOpen then
            if showSettingsWindow then showSettingsWindow() end
        else
            if hideSettingsWindow then hideSettingsWindow() end
        end
    end)
end

local SETTINGS_CHEVRON = "rbxassetid://73443883827495"

local SETTINGS_ICONS = {
	addmap   = "", map = "", gamemode = "", special = "", perk1 = "", perk2 = "",
}

local SETTINGS_OPTIONS = {
	addmap = {}, map = {}, gamemode = {}, special = {}, perk1 = {}, perk2 = {},
}

local SETTINGS_ROWS = {
	{key = "addmap",   name = "AddMap",        desc = "Choose a map to play on"},
	{key = "map",      name = "Map",           desc = "Select a map"},
	{key = "gamemode", name = "Gamemode",      desc = "Select a gamemode"},
	{key = "special",  name = "Special Round", desc = "Choose a special round"},
	{key = "perk1",    name = "Perk Slot 1",   desc = "Choose perk for slot 1"},
	{key = "perk2",    name = "Perk Slot 2",   desc = "Choose perk for slot 2"},
}

local setRefs = {}
local applySettingsTheme
local function buildCornerShine(parent, name, rotation, cardRadius, alpha, z)
	local inset = 2
	local f = mk('Frame', {Name = name,
		Position = UDim2.new(0, inset, 0, inset),
		Size = UDim2.new(1, -inset*2, 1, -inset*2),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 1 - alpha,
		BorderSizePixel = 0, ZIndex = z}, parent)
	mk('UICorner', {CornerRadius = UDim.new(0, math.max(2, cardRadius - inset))}, f)
	mk('UIGradient', {Rotation = rotation, Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.00),
		NumberSequenceKeypoint.new(0.22, 0.25),
		NumberSequenceKeypoint.new(0.50, 0.75),
		NumberSequenceKeypoint.new(1.00, 1.00),
	})}, f)
	return f
end
local function recolorGlow(frame, color)
	if frame and frame:IsA('Frame') then frame.BackgroundColor3 = color end
end
applySettingsTheme = function()
    local T = _stData
    if setRefs.title then setRefs.title.TextColor3 = T.Title end
    for _, l in ipairs(setRefs.primaries or {}) do l.TextColor3 = T.Primary end
    for _, l in ipairs(setRefs.descs or {}) do l.TextColor3 = T.Desc end
    for _, l in ipairs(setRefs.dropTexts or {}) do l.TextColor3 = T.Primary end
    local plateLight = Color3.Lerp(T.Plate, Color3.new(1,1,1), 0.08)
    for _, p in ipairs(setRefs.plates or {}) do p.BackgroundColor3 = plateLight end
    for _, b in ipairs(setRefs.drops or {}) do b.BackgroundColor3 = T.Drop end
    if setRefs.outer then setRefs.outer.BackgroundColor3 = T.Outer end
    if setRefs.inner then setRefs.inner.BackgroundColor3 = T.Inner end
    if setRefs.border then setRefs.border.Color = T.Border end
    recolorGlow(setRefs.glowTL, T.GlowTL)
    recolorGlow(setRefs.glowBR, T.GlowBR)
end

local _stData = {
	Title   = Color3.fromRGB(238,238,238),
	Primary = Color3.fromRGB(245,245,245),
	Desc    = Color3.fromRGB(148,148,148),
	Plate   = Color3.fromRGB(42,42,42),
	Drop    = Color3.fromRGB(26,26,26),
	Outer   = Color3.fromRGB(10,10,10),
	Inner   = Color3.fromRGB(13,13,13),
	GlowTL  = Color3.fromRGB(165,165,165),
	GlowBR  = Color3.fromRGB(125,125,125),
	Border  = Color3.fromRGB(105,105,105),
}
SETTINGS_THEME = setmetatable({}, {
	__index = _stData,
	__newindex = function(_, k, v)
		_stData[k] = v
		if applySettingsTheme then applySettingsTheme() end
	end,
})
showSettingsWindow = function()
    if settingsGui then return end
    transitionBusy = true
    settingsOpen = true
    setRefs = {primaries = {}, descs = {}, plates = {}, drops = {}, dropTexts = {}, chevrons = {}}
    local s = uiScale
    local overlay = mk('Frame', {Name = 'SettingsOverlay', Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1,
        BorderSizePixel = 0, Active = true, ZIndex = 500}, ScreenGui)
    applyBlur(15)
    ease(overlay, 0.3, {BackgroundTransparency = 0.55})
    local cw, ch = math.floor(500*s), math.floor(668*s)
    local headerH = math.floor(62*s)
    local centerPos = UDim2.new(0.5, 0, 0.5, 0)
    local card = mk('Frame', {Name = 'SettingsCard', AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,80), Size = UDim2.new(0,cw,0,ch),
        BackgroundColor3 = _stData.Outer, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 501}, overlay)
local cardRadius = math.floor(26*s)
corner(card, cardRadius)
    setRefs.border = stroke(card, 0, _stData.Border, 1.5)
    local glowClip = mk('Frame', {Name = 'GlowClip', Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 1}, card)
    corner(glowClip, math.floor(26*s))
    setRefs.glowClip = glowClip
    shadow(card, 50, 0.82, 12, Color3.fromRGB(10,10,10))
    setRefs.outer = card
    setRefs.glowTL = buildCornerShine(card, 'GlowTL', 45,  cardRadius, 0.22, 1)
setRefs.glowTL.BackgroundColor3 = _stData.GlowTL
setRefs.glowBR = buildCornerShine(card, 'GlowBR', 225, cardRadius, 0.18, 1)
setRefs.glowBR.BackgroundColor3 = _stData.GlowBR
    local head = mk('Frame', {Name = 'Header', AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,math.floor(15*s)), Size = UDim2.new(0,math.floor(260*s),0,math.floor(36*s)),
        BackgroundTransparency = 1, ZIndex = 3}, card)
    mk('TextLabel', {Name = 'Gear', Size = UDim2.new(0,math.floor(26*s),0,math.floor(26*s)),
        BackgroundTransparency = 1, Text = '⚙', Font = F_BOLD, TextSize = math.floor(24*s),
        TextColor3 = Color3.fromRGB(205,205,205),
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 3}, head)
    setRefs.gear = head:FindFirstChild('Gear')
    setRefs.title = mk('TextLabel', {Name = 'Title', Size = UDim2.new(0,math.floor(200*s),0,math.floor(32*s)),
        AnchorPoint = Vector2.new(0.5,0),
        Position = UDim2.new(0.5,0,0,math.floor(15*s)),
        BackgroundTransparency = 1, Text = 'SETTINGS', Font = F_BOLD, TextSize = math.floor(24*s),
        TextColor3 = _stData.Title, TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 3}, card)
    local inner = mk('Frame', {Name = 'InnerWindow',
        Position = UDim2.new(0, math.floor(10*s), 0, headerH),
        Size = UDim2.new(1, -math.floor(20*s), 1, -headerH - math.floor(12*s)),
        BackgroundColor3 = _stData.Inner, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 2}, card)
    corner(inner, math.floor(20*s))
    mk('UIGradient', {Rotation = 90, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,    0),
        NumberSequenceKeypoint.new(0.60, 0.10),
        NumberSequenceKeypoint.new(0.85, 0.55),
        NumberSequenceKeypoint.new(1,    1),
    })}, inner)
    setRefs.inner = inner
    local list = mk('Frame', {Name = 'Rows',
        Position = UDim2.new(0, math.floor(12*s), 0, math.floor(14*s)),
        Size = UDim2.new(1, -math.floor(24*s), 1, -math.floor(46*s)),
        BackgroundTransparency = 1, ZIndex = 3}, inner)
    mk('UIListLayout', {FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, math.floor(12*s)), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    local drops, openKey = {}, nil
    local PLATE_ROTS = {35, 120, 70, 150, 25, 100}
    local function closeDrop(key)
        local d = drops[key]
        if not d or not d.panel.Visible then return end
        ease(d.chev, 0.25, {Rotation = 0})
        local w = d.panel.Size.X.Offset
        local tw = ease(d.panel, 0.18, {Size = UDim2.new(0, w, 0, 0)})
        tw.Completed:Connect(function() d.panel.Visible = false end)
    end
    local function refreshOptions(key)
        local d = drops[key]
        for _, c in ipairs(d.list:GetChildren()) do
            if c:IsA('TextButton') then c:Destroy() end
        end
        for _, opt in ipairs(SETTINGS_OPTIONS[key] or {}) do
            local b = mk('TextButton', {AutoButtonColor = false,
                Size = UDim2.new(1,-math.floor(8*s),0,math.floor(32*s)),
                BackgroundColor3 = Color3.fromRGB(46,46,46), BorderSizePixel = 0,
                Text = opt, Font = F_MED, TextSize = math.floor(13*s),
                TextColor3 = _stData.Primary, ZIndex = 32}, d.list)
            corner(b, math.floor(9*s))
            table.insert(setRefs.dropTexts, b)
            b.MouseEnter:Connect(function() ease(b, 0.15, {BackgroundColor3 = Color3.fromRGB(62,62,62)}) end)
            b.MouseLeave:Connect(function() ease(b, 0.15, {BackgroundColor3 = Color3.fromRGB(46,46,46)}) end)
            b.MouseButton1Click:Connect(function()
                d.dropText.Text = opt
                closeDrop(key); openKey = nil
            end)
        end
    end
    local function openDrop(key)
        local d = drops[key]
        refreshOptions(key)
        local opts = #(SETTINGS_OPTIONS[key] or {})
        local h = math.floor((opts == 0 and 46 or math.min(150, opts*36 + 10)) * s)
        local bAp, bSz = d.btn.AbsolutePosition, d.btn.AbsoluteSize
        local cAp = card.AbsolutePosition
        local px = bAp.X - cAp.X
        local py = bAp.Y - cAp.Y + bSz.Y + math.floor(6*s)
        if py + h > ch - math.floor(8*s) then
            py = bAp.Y - cAp.Y - h - math.floor(6*s)
        end
        d.panel.Position = UDim2.new(0, px, 0, py)
        d.panel.Size = UDim2.new(0, bSz.X, 0, 0)
        d.panel.Visible = true
        ease(d.chev, 0.25, {Rotation = 180})
        ease(d.panel, 0.22, {Size = UDim2.new(0, bSz.X, 0, h)})
    end
    for i, rowDef in ipairs(SETTINGS_ROWS) do
        local row = mk('Frame', {Name = 'Row_'..rowDef.key, LayoutOrder = i,
            Size = UDim2.new(1, 0, 0, math.floor(74*s)), BackgroundTransparency = 1, ZIndex = 3}, list)
        local plate = mk('TextButton', {Name = 'Plate', AutoButtonColor = false,
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(1,0,1,0), BackgroundColor3 = _stData.Plate,
            BorderSizePixel = 0, Text = '', ClipsDescendants = true, ZIndex = 4}, row)
        corner(plate, math.floor(16*s))
        mk('UIGradient', {Rotation = PLATE_ROTS[i] or 45,
            Color = seq2(Color3.fromRGB(255,255,255), Color3.fromRGB(216,216,216))}, plate)
        table.insert(setRefs.plates, plate)
        local bright = mk('Frame', {Name = 'Brighten', Size = UDim2.new(1,0,1,0),
            BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = 5}, plate)
        corner(bright, math.floor(16*s))
        local hGrad = mk('Frame', {Name = 'HoverGlow', Size = UDim2.new(1,0,1,0),
            BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = 5}, plate)
        corner(hGrad, math.floor(16*s))
        mk('UIGradient', {Rotation = 135, Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.55),
            NumberSequenceKeypoint.new(1, 1),
        })}, hGrad)
        local icon = mk('ImageLabel', {Name = 'Icon',
            Position = UDim2.new(0, math.floor(18*s), 0.5, -math.floor(19*s)),
            Size = UDim2.new(0, math.floor(38*s), 0, math.floor(38*s)),
            BackgroundTransparency = 1, Image = SETTINGS_ICONS[rowDef.key] or '',
            ImageColor3 = Color3.fromRGB(200,200,200), ScaleType = Enum.ScaleType.Fit, ZIndex = 6}, plate)
        local nameLbl = mk('TextLabel', {Name = 'Name',
            Position = UDim2.new(0, math.floor(68*s), 0.5, -math.floor(21*s)),
            Size = UDim2.new(1, -math.floor(270*s), 0, math.floor(22*s)),
            BackgroundTransparency = 1, Text = rowDef.name, Font = F_BOLD,
            TextSize = math.floor(15*s), TextColor3 = _stData.Primary,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, plate)
        table.insert(setRefs.primaries, nameLbl)
        local descLbl = mk('TextLabel', {Name = 'Desc',
            Position = UDim2.new(0, math.floor(68*s), 0.5, math.floor(2*s)),
            Size = UDim2.new(1, -math.floor(270*s), 0, math.floor(18*s)),
            BackgroundTransparency = 1, Text = rowDef.desc, Font = F_REG,
            TextSize = math.floor(12*s), TextColor3 = _stData.Desc,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, plate)
        table.insert(setRefs.descs, descLbl)
        local dropBtn = mk('TextButton', {Name = 'Drop', AutoButtonColor = false,
            AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1, -math.floor(14*s), 0.5, 0),
            Size = UDim2.new(0, math.floor(185*s), 0, math.floor(44*s)),
            BackgroundColor3 = _stData.Drop, BorderSizePixel = 0, Text = '', ZIndex = 7}, plate)
        corner(dropBtn, math.floor(12*s))
        mk('UIGradient', {Rotation = 90,
            Color = seq2(Color3.fromRGB(255,255,255), Color3.fromRGB(225,225,225))}, dropBtn)
        table.insert(setRefs.drops, dropBtn)
        local dropText = mk('TextLabel', {Name = 'Value',
            Position = UDim2.new(0, math.floor(16*s), 0, 0), Size = UDim2.new(1, -math.floor(46*s), 1, 0),
            BackgroundTransparency = 1, Text = '', Font = F_MED,
            TextSize = math.floor(14*s), TextColor3 = _stData.Primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 8}, dropBtn)
        table.insert(setRefs.dropTexts, dropText)
        local chev = mk('ImageLabel', {Name = 'Chevron', AnchorPoint = Vector2.new(1,0.5),
            Position = UDim2.new(1, -math.floor(14*s), 0.5, 0),
            Size = UDim2.new(0, math.floor(18*s), 0, math.floor(18*s)),
            BackgroundTransparency = 1, Image = SETTINGS_CHEVRON,
            ImageColor3 = Color3.fromRGB(235,235,235), ScaleType = Enum.ScaleType.Fit, ZIndex = 8}, dropBtn)
        local panel = mk('Frame', {Name = 'DropPanel', Visible = false,
            BackgroundColor3 = Color3.fromRGB(20,20,20), BorderSizePixel = 0,
            ClipsDescendants = true, ZIndex = 30}, card)
        corner(panel, math.floor(12*s))
        mk('UIStroke', {Color = Color3.fromRGB(60,60,60), Thickness = 1, Transparency = 0.2}, panel)
        local scroll = mk('ScrollingFrame', {Name = 'Scroll', Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = math.floor(4*s), ScrollBarImageColor3 = Color3.fromRGB(90,90,90),
            CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 31}, panel)
        local optList = mk('Frame', {Name = 'OptList', Size = UDim2.new(1,0,0,0),
            BackgroundTransparency = 1, ZIndex = 31}, scroll)
        mk('UIListLayout', {FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, math.floor(6*s))}, optList)
        mk('UIPadding', {PaddingTop = UDim.new(0, math.floor(5*s)), PaddingBottom = UDim.new(0, math.floor(5*s)),
            PaddingLeft = UDim.new(0, math.floor(4*s)), PaddingRight = UDim.new(0, math.floor(4*s))}, optList)
        drops[rowDef.key] = {btn = dropBtn, chev = chev, panel = panel, list = optList, dropText = dropText}
        table.insert(setRefs.chevrons, chev)
        dropBtn.MouseButton1Click:Connect(function()
            if openKey == rowDef.key then
                closeDrop(openKey); openKey = nil
            else
                if openKey then closeDrop(openKey) end
                openKey = rowDef.key
                openDrop(rowDef.key)
            end
        end)
        plate.MouseEnter:Connect(function()
            ease(plate, 0.18, {Size = UDim2.new(1, -math.floor(8*s), 1, -math.floor(6*s))})
            ease(bright, 0.18, {BackgroundTransparency = 0.94})
            ease(hGrad, 0.22, {BackgroundTransparency = 0.85})
        end)
        plate.MouseLeave:Connect(function()
            ease(plate, 0.18, {Size = UDim2.new(1, 0, 1, 0)})
            ease(bright, 0.18, {BackgroundTransparency = 1})
            ease(hGrad, 0.22, {BackgroundTransparency = 1})
        end)
    end

    local function closeSettings()
        settingsOpen = false
        ease(card, 0.28, {BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0.5,70)})
        ease(overlay, 0.32, {BackgroundTransparency = 1})
        for _, p in ipairs(setRefs.plates or {}) do ease(p, 0.25, {BackgroundTransparency = 1}) end
        for _, b in ipairs(setRefs.drops or {}) do ease(b, 0.25, {BackgroundTransparency = 1}) end
        for _, l in ipairs(setRefs.primaries or {}) do ease(l, 0.25, {TextTransparency = 1}) end
        for _, l in ipairs(setRefs.descs or {}) do ease(l, 0.25, {TextTransparency = 1}) end
        for _, l in ipairs(setRefs.dropTexts or {}) do ease(l, 0.25, {TextTransparency = 1}) end
        if setRefs.title then ease(setRefs.title, 0.25, {TextTransparency = 1}) end
        if setRefs.gear then ease(setRefs.gear, 0.25, {TextTransparency = 1}) end
        if setRefs.inner then ease(setRefs.inner, 0.25, {BackgroundTransparency = 1}) end
        if setRefs.border then ease(setRefs.border, 0.25, {Transparency = 1}) end
        if setRefs.glowClip then ease(setRefs.glowClip, 0.25, {BackgroundTransparency = 1}) end
        if setRefs.glowTL then ease(setRefs.glowTL, 0.25, {BackgroundTransparency = 1}) end
        if setRefs.glowBR then ease(setRefs.glowBR, 0.25, {BackgroundTransparency = 1}) end
        for _, c in ipairs(setRefs.chevrons or {}) do ease(c, 0.2, {ImageTransparency = 1}) end
        task.delay(0.4, function()
            removeBlur(function()
                pcall(function() overlay:Destroy() end)
                settingsGui = nil
                transitionBusy = false
            end)
        end)
    end

    overlay.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local clickPos = i.Position
            local cardAbsPos = card.AbsolutePosition
            local cardAbsSize = card.AbsoluteSize
            if clickPos.X < cardAbsPos.X or clickPos.X > cardAbsPos.X + cardAbsSize.X or
               clickPos.Y < cardAbsPos.Y or clickPos.Y > cardAbsPos.Y + cardAbsSize.Y then
                closeSettings()
            end
        end
    end)

    settingsGui = overlay
end

hideSettingsWindow = function()
    if not settingsGui or not settingsOpen then return end
    settingsOpen = false
    local overlay = settingsGui
    local card = overlay:FindFirstChild("SettingsCard")
    if card then
        ease(card, 0.25, {BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0.5,70)})
        for _, p in ipairs(setRefs.plates or {}) do ease(p, 0.25, {BackgroundTransparency = 1}) end
        for _, b in ipairs(setRefs.drops or {}) do ease(b, 0.25, {BackgroundTransparency = 1}) end
        for _, l in ipairs(setRefs.primaries or {}) do ease(l, 0.25, {TextTransparency = 1}) end
        for _, l in ipairs(setRefs.descs or {}) do ease(l, 0.25, {TextTransparency = 1}) end
        for _, l in ipairs(setRefs.dropTexts or {}) do ease(l, 0.25, {TextTransparency = 1}) end
        if setRefs.title then ease(setRefs.title, 0.25, {TextTransparency = 1}) end
        if setRefs.gear then ease(setRefs.gear, 0.25, {TextTransparency = 1}) end
        if setRefs.inner then ease(setRefs.inner, 0.25, {BackgroundTransparency = 1}) end
        if setRefs.border then ease(setRefs.border, 0.25, {Transparency = 1}) end
        if setRefs.glowClip then ease(setRefs.glowClip, 0.25, {BackgroundTransparency = 1}) end
        if setRefs.glowTL then ease(setRefs.glowTL, 0.25, {BackgroundTransparency = 1}) end
        if setRefs.glowBR then ease(setRefs.glowBR, 0.25, {BackgroundTransparency = 1}) end
        for _, c in ipairs(setRefs.chevrons or {}) do ease(c, 0.2, {ImageTransparency = 1}) end
    end
    ease(overlay, 0.28, {BackgroundTransparency = 1})
    task.delay(0.35, function()
        removeBlur(function()
            pcall(function() overlay:Destroy() end)
            settingsGui = nil
            transitionBusy = false
        end)
    end)
    setRefs = {}
end

local _savedPerks = nil

-- PERK DATABASE: name -> id
local PERK_DB = {
    ["headphones"] = 1,
    ["stethoscope"] = 2,
    ["briefcase"] = 3,
    ["bloxy boy"] = 4,
    ["stilts"] = 5,
    ["medkit"] = 6,
    ["badge"] = 7,
    ["mil grade pack"] = 8,
    ["hermes shoes"] = 9,
    ["spring shoes"] = 10,
    ["boost pack"] = 11,
}

-- Найти ID перка по названию
local function findPerkIdByName(name)
    if not name then return nil end
    name = name:lower():gsub("^%s+", ""):gsub("%s+$", "")
    for perkName, id in pairs(PERK_DB) do
        if perkName:lower() == name then
            return id
        end
    end
    return nil
end

-- Прочитать текущие перки из UI
local function getCurrentPerks()
    local perks = {}
    pcall(function()
        local pg = LP.PlayerGui
        if not pg then return end
        local invPage = pg:FindFirstChild("InventoryPage")
        if not invPage then return end
        local board = invPage:FindFirstChild("Board")
        if not board then return end
        for i = 1, 4 do
            local slot = board:FindFirstChild("PerkSlot_" .. i)
            if slot then
                local contents = slot:FindFirstChild("Contents")
                if contents then
                    local dn = contents:FindFirstChild("DisplayName")
                    if dn and dn.Text and dn.Text ~= "" and dn.Text ~= "OWNED" then
                        perks["PerkSlot_" .. i] = {name = dn.Text}
                    end
                end
            end
        end
    end)
    return perks
end

local function saveOriginalPerks()
    _savedPerks = {}
    local current = getCurrentPerks()
    for slotName, perkData in pairs(current) do
        if perkData.name then
            local id = findPerkIdByName(perkData.name)
            if id then
                _savedPerks[slotName] = {id = id, name = perkData.name}
            end
        end
    end
    if next(_savedPerks) then
        log("Original perks saved: " .. tostring(#_savedPerks), "info")
        for slot, data in pairs(_savedPerks) do
            log("  " .. slot .. " -> " .. data.name .. " (ID:" .. data.id .. ")", "info")
        end
    end
end

local function restoreOriginalPerks()
    if not _savedPerks or not EquipRemote then return end
    log("Restoring original perks...", "info")
    for slotName, perkData in pairs(_savedPerks) do
        if perkData.id then
            pcall(function() EquipRemote:FireServer(slotName, perkData.id) end)
            log("Restored " .. slotName .. " -> " .. perkData.name .. " (ID:" .. perkData.id .. ")", "info")
        end
    end
    _savedPerks = nil
end

setFarm = function(on)
        farmRunning = on
        sLabel.Text = on and "STOP FARM" or "START FARM"
        for nm in pairs(featureStates) do
            featureStates[nm] = on
            if featurePaint[nm] then featurePaint[nm](on) end
            if onFeatureToggled then onFeatureToggled(nm, on) end
        end
        pcall(ease, StartBtn, 0.25, {BackgroundColor3 = on and C.StartOn or C.StartBtn})
        pcall(ease, sLabel, 0.25, {TextColor3 = on and C.White or C.Text})
        pcall(ease, sS, 0.25, {Transparency = on and 1 or 0})
        paintStart(on)
        if on then
            GAME_STATS.isFarming = true
            pcall(function() if startFarmLogic then startFarmLogic() end end)
            pcall(function() if startWispCounter then startWispCounter() end end)
            pcall(saveOriginalPerks)
        else
            GAME_STATS.isFarming = false
            pcall(function() if stopWispCounter then stopWispCounter() end end)
            MapWasRequested = false
            pcall(restoreOriginalPerks)
        end
        pcall(function() log(on and "Farming started..." or "Farming stopped", "info") end)
    end
local function buildFarm()
    local controlOwner = nil
    local _lastCollectTime = tick()
    local _freezeOn = false
    local _collectBusy = false
    local _collectAborted = false
    local _collectPrioUntil = 0
    local _avoidActive = false
    local _tpTarget = nil
    local _tpTargetTime = 0
    local _tpIndex = 0
    local GOLDEN = 2.399963229728653
    local _cashLabel = nil
    local _cashConn = nil
    local _lastCash = nil
    local _bcAddedConn = nil
    local _voteRunning = false
    local _roundCount, _skipCount = GAME_STATS.rounds or 0, GAME_STATS.skips or 0
    local _savedPerks = nil
    local _savedPerkConn = nil
    local function setStat(name, val)
        if statVals[name] then statVals[name].Text = tostring(val) end
        if statShadows[name] then statShadows[name].Text = tostring(val) end
    end
    local function incRound()
        if not farmRunning then return end
        _roundCount = _roundCount + 1
        setStat("Rounds", _roundCount)
        setGameStat("Rounds", _roundCount)
        _perfRoundCount = _roundCount
    end
    local function incSkip()
        if not farmRunning then return end
        _skipCount = _skipCount + 1
        setStat("Skips", _skipCount)
        setGameStat("Skips", _skipCount)
        _perfSkipCount = _skipCount
    end
    local VIPCommand, CollectRemote, SetPlayerMode, EquipRemote, VoteRemote
    local function pathRemote(...)
        local segs = table.pack(...)
        local ok, r = pcall(function()
            local cur = RS
            for i = 1, segs.n do cur = cur:WaitForChild(segs[i], 6) end
            return cur
        end)
        return (ok and r) or nil
    end
    task.spawn(function()
        VIPCommand    = pathRemote("Remotes","Admin","VIPCommand")
        CollectRemote = pathRemote("Shared","FieldSync","Remotes","Payload")
        SetPlayerMode = pathRemote("Remotes","Session","SetPlayerMode")
        EquipRemote   = pathRemote("Shared","UserData","Remotes","Equip")
        VoteRemote    = pathRemote("Remotes","Round","Vote")
        if not VoteRemote then
            log("VoteRemote not found in Remotes/Round/Vote", "warn")
            pcall(function()
                local ev = RS:WaitForChild("Events", 10)
                VoteRemote = ev:FindFirstChild("Vote")
                if not VoteRemote then
                    local pl = ev:FindFirstChild("Player")
                    if pl then VoteRemote = pl:FindFirstChild("Vote") end
                end
                if not VoteRemote then
                    local mp = ev:FindFirstChild("Map")
                    if mp then VoteRemote = mp:FindFirstChild("Vote") end
                end
            end)
        end
        if VoteRemote then
            log("VoteRemote found", "good")
        else
            log("VoteRemote not found in any known paths", "warn")
        end
        pcall(function()
            local r = RS:FindFirstChild("Events") and RS.Events:FindFirstChild("UpdateServerStateRegistry")
            if r and r:IsA("RemoteEvent") then r.OnClientEvent:Connect(function() end) end
        end)
    end)
    local function vip(...)
        if not VIPCommand then return end
        local args = table.pack(...)
        pcall(function() VIPCommand:FireServer(table.unpack(args, 1, args.n)) end)
    end
    local function fireVoteServer(num)
        if VoteRemote and VoteRemote:IsA("RemoteEvent") then
            pcall(function() VoteRemote:FireServer(num) end)
        end
    end
    local function getHRP()
        local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function stopV(hrp)
        pcall(function() hrp.Velocity = Vector3.zero; hrp.AssemblyLinearVelocity = Vector3.zero end)
    end
    local WISPS_R, WISPS_G, WISPS_B = 128, 150, 255
    local COLOR_TOLERANCE = 8
    local function isWispsColor(color)
        if not color then return false end
        local r, g, b = color.R * 255, color.G * 255, color.B * 255
        return math.abs(r - WISPS_R) <= COLOR_TOLERANCE
        and math.abs(g - WISPS_G) <= COLOR_TOLERANCE
        and math.abs(b - WISPS_B) <= COLOR_TOLERANCE
    end
    local _labelMode = "none"
    local function getMenuWispsLabel()
        local ok, lbl = pcall(function()
            return PG.HomePage.Root.Bottom.Left.Tickets.Pill.Body.Amount
        end)
        if ok and lbl and lbl:IsA("TextLabel") and lbl.Parent then return lbl end
        return nil
    end
    local function getCashLabel()
        local g = PG:FindFirstChild("Game")
        if g then
            local ok, tk = pcall(function()
                return g.HUD.Overlay.CharacterStatus.BottomLeft.Tickets
            end)
            if ok and tk then
                for _, child in ipairs(tk:GetChildren()) do
                    if child:IsA("TextLabel") and isWispsColor(child.TextColor3) then
                        _labelMode = "game"
                        return child
                    end
                end
            end
        end
        local menuLbl = getMenuWispsLabel()
        if menuLbl then
            _labelMode = "menu"
            return menuLbl
        end
        _labelMode = "none"
        return nil
    end
    local function readCash(label)
        if not label or not label.Parent then return nil end
        local text = tostring(label.Text or "")
        if not text:match("%d") then return nil end
        local clean = string.gsub(text, "[^%d]", "")
        if clean == "" then return nil end
        return tonumber(clean)
    end
    local _cashLabel = nil
    local _cashConnText = nil
    local _cashConnColor = nil
    local _baseWisps = nil
    local _lastWispsValue = nil
    local _bcActive = false
    local _bcRebindConn = nil
    local _bcAddedConn = nil
    local function onWispsValueChanged()
        if not _bcActive then return end
        if not (_cashLabel and _cashLabel.Parent) then return end
        local isWispColor = isWispsColor(_cashLabel.TextColor3)
        if _labelMode == "game" and not isWispColor then return end
        local current = readCash(_cashLabel)
        if current == nil then return end
        if _baseWisps == nil then
            _baseWisps = current
            _lastWispsValue = current
            return
        end
        if not isWispColor then return end
        local diff = current - _lastWispsValue
        if diff > 0 then
            GAME_STATS.wisps = GAME_STATS.wisps + diff
            _perfWispCount = GAME_STATS.wisps
            if statVals["Wisps"] then statVals["Wisps"].Text = tostring(GAME_STATS.wisps) end
            if statShadows["Wisps"] then statShadows["Wisps"].Text = tostring(GAME_STATS.wisps) end
        end
        _lastWispsValue = current
    end
    local function onWispsColorChanged()
        if not _bcActive then return end
        if _labelMode ~= "game" then return end
        if not (_cashLabel and _cashLabel.Parent) then return end
    end
    local function bindCashLabel(label)
        if _cashConnText then pcall(function() _cashConnText:Disconnect() end); _cashConnText = nil end
        if _cashConnColor then pcall(function() _cashConnColor:Disconnect() end); _cashConnColor = nil end
        if not (label and label.Parent) then
            log("Wisp counter: label lost, awaiting rebind", "warn")
            return
        end
        _cashLabel = label
        local current = readCash(label)
        _baseWisps = current
        _lastWispsValue = current
        log("Wisp counter: base set to " .. tostring(_baseWisps), "good")
        _cashConnText = label:GetPropertyChangedSignal("Text"):Connect(onWispsValueChanged)
        _cashConnColor = label:GetPropertyChangedSignal("TextColor3"):Connect(onWispsColorChanged)
    end
    function stopWispCounter()
        _bcActive = false
        if _cashConnText then pcall(function() _cashConnText:Disconnect() end); _cashConnText = nil end
        if _cashConnColor then pcall(function() _cashConnColor:Disconnect() end); _cashConnColor = nil end
        if _bcRebindConn then pcall(function() _bcRebindConn:Disconnect() end); _bcRebindConn = nil end
        if _bcAddedConn then pcall(function() _bcAddedConn:Disconnect() end); _bcAddedConn = nil end
        _cashLabel = nil
        _baseWisps = nil
        _lastWispsValue = nil
    end
    function startWispCounter()
        stopWispCounter()
        _bcActive = true
        if not GAME_STATS.wisps then GAME_STATS.wisps = 0 end
        setGameStat("Wisps", GAME_STATS.wisps)
        local label = getCashLabel()
        if label then
            bindCashLabel(label)
        else
            log("Wisp counter: label not found (menu or game)", "warn")
        end
        local pg = LP.PlayerGui
        _bcRebindConn = pg.DescendantRemoving:Connect(function(obj)
            if not _bcActive then return end
            if obj == _cashLabel then
                if _cashConnText then pcall(function() _cashConnText:Disconnect() end); _cashConnText = nil end
                if _cashConnColor then pcall(function() _cashConnColor:Disconnect() end); _cashConnColor = nil end
                _cashLabel = nil
            end
        end)
        _bcAddedConn = pg.DescendantAdded:Connect(function(newObj)
            if not _bcActive then return end
            if newObj:IsA("TextLabel") and (newObj.Name == "Cash" or newObj.Name == "Amount" or isWispsColor(newObj.TextColor3)) then
                local found = getCashLabel()
                if found and found ~= _cashLabel then bindCashLabel(found) end
            end
        end)
    end
    local function isIntermissionLocal()
        local ok, res = pcall(function() return PG.Game.HUD.Overlay.RoundOverlay.RoundTimer.RoundTimer end)
        if ok and res then return res.Visible end
        local ok2, res2 = pcall(function() return PG.Game.HUD.Overlay.RoundOverlay.RoundTimer   end)
        if ok2 and res2 then return res2.Visible end
        return false
    end
    local botNames = {}
    pcall(function()
        local n = RS:FindFirstChild("NPCs")
        if n then for _, m in ipairs(n:GetChildren()) do botNames[m.Name] = true end end
    end)
    local function findHRP(model)
        local ch = model:FindFirstChild("Character")
        if ch then local r = ch:FindFirstChild("HumanoidRootPart"); if r then return r end end
        return model:FindFirstChild("HumanoidRootPart", true)
    end
    local function isBot(obj)
        if not obj:IsA("Model") then return false end
        if obj == LP.Character then return false end
        if Players:GetPlayerFromCharacter(obj) then return false end
        if Players:FindFirstChild(obj.Name) then return false end
        if botNames[obj.Name] then return true end
        local ch = obj:FindFirstChild("Character")
        if ch and ch:FindFirstChild("HumanoidRootPart") and ch:FindFirstChildOfClass("Humanoid") then return true end
        return false
    end
    local _botRoots = {}
    local _queuedSuns = {}
    local _collectQueue = {}
    local _collectRunning = false
    local function feat(n) return featureStates[n] end
    workspace.DescendantAdded:Connect(function(obj)
        if isBot and isBot(obj) then local r = findHRP(obj); if r then _botRoots[obj] = r end
        elseif obj:IsA("BasePart") and obj.Name == "HumanoidRootPart" then
            local m = obj:FindFirstAncestorOfClass("Model")
            if m and isBot and isBot(m) then _botRoots[m] = obj end
        end
    end)
    workspace.DescendantRemoving:Connect(function(obj) if _botRoots and _botRoots[obj] then _botRoots[obj] = nil end end)

    task.spawn(function()
        task.wait(1)
        for _, d in ipairs(workspace:GetDescendants()) do
            if isBot and isBot(d) then
                local r = findHRP(d)
                if r then _botRoots[d] = r end
            end
        end
    end)
    local function botAlive(model)
        local h = model:FindFirstChildOfClass("Humanoid")
        if not h then local ch = model:FindFirstChild("Character"); if ch then h = ch:FindFirstChildOfClass("Humanoid") end end
        return h ~= nil and h.Health > 0
    end
    local function xzDist(a, b)
        local dx = a.X - b.X; local dz = a.Z - b.Z; return math.sqrt(dx*dx + dz*dz)
    end
    local function getNearestBot()
        local hrp = getHRP(); if not hrp then return nil, math.huge end
        local nearest, shortest = nil, math.huge
        for model, r in pairs(_botRoots) do
            if r and r.Parent and botAlive(model) then
                local d = xzDist(hrp.Position, r.Position)
                if d < 0.5 then _botRoots[model] = nil
                elseif d < shortest then shortest = d; nearest = r end
            else _botRoots[model] = nil end
        end
        return nearest, shortest
    end
    local function newTPPoint()
        if CFG.MapCenterX == 0 and CFG.MapCenterZ == 0 then
            if not _mapCenter then
                local h = getHRP()
                _mapCenter = h and Vector2.new(h.Position.X, h.Position.Z) or Vector2.new(0, 0)
            end
        else _mapCenter = Vector2.new(CFG.MapCenterX, CFG.MapCenterZ) end
        _tpIndex = _tpIndex + 1
        local a = _tpIndex * GOLDEN
        local r = (_tpIndex % 2 == 0) and CFG.MapRadius or (CFG.MapRadius * 0.45)
        return Vector3.new(_mapCenter.X + math.cos(a) * r, UNDER_MAP_Y, _mapCenter.Y + math.sin(a) * r)
    end
    local function releaseToTP()
        if feat("Auto TP Under Map") then controlOwner = "tp" else controlOwner = nil end
    end
    local VirtualUser = game:GetService("VirtualUser")
    local AIR_PLATFORM_OFFSET = 3.6
    pcall(function()
        local oldAir = workspace:FindFirstChild("SoulLiteAirPlatform")
        if oldAir then oldAir:Destroy() end
    end)
    local floatPlatform
    local function createFloatPlatform()
        if floatPlatform and floatPlatform.Parent then return end
        floatPlatform = Instance.new("Part")
        floatPlatform.Name = "SoulLiteAirPlatform"
        floatPlatform.Anchored = true
        floatPlatform.CanCollide = true
        floatPlatform.CanQuery = true
        floatPlatform.CanTouch = true
        floatPlatform.Massless = true
        floatPlatform.Transparency = 1
        floatPlatform.Size = Vector3.new(5, 1.5, 5)
        floatPlatform.Material = Enum.Material.SmoothPlastic
        floatPlatform.TopSurface = Enum.SurfaceType.Smooth
        floatPlatform.BottomSurface = Enum.SurfaceType.Smooth
        floatPlatform.CastShadow = false
        floatPlatform.Parent = workspace
    end
    local function removeFloatPlatform()
        if floatPlatform then
            pcall(function()
                floatPlatform:Destroy()
            end)
            floatPlatform = nil
        end
    end
    local function updateFloatPlatform(pos)
        if not (floatPlatform and floatPlatform.Parent) then
            createFloatPlatform()
        end
        if floatPlatform then
            floatPlatform.CFrame = CFrame.new(pos)
        end
    end
    task.spawn(function()
        while true do
            task.wait(0.03)
            if feat("Auto TP Under Map") or feat("Collect Wisps") then
                local hrp = getHRP()
                if hrp then
                    updateFloatPlatform(hrp.Position - Vector3.new(0, AIR_PLATFORM_OFFSET, 0))
                end
            else
                if floatPlatform then removeFloatPlatform() end
            end
        end
    end)
    if not LP:GetAttribute("SoulLiteAntiAfk") then
        LP:SetAttribute("SoulLiteAntiAfk", true)
        LP.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
    ScreenGui.Destroying:Connect(function()
        removeFloatPlatform()
        if stopBubbleCounter then stopBubbleCounter() end
    end)
    RunService.Heartbeat:Connect(function()
        if controlOwner == "collect" and not _collectBusy then
            controlOwner = feat("Auto TP Under Map") and "tp" or nil
        end
        if not feat("Auto TP Under Map") then
            if controlOwner == "tp" then controlOwner = nil end
            return
        end
        local own = (controlOwner == nil or controlOwner == "tp")
        _freezeOn = own
        if not own then return end
        if not _tpTarget or (os.clock() - _tpTargetTime) > 3 then
            _tpTarget = newTPPoint()
            _tpTargetTime = os.clock()
        end
        local hrp = getHRP()
        if hrp then
            if (hrp.Position - _tpTarget).Magnitude > 2 then
                hrp.CFrame = CFrame.new(_tpTarget)
            end
            stopV(hrp)
        end
    end)
    local _lastAvoidTP = 0
    RunService.Heartbeat:Connect(function(dt)
        if not feat("Avoid Nextbots") then return end
        local _isInterm = isIntermissionLocal()
        if _isInterm and not perfModeActive then return end

        if _collectBusy and os.clock() < _collectPrioUntil then return end
        local bot, dist = getNearestBot()
        if bot and dist and dist < avoidValue then
            local now = os.clock()
            if now - _lastAvoidTP >= 0.08 then
                _lastAvoidTP = now
                _avoidActive = true
                if _collectBusy then _collectAborted = true end
                _freezeOn = false
                if feat("Auto TP Under Map") then controlOwner = "avoid" end
                local hrp = getHRP()
                if hrp then
                    local mc = _mapCenter or Vector2.new(CFG.MapCenterX, CFG.MapCenterZ)
                    local cr = CFG.MapRadius
                    local py = hrp.Position.Y
                    local corners = {
                        Vector3.new(mc.X - cr, py, mc.Y - cr),
                        Vector3.new(mc.X + cr, py, mc.Y - cr),
                        Vector3.new(mc.X - cr, py, mc.Y + cr),
                        Vector3.new(mc.X + cr, py, mc.Y + cr),
                    }
                    local best, bestDist = corners[1], (corners[1] - bot.Position).Magnitude
                    for i = 2, 4 do
                        local d = (corners[i] - bot.Position).Magnitude
                        if d > bestDist then bestDist = d; best = corners[i] end
                    end
                    hrp.CFrame = CFrame.new(best)
                    stopV(hrp)
                end
            end
            if now - _lastAvoidLogTime >= 1.0 then
                _lastAvoidLogTime = now
                log("Avoid nextbot (" .. math.floor(dist) .. " studs)", "warn")
            end
        else
            if _avoidActive then
                _avoidActive = false
                if controlOwner == "avoid" then
                    controlOwner = feat("Auto TP Under Map") and "tp" or nil
                end
            end
        end
    end)
    local function safeCollectRemote(tickId)
        if not CollectRemote then return end
        pcall(function()
            if CollectRemote:IsA("RemoteFunction") then
                CollectRemote:InvokeServer(LP, tickId, "Collect")
            elseif CollectRemote:IsA("RemoteEvent") then
                CollectRemote:FireServer(LP, tickId, "Collect")
            end
        end)
    end
    local _collectQueue = {}; local _collectRunning = false

    local function queueSun(obj)
        local model = obj
        if not (model and model:IsA("Model")) then
            model = obj and obj:FindFirstAncestorOfClass("Model")
        end
        if not model then return end
        if not model.Parent then return end
        local modelName = model.Name
        if not CFG.TicketIds[modelName] then
            log("Unknown wisp model: " .. modelName, "warn")
            return
        end
        if _queuedSuns[model] then return end
        _queuedSuns[model] = true
        table.insert(_collectQueue, model)
        log("Queued wisp: " .. modelName .. " (tickId: " .. CFG.TicketIds[modelName] .. ")", "good")
    end
    local function collectLoop(model, tickId, bubblePos)
        log("collectLoop started for " .. model.Name, "info")
        local MAX_ATTEMPTS = CFG.CollectRetries
        local STAND_MAX    = 0.8
        local _lastInterrupted = false
        for attempt = 1, MAX_ATTEMPTS do
            if not (feat("Collect Wisps") and model and model.Parent) then return end
            local ignoreAvoid = (attempt >= MAX_ATTEMPTS)
            local pause = (attempt > 1)
                and (_lastInterrupted and CFG.CollectPostAvoidWait or CFG.CollectRetryGap)
                or  CFG.CollectWait
            local p0 = os.clock()
            while os.clock() - p0 < pause and feat("Collect Wisps") and model and model.Parent do
                task.wait(0.1)
            end
            if not (feat("Collect Wisps") and model and model.Parent) then return end
            controlOwner = "collect"; _collectBusy = true; _freezeOn = false
            if ignoreAvoid then
                _collectPrioUntil = os.clock() + STAND_MAX + 0.3
            end
            local bhrp  = model:FindFirstChild("HumanoidRootPart")
            local standCF = (bhrp and bhrp.CFrame) or CFrame.new(bubblePos)
            local hrp   = getHRP()
            if hrp then
                log("TP to " .. model.Name .. " attempt " .. attempt, "info")
                hrp.CFrame = standCF
                stopV(hrp)
            else
                log("No HRP found!", "bad")
            end
            _collectAborted = false
            local t0 = os.clock()
            local collected   = false
            local interrupted = false
            local nextRemote  = 0
            while os.clock() - t0 < STAND_MAX do
                if not model.Parent then collected = true; break end
                if not feat("Collect Wisps") then break end
                if not ignoreAvoid and (_collectAborted or _avoidActive) then interrupted = true; break end
                if os.clock() >= nextRemote then
                    safeCollectRemote(tickId)
                    nextRemote = os.clock() + 0.1
                end
                task.wait(0.05)
            end
            _collectBusy = false
            if ignoreAvoid then _collectPrioUntil = 0 end
            _lastInterrupted = interrupted
            if collected then
                releaseToTP()
                return
            end
            releaseToTP()
        end
        _collectBusy = false
        _collectPrioUntil = 0
        releaseToTP()
    end
    local function runCollector()
        if _collectRunning then return end
        _collectRunning = true
        log("runCollector started", "info")
        task.spawn(function()
            while feat("Collect Wisps") do
                local model = table.remove(_collectQueue, 1)
                if not model then
                    task.wait(0.1)
                    continue
                end
                if not model.Parent then
                    _queuedSuns[model] = nil
                    continue
                end
                local tickId = CFG.TicketIds[model.Name]
                if tickId then
                    log("Processing wisp: " .. model.Name, "info")
                    local bp
                    local bhrp = model:FindFirstChild("HumanoidRootPart")
                    if bhrp then
                        bp = bhrp.Position
                        log("  HRP found at: " .. tostring(bp), "info")
                    else
                        local ok, piv = pcall(function() return model:GetPivot() end)
                        if ok and piv then bp = piv.Position
                        else for _, p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then bp = p.Position; break end end end
                    end
                    bp = bp or Vector3.new(0, 0, 0)
                    log("  Collecting from position: " .. tostring(bp), "info")
                    local cok, cerr = xpcall(collectLoop, debug.traceback, model, tickId, bp)
                    if not cok then
                        log("Collect error (F9 for trace)", "bad")
                        log("Collect traceback: " .. tostring(cerr), "bad")
                    end
                else
                    log("  No tickId for " .. model.Name, "warn")
                end
                _queuedSuns[model] = nil
                _collectBusy = false
                _collectPrioUntil = 0
                if feat("Auto TP Under Map") then controlOwner = "tp" else controlOwner = nil end
            end
            log("runCollector stopped", "info")
            _collectRunning = false
            _collectBusy = false
            releaseToTP()
        end)
    end
    workspace.DescendantAdded:Connect(function(obj)
        if not feat("Collect Wisps") then return end
        local model = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
        if not model then return end
        if not model.Parent then return end
        local modelName = model.Name
        if not CFG.TicketIds[modelName] then
            if modelName:find("Wisp", 1, true) or modelName:find("Tier", 1, true) then
                log("Wisp model found but name mismatch: " .. modelName, "warn")
            end
            return
        end
        local _bubbleNow = os.clock()
        if _bubbleNow - _lastWispLogTime >= 1.0 then
            _lastWispLogTime = _bubbleNow
            log(model.Name .. " appeared", "info")
        end
        queueSun(model)
        runCollector()
    end)
    local function scanExistingSuns()
        local found = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Parent and CFG.TicketIds[obj.Name] then
                queueSun(obj)
                found = found + 1
            end
        end
        if found == 0 then
            log("scanExistingSuns: no wisp models found in workspace", "warn")
            log("Available wisp-like models:", "warn")
            local count = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:find("Wisp", 1, true) or obj.Name:find("Ticket", 1, true)) then
                    log("  - " .. obj.Name, "warn")
                    count = count + 1
                    if count >= 10 then break end
                end
            end
        else
            log("scanExistingSuns: found " .. found .. " wisp models", "good")
        end
        runCollector()
    end
    local _reviveConn = nil
    local function stopReviveWatch() if _reviveConn then _reviveConn:Disconnect(); _reviveConn = nil end end
    local function startReviveWatch()
        local char = LP.Character; if not char then return end
        local hum = char:WaitForChild("Humanoid", 5); if not hum then return end
        stopReviveWatch()
        _reviveConn = hum.HealthChanged:Connect(function(hp)
            if not feat("Auto Revive") then return end
            if hp <= 0 then
                log("Downed, reviving", "bad")
                if _perfLogFn then _perfLogFn("Downed", "bad") end
                if not _perfDownedCooldown then
                    _perfDownedCooldown = true
                    _perfDownedCount = _perfDownedCount + 1
                    setGameStat("Downed", _perfDownedCount)
                    task.delay(5, function() _perfDownedCooldown = false end)
                end
                task.spawn(function()
                    while feat("Auto Revive") do
                        if SetPlayerMode then pcall(function() SetPlayerMode:FireServer(true) end) end
                        if not feat("Auto Revive") then break end
                        task.wait(0.3)
                        local char = LP.Character
                        if not char then task.wait(0.5); continue end
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if not hum then task.wait(0.5); continue end
                        if hum.Health > 0 then break end
                        task.wait(0.5)
                    end
                end)
            end
        end)
    end
    local function startVoteDetection()
        if _voteRunning then return end
        _voteRunning = true
        task.spawn(function()
            local _voteHandled = false
            while _voteRunning and feat("Auto Skip Vote") do
                local voteGui = nil
                local pgShared = PG:FindFirstChild("Shared")
                local popups = pgShared and pgShared:FindFirstChild("Popups")
                if popups then
                    voteGui = popups:FindFirstChild("Vote")
                end
                if not voteGui then
                    voteGui = PG:FindFirstChild("Vote")
                end
                if not voteGui and PG:FindFirstChild("Game") then
                    voteGui = PG.Game:FindFirstChild("Vote")
                end
                if voteGui and voteGui.Visible then
                    if not _voteHandled then
                        _voteHandled = true
                        log("Vote window found", "info")
                        pcall(function()
                            vip("!timer 1")
                        end)
                        log("Auto Vote: timer skip sent", "good")
                        if _perfLogFn then _perfLogFn("Vote Skip sent", "good") end
                        incSkip()
                        local choices = voteGui:FindFirstChild("Choices")
                        if choices and choices:FindFirstChild("1") then
                            if VoteRemote then
                                log("Sending vote", "info")
                                pcall(function()
                                    fireVoteServer(1)
                                end)
                            end
                        end
                    end
                    task.wait(0.5)
                else
                    _voteHandled = false
                    task.wait(0.8)
                end
            end
        end)
    end
    local function stopVoteDetection()
        _voteRunning = false
    end
    local _stateHandled = false
    local function onIntermission()
        if _stateHandled then return end
        _stateHandled = true
        _perfRoundActive = false
        _perfRoundStartTime = nil
        task.wait(0.2)
        if feat("Auto Gamemode Pro") and VIPCommand then
            pcall(function() VIPCommand:FireServer(getEventValue("gamemode")) end)
            log("Gamemode: " .. getEventValue("gamemode"), "good")
            if _perfLogFn then _perfLogFn("Gamemode -> " .. getEventValue("gamemode"), "good") end
        end
        task.wait(0.2)
        if feat("Auto Skip Timer") and VIPCommand then
            pcall(function() VIPCommand:FireServer("!timer 1") end)
            if not _skipDoneThisRound then
                incSkip()
                _skipDoneThisRound = true
            end
            log("Intermission timer 1s", "good")
        end
        task.wait(0.3)
        if feat("Auto Plushie Hell") and VIPCommand then
            pcall(function() VIPCommand:FireServer(getEventValue("specialround")) end)
            log("Special round: " .. getEventValue("specialround"), "good")
        end
        incRound()
        if _perfLogFn then _perfLogFn("Round Started", "good") end
    end

    local function onRound()
        if _stateHandled then return end
        _stateHandled = true
        _skipDoneThisRound = false
        log("Round started", "good")
        _perfRoundActive = true
        _perfRoundStartTime = os.clock()
        if _perfLogFn then _perfLogFn("Map -> WorkFacility", "good") end
    end
    local roundStartEvent = RS:FindFirstChild("RoundStart") or RS:FindFirstChild("GameRoundStart")
    local roundEndEvent = RS:FindFirstChild("RoundEnd") or RS:FindFirstChild("IntermissionStart")
    if roundStartEvent and roundEndEvent then
        log("State events found, using events", "good")
        local _lastInterm = isIntermissionLocal()
        if not _lastInterm then
            _perfRoundActive = true
            _perfRoundStartTime = nil
        end
        roundStartEvent.OnClientEvent:Connect(function()
            task.spawn(onRound)
        end)
        roundEndEvent.OnClientEvent:Connect(function()
            task.spawn(onIntermission)
        end)
    else
        log("No state events found, using GUI polling", "warn")
        local _lastInterm = isIntermissionLocal()
        if not _lastInterm then
            _perfRoundActive = true
            _perfRoundStartTime = nil
        end
        task.spawn(function()
            while true do
                task.wait(0.5)
                if feat("Auto Gamemode Pro") or feat("Auto Skip Timer") or feat("Auto Plushie Hell") or feat("Auto TP Under Map") then
                    local interm = isIntermissionLocal()
                    if _lastInterm ~= interm then
                        _lastInterm = interm
                        _stateHandled = false
                        log("State changed: " .. (interm and "INTERMISSION" or "ROUND"), "info")
                        if interm then
                            task.spawn(onIntermission)
                        else
                            task.spawn(onRound)
                        end
                    end
                end
            end
        end)
    end
    LP.CharacterAdded:Connect(function(char)
        if not feat("Auto Revive") then return end
        char:WaitForChild("Humanoid", 5); task.wait(1)
        startReviveWatch()
    end)
    local featureHandlers = {
        ["Avoid Nextbots"]    = function(on) if not on then _avoidActive = false end end,
        ["Auto Revive"]       = function(on) if on then startReviveWatch() else stopReviveWatch() end end,
        ["Auto Skip Vote"]    = function(on) if on then startVoteDetection() else stopVoteDetection() end end,
        ["Auto TP Under Map"] = function(on)
            if not on then
                if controlOwner == "tp" then controlOwner = nil end
            end
        end,
        ["Collect Wisps"]   = function(on)
            if on then
                startWispCounter()
                scanExistingSuns()
            else
                stopWispCounter()
                _collectRunning = false
                _collectQueue = {}
                _queuedSuns = {}
                _collectBusy = false
                _collectPrioUntil = 0
                if controlOwner == "collect" then releaseToTP() end
            end
        end,
    }
    onFeatureToggled = function(name, enabled)
        local h = featureHandlers[name]; if h then h(enabled) end
    end
    startFarmLogic = function()
        if not VIPCommand then
            log("Resolving remotes...", "warn")
            local w = 0
            while not VIPCommand and w < 24 do task.wait(0.25); w = w + 1 end
            task.spawn(function()
                local afkTimer = 0
                while true do
                    task.wait(1)
                    if farmRunning then
                        afkTimer = afkTimer + 1
                        if afkTimer >= 60 and controlOwner == nil then
                            local hrp = getHRP()
                            if hrp then
                                local oldVel = hrp.Velocity
                                hrp.Velocity = Vector3.new(oldVel.X, 15, oldVel.Z)
                                task.wait(0.1)
                                hrp.Velocity = Vector3.new(oldVel.X, 0, oldVel.Z)
                                log("Anti-AFK: mini-jump performed", "good")
                            end
                            afkTimer = 0
                        end
                    else
                        afkTimer = 0
                    end
                end
            end)
        end
        if not VIPCommand then log("VIP remote missing", "bad") end
        task.spawn(function()
            log("Initializing", "info"); task.wait(0.2)
            if VIPCommand then
                pcall(function() VIPCommand:FireServer(getEventValue("gamemode")) end)
            end
            task.wait(0.2)
            local equipWait = 0
            while not EquipRemote and equipWait < 80 do
                task.wait(0.25); equipWait = equipWait + 1
            end
            if EquipRemote then
                local perk1Id = 7  -- badge
                local perk2Id = 3  -- briefcase
                pcall(function() EquipRemote:FireServer("PerkSlot_1", perk1Id) end); task.wait(0.2)
                pcall(function() EquipRemote:FireServer("PerkSlot_2", perk2Id) end)
                log("Perks equipped: Slot1=" .. perk1Id .. " (badge) Slot2=" .. perk2Id .. " (briefcase)", "good")
                if _perfLogFn then _perfLogFn("Perks Equipped", "good") end
            else
                log("EquipRemote not found — perks skipped", "bad")
            end
            if not MapWasRequested and VIPCommand then
                pcall(function() VIPCommand:FireServer("AddMap", "WorkFacility") end)
                task.wait(0.15)
                pcall(function() VIPCommand:FireServer("!map WorkFacility") end)
                MapWasRequested = true
                log("Map: AddMap + !map WorkFacility sent", "good")
                if _perfLogFn then _perfLogFn("Map -> WorkFacility", "good") end
            end
            log("Farm active", "good")
            if _perfLogFn then _perfLogFn("Farm Active", "good") end
        end)
        local _joinedOnce = false
        task.spawn(function()
            while farmRunning do
                task.wait(1.5)
                if _joinedOnce then break end
                pcall(function()
                    local playerGui = PG
                    if not playerGui then return end
                    local homePage = playerGui:FindFirstChild("HomePage")
                    if not homePage then return end
                    local root = homePage:FindFirstChild("Root")
                    if not root then return end
                    local mainMenu = root:FindFirstChild("MainMenu")
                    if not mainMenu then return end
                    local center = mainMenu:FindFirstChild("Center")
                    if not center then return end
                    local buttons = center:FindFirstChild("Buttons")
                    if not buttons then return end
                    local fr = buttons:FindFirstChild("Frame")
                    if not fr then return end
                    local b = fr:FindFirstChild("B")
                    if not b then return end
                    local imgBtn = b:FindFirstChild("ImageButton")
                    if imgBtn and imgBtn.Visible then
                        if SetPlayerMode then
                            pcall(function() SetPlayerMode:FireServer(true) end)
                            _joinedOnce = true
                            log("Auto join: entered round", "good")
                            if _perfLogFn then _perfLogFn("Auto Join Round", "good") end
                        end
                    end
                end)
            end
        end)
    end
end
local function buildRadiusVisual()
    local LEVELS = {-2.6, 2.2}
    local folder = workspace:FindFirstChild("RadiusVisualizerParts")
    if folder then folder:Destroy() end
    folder = Instance.new("Folder"); folder.Name = "RadiusVisualizerParts"; folder.Parent = workspace
    local ringFade = Instance.new("NumberValue"); ringFade.Value = 0
    local wants = false; local phase = 0; local rings = {}
    local function makeRing(level)
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Block; part.Anchored = true
        part.CanCollide = false; part.CanQuery = false; part.CanTouch = false
        part.Transparency = 1; part.Material = Enum.Material.SmoothPlastic
        part.Size = Vector3.new(2 * avoidValue, 0.05, 2 * avoidValue); part.Parent = folder
        local ring = { part = part, level = level, fadeObj = nil }
        if RING_TEX ~= "" then
            local decal = Instance.new("Decal")
            decal.Face = Enum.NormalId.Top; decal.Texture = RING_TEX
            decal.Transparency = 1; decal.Color3 = Color3.fromRGB(255, 255, 255); decal.Parent = part
            ring.fadeObj = decal
        else
            local sg = Instance.new("SurfaceGui")
            sg.Adornee = part; sg.Face = Enum.NormalId.Top
            sg.LightInfluence = 0; sg.AlwaysOnTop = false
            sg.PixelsPerStud = 12; sg.Enabled = false; sg.Parent = part
            local circ = Instance.new("Frame")
            circ.Size = UDim2.new(1, 0, 1, 0); circ.BackgroundTransparency = 1; circ.Parent = sg
            Instance.new("UICorner", circ).CornerRadius = UDim.new(0.5, 0)
            local st = Instance.new("UIStroke")
            st.Color = Color3.fromRGB(242, 90, 103); st.Thickness = 4
            st.Transparency = 1; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = circ
            local gr = Instance.new("UIGradient")
            gr.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.5, 0.65), NumberSequenceKeypoint.new(1, 0)})
            gr.Rotation = 35; gr.Parent = st
            ring.sg = sg; ring.fadeObj = st
        end
        return ring
    end
    for _, lv in ipairs(LEVELS) do rings[#rings + 1] = makeRing(lv) end
    setRingRadius = function(r)
        r = math.clamp(math.floor(r), 1, 300)
        for _, ring in ipairs(rings) do ring.part.Size = Vector3.new(2 * r, 0.05, 2 * r) end
    end
    setRingRadius(avoidValue)
    showRing = function()
        wants = true; setRingRadius(avoidValue)
        for _, ring in ipairs(rings) do if ring.sg then ring.sg.Enabled = true end end
        TweenService:Create(ringFade, TweenInfo.new(0.25, QU, Enum.EasingDirection.Out), { Value = 1 }):Play()
    end
    hideRing = function()
        wants = false
        TweenService:Create(ringFade, TweenInfo.new(0.35, QU, Enum.EasingDirection.In), { Value = 0 }):Play()
    end
    RunService.Heartbeat:Connect(function(dt)
        local f = ringFade.Value
        if f < 0.01 and not wants then
            for _, ring in ipairs(rings) do
                ring.part.Transparency = 1
                if ring.fadeObj then ring.fadeObj.Transparency = 1 end
                if ring.sg then ring.sg.Enabled = false end
            end
            return
        end
        phase = phase + dt * 1.4
        local c = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not c then return end
        local pos = c.Position
        for _, ring in ipairs(rings) do
            ring.part.CFrame = CFrame.new(pos.X, pos.Y + ring.level, pos.Z) * CFrame.Angles(0, phase, 0)
            ring.part.Transparency = 1
            if ring.fadeObj then ring.fadeObj.Transparency = 1 - f end
            if ring.sg then ring.sg.Enabled = f > 0.01 end
        end
    end)
end
buildGlass(); buildContent(); buildHeader(); buildBanner(); buildSlider()
buildConsole(); buildStats(); buildPetals(); buildSoul(); buildToggles()
buildStart(); buildBottom()
buildFarm()
local _buildFarmDone = true
buildRadiusVisual()
local function applyEye(on)
    eyeIcon.Image = on and ICON_CLOSED or ICON_OPEN
    if Handle then Handle.Text = on and masked or realHandle end
end
applyEye(true)
EyeButton.MouseButton1Click:Connect(function()
    privacy = not privacy; eyeIcon.Image = privacy and ICON_CLOSED or ICON_OPEN
    if not Handle then return end
    if busy then Handle.Text = privacy and masked or realHandle; return end
    busy = true; ease(Handle, 0.18, {TextTransparency = 1}); task.wait(0.18)
    Handle.Text = privacy and masked or realHandle
    ease(Handle, 0.18, {TextTransparency = 0}); task.wait(0.18); busy = false
end)
DragZone.InputBegan:Connect(function(i)
    if not modalOpen and not transitionBusy
       and i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragStartMs = UserInputService:GetMouseLocation()
        dragStartMF = MainWindow.Position
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = false
    end
end)
RunService.RenderStepped:Connect(function()
    if not dragActive or modalOpen or transitionBusy then return end
    local m = UserInputService:GetMouseLocation()
    MainWindow.Position = UDim2.new(
        dragStartMF.X.Scale, dragStartMF.X.Offset + (m.X - dragStartMs.X),
        dragStartMF.Y.Scale, dragStartMF.Y.Offset + (m.Y - dragStartMs.Y)
    )
end)
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if modalOpen or transitionBusy then return end
    local kc = i.KeyCode
    if kc == Enum.KeyCode.LeftControl then
        if _fading then return end
        _guiShown = not _guiShown
        fadeGui(not _guiShown)
    end
    if kc == Enum.KeyCode.R then
        dragActive = false
        ease(MainWindow, 0.25, {Position = UDim2.new(0.5, 0, 0.5, 0)})
    end
end)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
applyTheme(RED_THEME)

runCinematicIntro = function(iGui, loadBg)

for _, child in ipairs(iGui:GetChildren()) do
    if child ~= loadBg then
        pcall(function() child:Destroy() end)
    end
end

local _vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
local vpW, vpH = _vp.X, _vp.Y

local scaleRatio = math.clamp(vpW / 1920, 0.6, 1.3)

local introScaleFactor = math.clamp(vpW / 1920, 0.55, 1.2)

local CAT_RAW = {
    {1821.63,637.76},{1821.35,619.8},{1820.51,602.15},{1819.13,584.8},{1817.21,567.75},
    {1814.76,551.02},{1811.79,534.58},{1808.31,518.45},{1804.33,502.63},{1799.85,487.1},
    {1794.89,471.88},{1789.46,456.96},{1783.56,442.35},{1777.2,428.04},{1770.39,414.02},
    {1763.15,400.31},{1755.47,386.9},{1747.37,373.79},{1738.86,360.98},{1729.94,348.47},
    {1720.63,336.26},{1710.93,324.34},{1706.43,315.83},{1708.52,309.98},{1710.89,302.82},
    {1713.42,294.37},{1716.03,284.68},{1718.61,273.78},{1721.08,261.7},{1723.34,248.49},
    {1725.28,234.18},{1726.82,218.8},{1727.86,202.4},{1728.29,185.01},{1728.03,166.66},
    {1726.98,147.4},{1725.04,127.25},{1722.12,106.26},{1718.12,84.46},{1712.94,61.89},
    {1706.48,38.58},{1698.66,14.57},{1694.2,2.72},{1692.9,2.36},{1690.29,1.78},
    {1686.36,1.12},{1681.11,0.51},{1674.5,0.11},{1666.52,0.04},{1657.16,0.45},
    {1646.4,1.47},{1634.23,3.25},{1620.62,5.92},{1605.56,9.62},{1589.03,14.49},
    {1571.02,20.67},{1551.5,28.3},{1530.47,37.51},{1507.91,48.46},{1483.79,61.27},
    {1458.11,76.08},{1430.84,93.04},{1401.97,112.28},{1377.82,123.12},{1362.47,118.88},
    {1347.01,114.89},{1331.45,111.14},{1315.78,107.65},{1300.03,104.41},{1284.19,101.42},
    {1268.28,98.67},{1252.3,96.18},{1236.26,93.93},{1220.17,91.93},{1204.04,90.18},
    {1187.87,88.68},{1171.67,87.42},{1155.45,86.41},{1139.22,85.64},{1122.98,85.12},
    {1106.74,84.84},{1090.5,84.9},{1074.26,85.26},{1058.01,85.86},{1041.77,86.7},
    {1025.56,87.79},{1009.36,89.13},{993.2,90.72},{977.07,92.55},{961.0,94.63},
    {944.98,96.95},{929.02,99.53},{913.13,102.35},{897.32,105.43},{881.6,108.75},
    {865.97,112.33},{850.45,116.15},{835.03,120.23},{819.74,124.56},{791.0,105.79},
    {762.65,87.31},{735.9,71.07},{710.72,56.93},{687.1,44.74},{665.03,34.37},
    {644.49,25.68},{625.46,18.54},{607.92,12.79},{591.86,8.32},{577.26,4.96},
    {564.1,2.59},{552.37,1.07},{542.06,0.26},{533.13,0.02},{525.59,0.21},
    {519.4,0.69},{514.57,1.32},{511.05,1.97},{508.86,2.5},{507.95,2.76},
    {501.04,22.14},{493.66,45.93},{487.62,69.01},{482.82,91.35},{479.17,112.9},
    {476.57,133.63},{474.93,153.51},{474.14,172.49},{474.12,190.54},{474.76,207.63},
    {475.97,223.71},{477.65,238.76},{479.71,252.73},{482.05,265.59},{484.57,277.31},
    {487.18,287.83},{489.78,297.14},{492.28,305.19},{494.57,311.95},{496.56,317.37},
    {488.42,328.02},{478.85,340.03},{469.67,352.33},{460.88,364.94},{452.49,377.84},
    {444.51,391.04},{436.96,404.54},{429.83,418.34},{423.15,432.45},{416.92,446.85},
    {411.14,461.56},{405.84,476.57},{401.01,491.88},{396.67,507.5},{392.82,523.41},
    {389.48,539.63},{386.66,556.16},{384.36,572.99},{382.59,590.12},{381.37,607.56},
    {380.7,625.31},{380.59,645.48},{381.02,670.04},{381.96,693.89},{383.42,717.06},
    {385.37,739.54},{387.81,761.35},{390.74,782.51},{394.12,803.01},{397.97,822.87},
    {402.27,842.1},{407.0,860.72},{412.16,878.72},{417.73,896.13},{423.72,912.96},
    {430.09,929.2},{436.86,944.88},{444.0,960.0},{451.51,974.58},{459.37,988.62},
    {467.57,1002.14},{476.12,1015.15},{484.98,1027.65},{494.16,1039.66},{503.64,1051.18},
    {513.42,1062.24},{523.48,1072.83},{533.82,1082.97},{544.41,1092.67},{555.26,1101.94},
    {566.36,1110.79},{577.68,1119.23},{589.23,1127.27},{600.99,1134.93},{612.95,1142.2},
    {625.1,1149.11},{637.43,1155.66},{649.93,1161.87},{662.59,1167.74},{675.41,1173.28},
    {688.36,1178.51},{701.44,1183.44},{714.65,1188.07},{727.96,1192.41},{741.37,1196.49},
    {754.87,1200.3},{768.44,1203.85},{782.09,1207.17},{795.79,1210.26},{809.54,1213.12},
    {823.33,1215.77},{837.14,1218.23},{850.98,1220.49},{864.81,1222.58},{878.65,1224.49},
    {892.47,1226.25},{894.32,1227.0},{891.69,1228.72},{887.26,1231.73},{881.24,1236.01},
    {873.81,1241.54},{865.15,1248.3},{855.46,1256.27},{844.94,1265.44},{833.76,1275.78},
    {822.11,1287.28},{810.2,1299.91},{798.19,1313.67},{786.3,1328.53},{774.7,1344.46},
    {763.58,1361.47},{753.14,1379.51},{743.57,1398.58},{735.04,1418.66},{727.76,1439.72},
    {721.91,1461.76},{717.68,1484.75},{715.26,1508.66},{712.76,1526.9},{705.25,1530.27},
    {696.45,1533.95},{686.46,1537.88},{675.36,1541.99},{663.24,1546.18},{650.17,1550.4},
    {636.25,1554.57},{621.56,1558.6},{606.18,1562.43},{590.19,1565.98},{573.69,1569.17},
    {556.76,1571.93},{539.48,1574.19},{521.93,1575.86},{504.2,1576.87},{486.38,1577.15},
    {468.54,1576.62},{450.78,1575.2},{433.18,1572.83},{415.82,1569.42},{398.79,1564.89},
    {382.17,1559.19},{366.05,1552.22},{350.51,1543.91},{335.63,1534.2},{321.5,1522.99},
    {308.21,1510.22},{295.83,1495.82},{284.46,1479.7},{277.31,1467.65},{275.74,1464.81},
    {272.26,1458.98},{266.9,1450.69},{259.67,1440.45},{250.59,1428.77},{239.67,1416.18},
    {226.91,1403.19},{212.35,1390.32},{195.98,1378.09},{177.83,1367.01},{157.9,1357.61},
    {136.21,1350.4},{112.78,1345.89},{102.34,1345.08},{93.05,1345.56},{79.71,1347.4},
    {66.1,1351.49},{56.0,1358.74},{53.2,1370.04},{61.48,1386.31},{84.62,1408.43},
    {97.13,1417.76},{99.77,1419.26},{104.45,1422.23},{110.93,1426.8},{118.98,1433.15},
    {128.37,1441.42},{138.86,1451.78},{150.21,1464.37},{162.2,1479.35},{174.59,1496.88},
    {187.14,1517.11},{199.63,1540.21},{211.81,1566.31},{222.06,1591.8},{222.23,1592.62},
    {222.72,1594.68},{223.56,1597.9},{224.8,1602.18},{226.47,1607.43},{228.62,1613.56},
    {231.29,1620.48},{234.51,1628.08},{238.34,1636.29},{242.81,1645.01},{247.96,1654.15},
    {253.83,1663.61},{260.47,1673.31},{267.92,1683.14},{276.21,1693.03},{285.4,1702.87},
    {295.51,1712.58},{306.59,1722.06},{318.68,1731.23},{331.83,1739.98},{346.08,1748.23},
    {361.45,1755.89},{378.01,1762.85},{395.78,1769.04},{414.81,1774.36},{435.14,1778.72},
    {456.81,1782.02},{479.87,1784.17},{504.35,1785.08},{530.29,1784.67},{557.74,1782.82},
    {586.74,1779.47},{617.32,1774.51},{649.54,1767.84},{683.42,1759.39},{711.39,1751.78},
    {712.38,1757.39},{713.04,1768.89},{713.42,1784.98},{713.58,1804.38},{713.56,1825.79},
    {713.43,1847.93},{713.23,1869.51},{713.01,1889.23},{712.82,1905.8},{712.73,1917.94},
    {725.09,1920.0},{741.24,1920.0},{757.39,1920.0},{773.54,1920.0},{789.68,1920.0},
    {805.83,1920.0},{821.98,1920.0},{838.13,1920.0},{854.28,1920.0},{870.42,1920.0},
    {886.57,1920.0},{902.72,1920.0},{918.87,1920.0},{935.02,1920.0},{951.17,1920.0},
    {967.31,1920.0},{983.46,1920.0},{999.61,1920.0},{1015.76,1920.0},{1031.91,1920.0},
    {1048.05,1920.0},{1064.2,1920.0},{1080.35,1920.0},{1096.5,1920.0},{1112.65,1920.0},
    {1128.79,1920.0},{1144.94,1920.0},{1161.09,1920.0},{1177.24,1920.0},{1193.39,1920.0},
    {1209.53,1920.0},{1225.68,1920.0},{1241.83,1920.0},{1257.98,1920.0},{1274.13,1920.0},
    {1290.27,1920.0},{1306.42,1920.0},{1322.57,1920.0},{1338.72,1920.0},{1354.87,1920.0},
    {1371.01,1920.0},{1387.16,1920.0},{1403.31,1920.0},{1419.46,1920.0},{1435.61,1920.0},
    {1451.75,1920.0},{1467.9,1920.0},{1484.05,1920.0},{1489.9,1919.35},{1489.92,1915.82},
    {1489.94,1909.43},{1489.98,1900.43},{1490.04,1889.06},{1490.1,1875.55},{1490.16,1860.17},
    {1490.24,1843.13},{1490.31,1824.69},{1490.4,1805.09},{1490.48,1784.57},{1490.56,1763.37},
    {1490.65,1741.74},{1490.73,1719.9},{1490.81,1698.12},{1490.89,1676.63},{1490.96,1655.66},
    {1491.02,1635.47},{1491.07,1616.29},{1491.12,1598.37},{1491.15,1581.95},{1491.17,1567.27},
    {1491.18,1554.16},{1490.43,1528.35},{1488.34,1503.9},{1485.01,1480.78},{1480.54,1458.94},
    {1475.03,1438.34},{1468.58,1418.95},{1461.3,1400.71},{1453.28,1383.59},{1444.63,1367.55},
    {1435.46,1352.54},{1425.85,1338.52},{1415.92,1325.45},{1405.76,1313.3},{1395.47,1302.01},
    {1385.17,1291.54},{1374.95,1281.86},{1364.91,1272.93},{1355.15,1264.69},{1345.77,1257.12},
    {1336.89,1250.16},{1328.59,1243.78},{1320.98,1237.93},{1314.17,1232.58},{1308.25,1227.68},
    {1313.49,1224.69},{1327.35,1222.91},{1341.22,1220.98},{1355.09,1218.87},{1368.94,1216.58},
    {1382.78,1214.1},{1396.58,1211.42},{1410.34,1208.53},{1424.05,1205.41},{1437.7,1202.06},
    {1451.28,1198.46},{1464.77,1194.61},{1478.17,1190.49},{1491.46,1186.1},{1504.65,1181.42},
    {1517.71,1176.44},{1530.63,1171.15},{1543.41,1165.55},{1556.04,1159.62},{1568.5,1153.34},
    {1580.79,1146.72},{1592.89,1139.74},{1604.8,1132.38},{1616.5,1124.64},{1627.99,1116.51},
    {1639.25,1107.98},{1650.28,1099.04},{1661.06,1089.67},{1671.58,1079.86},{1681.83,1069.61},
    {1691.81,1058.91},{1701.5,1047.73},{1710.9,1036.08},{1719.98,1023.95},{1728.75,1011.31},
    {1737.19,998.17},{1745.29,984.51},{1753.05,970.32},{1760.44,955.58},{1767.47,940.3},
    {1774.12,924.45},{1780.37,908.04},{1786.23,891.04},{1791.68,873.45},{1796.71,855.25},
    {1801.3,836.44},{1805.46,817.0},{1809.17,796.93},{1812.41,776.22},{1815.19,754.84},
    {1817.48,732.8},{1819.28,710.09},{1820.58,686.68},{1821.36,662.57},{1821.63,637.76},
}
local SVG_MIN_X  = 53.2
local SVG_WIDTH  = 1768.43
local SVG_HEIGHT = 1919.98

local T_CAT_START     = 2.0
local T_CAT_END       = 7.0
local T_SCATTER_START = 9.0
local T_GIRL_START    = 2.5
local T_GIRL_FULL     = 7.0
local T_FOG_START     = 11.0
local T_FOG_FULL      = 13.0
local T_TEXT_SHOW     = 3.0
local T_TEXT_FULL     = 6.5
local T_DARK_START    = 9.6
local T_DARK_FULL     = 10.8
local T_TEXT_SLIDE    = 10.85
local T_TEXT_GONE     = 11.8
local T_TOTAL         = 15.0

local SCATTER_XN = 0.50

local GIRL_ASSET = "rbxassetid://86183713641869"

local function sStep(e0, e1, x)
    local t = math.clamp((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)
end
local function lerpN(a, b, t) return a + (b - a) * t end

local _RS  = game:GetService("RunService")
local _TS  = game:GetService("TweenService")
local _LP  = game:GetService("Players").LocalPlayer

local _cam = workspace.CurrentCamera
local _vp  = _cam and _cam.ViewportSize or Vector2.new(1366, 768)
local vpW, vpH = _vp.X, _vp.Y

local scaleRatio = math.clamp(vpW / 1920, 0.6, 1.3)

local bigFsz  = math.floor(36 * scaleRatio)

local catS = (vpW * 0.12) / SVG_WIDTH

local bgF = loadBg
bgF.Size                   = UDim2.new(1,0,1,0)
bgF.BackgroundColor3       = Color3.fromRGB(0,0,0)
bgF.BackgroundTransparency = 0
bgF.BorderSizePixel        = 0
bgF.ZIndex                 = 0

local SVG_MAX_X = SVG_MIN_X + SVG_WIDTH
local rawCX = SVG_MIN_X + SVG_WIDTH * 0.5
local rawCY = SVG_HEIGHT * 0.5
local noseDist = SVG_MAX_X - rawCX
local textLeftEdge = vpW * 0.375

local CAT_X_OFFSET = 200 * scaleRatio
local catCenterY = vpH * 0.45

local catCenterX = textLeftEdge - noseDist * catS + CAT_X_OFFSET
local offX = catCenterX - rawCX * catS
local offY = catCenterY - rawCY * catS

local vigF = Instance.new("Frame")
vigF.Size                   = UDim2.new(1,0,1,0)
vigF.BackgroundColor3       = Color3.fromRGB(0,0,0)
vigF.BackgroundTransparency = 0.86
vigF.BorderSizePixel        = 0
vigF.ZIndex                 = 1
vigF.Parent                 = iGui
local vigGrad = Instance.new("UIGradient")
vigGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(12,12,18)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(4,4,8)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
})
vigGrad.Rotation = 45
vigGrad.Parent = vigF

local partCont = Instance.new("Frame")
partCont.Size                   = UDim2.new(1,0,1,0)
partCont.BackgroundTransparency = 1
partCont.BorderSizePixel        = 0
partCont.ZIndex                 = 2
partCont.Parent                 = iGui

local girlF = Instance.new("Frame")
girlF.Size                   = UDim2.new(0.62,0,1,0)
girlF.Position               = UDim2.new(0.28,0,0,0)
girlF.AnchorPoint            = Vector2.new(0,0)
girlF.BackgroundColor3       = Color3.fromRGB(0,0,0)
girlF.BackgroundTransparency = 1
girlF.BorderSizePixel        = 0
girlF.ZIndex                 = 1
girlF.Parent                 = iGui

local girlImg = Instance.new("ImageLabel")
girlImg.Size               = UDim2.new(1,0,1,0)
girlImg.Image              = GIRL_ASSET
girlImg.BackgroundTransparency = 1
girlImg.ImageTransparency  = 1
girlImg.ScaleType          = Enum.ScaleType.Crop
girlImg.ZIndex             = 1
girlImg.Parent             = girlF

local girlGrad = Instance.new("UIGradient")
girlGrad.Rotation = 0
girlGrad.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0,    1),
NumberSequenceKeypoint.new(0.16, 0.45),
NumberSequenceKeypoint.new(0.38, 0),
NumberSequenceKeypoint.new(0.70, 0),
NumberSequenceKeypoint.new(0.88, 0.50),
NumberSequenceKeypoint.new(1,    1),
})
girlGrad.Parent = girlImg

local function girlEdgeStrip(name, posY, rot)
local f = Instance.new("Frame")
f.Name = name
f.BackgroundColor3 = Color3.fromRGB(0,0,0)
f.BorderSizePixel = 0
f.Size = UDim2.new(1, 0, 0.16, 0)
f.Position = UDim2.new(0, 0, posY, 0)
f.ZIndex = 3
f.Parent = girlF
local g = Instance.new("UIGradient")
g.Rotation = rot
g.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.55),
NumberSequenceKeypoint.new(1, 1),
})
g.Parent = f
return f
end
girlEdgeStrip("GirlFadeTop", 0, 90)
girlEdgeStrip("GirlFadeBottom", 0.84, 270)

local girlEdgeFade = Instance.new("Frame")
girlEdgeFade.Name = "GirlEdgeFade"
girlEdgeFade.BackgroundColor3 = Color3.fromRGB(0,0,0)
girlEdgeFade.BorderSizePixel = 0
girlEdgeFade.Size = UDim2.new(0.20, 0, 1, 0)
girlEdgeFade.Position = UDim2.new(0, 0, 0, 0)
girlEdgeFade.ZIndex = 2
girlEdgeFade.Parent = girlF
local gefGrad = Instance.new("UIGradient")
gefGrad.Rotation = 0
gefGrad.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.50),
NumberSequenceKeypoint.new(1, 1),
})
gefGrad.Parent = girlEdgeFade

local nightF = Instance.new("Frame")
nightF.Size                   = UDim2.new(1,0,1,0)
nightF.BackgroundColor3       = Color3.fromRGB(0,0,0)
nightF.BackgroundTransparency = 0.90
nightF.BorderSizePixel        = 0
nightF.ZIndex                 = 1
nightF.Parent                 = girlF

local bloomF = Instance.new("Frame")
bloomF.AnchorPoint           = Vector2.new(0.5,0.5)
bloomF.Position              = UDim2.new(0.34, 0, 0.38, 0)
bloomF.Size                  = UDim2.new(0.22, 0, 0.32, 0)
bloomF.BackgroundColor3      = Color3.fromRGB(0,0,0)
bloomF.BackgroundTransparency = 1
bloomF.BorderSizePixel       = 0
bloomF.Visible               = false
bloomF.ZIndex                = 1
bloomF.Parent                = iGui
local bloomGrad = Instance.new("UIGradient")
bloomGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(190,105,255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100,30,225)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
})
bloomGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   0.34),
    NumberSequenceKeypoint.new(0.55, 0.72),
    NumberSequenceKeypoint.new(1,   1),
})
bloomGrad.Rotation = 0
bloomGrad.Parent = bloomF
local bloomCorner = Instance.new("UICorner")
bloomCorner.CornerRadius = UDim.new(0.5,0)
bloomCorner.Parent = bloomF

local introBloom = Instance.new("BloomEffect")
introBloom.Intensity = 1.35
introBloom.Size = 20
introBloom.Threshold = 0.62
introBloom.Parent = game:GetService("Lighting")

local textLbl = Instance.new("TextLabel")
textLbl.Name                = "IntroText"
textLbl.AnchorPoint         = Vector2.new(0.5,0.5)
textLbl.Position            = UDim2.new(0.50, 0, 0.45, 0)
textLbl.Size                = UDim2.new(0.25, 0, 0.07, 0)
textLbl.BackgroundTransparency = 1
textLbl.Text                = "BY RGPLUGG"
textLbl.Font                = Enum.Font.GothamBold
textLbl.TextScaled          = false
textLbl.TextSize              = bigFsz
textLbl.TextColor3          = Color3.fromRGB(200,200,200)
textLbl.TextTransparency    = 1
textLbl.ZIndex              = 4
textLbl.Parent              = iGui
local textDissolveGrad = Instance.new("UIGradient")
textDissolveGrad.Rotation = 0
textDissolveGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   0),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(1,   1),
})
textDissolveGrad.Parent = textLbl
local fogF = Instance.new("Frame")
fogF.Size                   = UDim2.new(1,0,1,0)
fogF.BackgroundColor3       = Color3.fromRGB(0,0,0)
fogF.BackgroundTransparency = 1
fogF.BorderSizePixel        = 0
fogF.ZIndex                 = 1
fogF.Parent                 = iGui
local fogGrad = Instance.new("UIGradient")
fogGrad.Rotation = 270
fogGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   0.0),
    NumberSequenceKeypoint.new(0.40, 0.50),
    NumberSequenceKeypoint.new(0.75, 0.85),
    NumberSequenceKeypoint.new(1,   1.0),
})
fogGrad.Parent = fogF

local darkOverlay = Instance.new("Frame")
darkOverlay.Name = "BlackFadeOverlay"
darkOverlay.Size = UDim2.new(1,0,1,0)
darkOverlay.Position = UDim2.new(0,0,0,0)
darkOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
darkOverlay.BackgroundTransparency = 1
darkOverlay.BorderSizePixel = 0
darkOverlay.Active = true
darkOverlay.Visible = true
darkOverlay.ClipsDescendants = false
darkOverlay.ZIndex = 3
darkOverlay.Parent = iGui
textLbl.ZIndex = 4

local catParts = {}
local n = #CAT_RAW

for i = 1, n do
    local rx, ry = CAT_RAW[i][1], CAT_RAW[i][2]
    local cx = rx * catS + offX
    local cy = ry * catS + offY
    local pathProg = (i - 1) / (n - 1)
    local svgXN    = (rx - SVG_MIN_X) / SVG_WIDTH
    local isRight  = svgXN > SCATTER_XN
    local isLeft   = not isRight
    local density  = isRight and 1 or 1
    density = density + math.random(0, 0)

    for d = 1, density do
        if math.random() < 0.15 then continue end

        local sz    = 1.0 + math.random() * 4.8
        local depth = 0.72 + math.random() * 0.28
        local p = {
            baseX = cx, baseY = cy,
            x = cx,     y = cy,
            size  = sz,  depth = depth,
            baseOp     = 0.55 + math.random() * 0.15,
            jX         = (math.random() - 0.5) * 15,
            jY         = (math.random() - 0.5) * 15,
            driftAngle = math.random() * math.pi * 2,
            driftSpeed = 0.08 + math.random() * 0.22,
            driftR     = 3.0  + math.random() * 7.0,
            flickPhase = math.random() * math.pi * 2,
            flickSpeed = 0.8  + math.random() * 2.5,
            flickAmt   = 0.04 + math.random() * 0.18,
            blinkPhase = math.random() * math.pi * 2,
            blinkSpeed = 0.3 + math.random() * 0.5,
            blinkAmt   = 0.06 + math.random() * 0.08,
            driftPhase = math.random() * math.pi * 2,
            revealTime = T_CAT_START
                         + pathProg * (T_CAT_END - T_CAT_START)
                         + (math.random() - 0.5) * 0.35
                         + d * 0.015,
            appearDur  = 0.25 + math.random() * 0.5,
            pathProg   = pathProg,
            isRight    = isRight,
            isLeft     = isLeft,
            scatterDelay = isRight and math.random() * 0.85 or 0,
            revealed    = false,
            expired     = false,
            scattered  = false,
            scatterLife = 0,
            scatterMax  = 1.2 + math.random() * 2.2,
            vx = 0, vy = 0,
            isFront    = math.random() < 0.22,
        }

        local lbl = Instance.new("ImageLabel")
        lbl.BackgroundTransparency = 1
        lbl.AnchorPoint        = Vector2.new(0.5,0.5)
        lbl.Image              = "rbxassetid://109179504750572"
        lbl.ImageTransparency  = 1
        local cr = math.floor(125 + math.random() * 32)
        local cg = math.floor(92 + math.random() * 32)
        lbl.ImageColor3 = Color3.fromRGB(cr, cg, math.floor(205 + math.random() * 35))
        local s2 = sz * depth
        local pxSz = math.max(3, math.floor(s2 * 3.2))
        lbl.Size     = UDim2.new(0, pxSz, 0, pxSz)
        lbl.ScaleType = Enum.ScaleType.Fit
        local pSX = (cx + p.jX) / vpW
        local pSY = (cy + p.jY) / vpH
        lbl.Position = UDim2.new(pSX, 0, pSY, 0)
        local grey = math.random(140, 240)
        lbl.ImageColor3 = Color3.fromRGB(grey, grey, grey)
        lbl.ZIndex   = 2
        lbl.Parent   = partCont
        p.lbl = lbl

        catParts[#catParts + 1] = p
    end
end

local lastPX, lastPY = {}, {}
local lastPT = {}
for idx = 1, #catParts do
    lastPX[idx] = -999999
    lastPY[idx] = -999999
    lastPT[idx] = -1
end

local introTime = 0
local introConn
local introFinished = Instance.new("BindableEvent")
local particleAccumulator = 0
local girlTweenStarted = false
local fogTweenStarted = false
local darkTweenStarted = false
local darkTweenCompleted = false
local textIntroTweenStarted = false
local textFlightStarted = false

local function playIntroTween(object, duration, properties, style, onComplete)
    if object and object.Parent then
        local tween = TweenService:Create(object,
            TweenInfo.new(duration, style or Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out),
            properties)
        if onComplete then
            tween.Completed:Connect(onComplete)
        end
        tween:Play()
        return tween
    end
    return nil
end

introConn = _RS.Heartbeat:Connect(function(dt)
    introTime = math.min(introTime + dt, T_TOTAL + 1)
    local t = introTime

    if not girlTweenStarted and t >= T_GIRL_START then
        girlTweenStarted = true
        playIntroTween(girlImg, T_GIRL_FULL - T_GIRL_START,
            {ImageTransparency = 0}, Enum.EasingStyle.Sine)
        playIntroTween(nightF, T_GIRL_FULL - T_GIRL_START,
            {BackgroundTransparency = 0.88}, Enum.EasingStyle.Sine)
    end
    if not textIntroTweenStarted and t >= T_TEXT_SHOW then
        textIntroTweenStarted = true
        playIntroTween(textLbl, T_TEXT_FULL - T_TEXT_SHOW,
            {TextTransparency = 0}, Enum.EasingStyle.Sine)
    end
    if not fogTweenStarted and t >= T_FOG_START then
        fogTweenStarted = true
        playIntroTween(fogF, T_FOG_FULL - T_FOG_START,
            {BackgroundTransparency = 0.10}, Enum.EasingStyle.Sine)
    end
    if not darkTweenStarted and t >= T_DARK_START then
        darkTweenStarted = true
        playIntroTween(darkOverlay, T_DARK_FULL - T_DARK_START,
            {BackgroundTransparency = 0}, Enum.EasingStyle.Sine,
            function(playbackState)
                if playbackState ~= Enum.PlaybackState.Completed
                    or darkTweenCompleted then
                    return
                end
                darkTweenCompleted = true
                darkOverlay.BackgroundTransparency = 0
                if textFlightStarted then return end
                textFlightStarted = true

                playIntroTween(textLbl, T_TEXT_GONE - T_TEXT_SLIDE,
                    {
                        TextTransparency = 1,
                    }, Enum.EasingStyle.Quint)
                textDissolveGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,   0),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(1,   1),
                })
                local dissDur = T_TEXT_GONE - T_TEXT_SLIDE
                local dissT = 0
                local dissConn
                dissConn = _RS.Heartbeat:Connect(function(dt)
                    dissT = math.min(dissT + dt, dissDur)
                    local p = dissT / dissDur
                    textDissolveGrad.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0,   p),
                        NumberSequenceKeypoint.new(0.5, p),
                        NumberSequenceKeypoint.new(1,   1),
                    })
                    if dissT >= dissDur then
                        dissConn:Disconnect()
                    end
                end)
            end)
    end

    particleAccumulator = particleAccumulator + dt
    if particleAccumulator < (1 / 30) then
        return
    end
    particleAccumulator = particleAccumulator - (1 / 30)
    for idx, p in ipairs(catParts) do
        local lbl = p.lbl
        if p.isLeft and p.revealed then
            continue
        end
        local age = t - p.revealTime

        if age < 0 then
            if lbl.ImageTransparency < 0.99 then lbl.ImageTransparency = 1 end
            continue
        end

        local apT = math.min(1, age / p.appearDur)
        local apE = apT < 0.5
                    and (2 * apT * apT)
                    or  (-1 + (4 - 2 * apT) * apT)

        local flick = 1 + math.sin(t * p.flickSpeed + p.flickPhase) * p.flickAmt
        local blink = 1 - math.sin(t * p.blinkSpeed + p.blinkPhase) * p.blinkAmt
        local driftX = math.sin(t * p.driftSpeed + p.driftPhase) * p.driftR
        local driftY = math.cos(t * p.driftSpeed * 0.7 + p.driftPhase) * p.driftR

        local px, py, finalOp

        if p.isLeft and not p.scattered then
            px = p.baseX + p.jX + driftX
            py = p.baseY + p.jY + driftY
            finalOp = p.baseOp * apE * flick * blink * p.depth
            if apT >= 1 then
                p.revealed = true
            end
            if p.revealed then
                lbl.ImageTransparency = math.clamp(1 - p.baseOp * p.depth, 0, 1)
                continue
            end
        elseif p.scattered then
            p.scatterLife = p.scatterLife + dt
            if p.scatterLife >= p.scatterMax then
                lbl.ImageTransparency = 1
                p.expired = true
                continue
            end
            local sl = p.scatterLife
            px = p.baseX + p.jX + p.vx * sl + driftX * 0.3
            py = p.baseY + p.jY + p.vy * sl + 18 * sl * sl + driftY * 0.3
            local st  = sl / p.scatterMax
            local scA = math.max(0, 1 - st * st)
            finalOp   = p.baseOp * apE * flick * scA * p.depth
        else
            local rightBurst = p.isRight
                and t > T_SCATTER_START
                and t > T_SCATTER_START + p.scatterDelay * 0.55
            if rightBurst and not p.scattered then
                    p.scattered = true
                    local angle
                    local speed
                    angle = math.random() * math.pi * 2
                    speed = 75 + math.random() * 125
                    p.vx = math.cos(angle) * speed
                    p.vy = math.sin(angle) * speed * 0.55
            end
            px = p.baseX + p.jX + driftX
            py = p.baseY + p.jY + driftY
            finalOp = p.baseOp * apE * flick * blink * p.depth
        end

        local ipx, ipy = math.floor(px), math.floor(py)
        if ipx ~= lastPX[idx] or ipy ~= lastPY[idx] then
            lbl.Position = UDim2.new(ipx / vpW, 0, ipy / vpH, 0)
            lastPX[idx] = ipx; lastPY[idx] = ipy
        end
        local nextTransparency = math.clamp(1 - finalOp, 0, 1)
        if math.abs(nextTransparency - lastPT[idx]) > 0.018 then
            lbl.ImageTransparency = nextTransparency
            lastPT[idx] = nextTransparency
        end
    end

    if t >= T_TOTAL then
        introConn:Disconnect()
        darkOverlay.BackgroundTransparency = 0
        pcall(function() partCont.Visible = false end)
        pcall(function() girlF.Visible = false end)
        pcall(function() fogF.Visible = false end)
        pcall(function() vigF.Visible = false end)
        pcall(function() bloomF.Visible = false end)
        pcall(function() textLbl.Visible = false end)
        pcall(function() partCont.Parent = nil end)
        pcall(function() girlF.Parent = nil end)
        pcall(function() fogF.Parent = nil end)
        pcall(function() vigF.Parent = nil end)
        pcall(function() bloomF.Parent = nil end)
        pcall(function() textLbl.Parent = nil end)
        pcall(function() introBloom.Parent = nil end)
        introFinished:Fire()
    end
end)

introFinished.Event:Wait()
introFinished:Destroy()
return darkOverlay
end
