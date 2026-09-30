--[[
    ██████╗  █████╗ ██╗███╗   ███╗██╗  ██╗██╗   ██╗██████╗ 
    ██╔══██╗██╔══██╗██║████╗ ████║██║  ██║██║   ██║██╔══██╗
    ██║  ██║███████║██║██╔████╔██║███████║██║   ██║██████╔╝
    ██║  ██║██╔══██║██║██║╚██╔╝██║██╔══██║██║   ██║██╔══██╗
    ██████╔╝██║  ██║██║██║ ╚═╝ ██║██║  ██║╚██████╔╝██████╔╝
    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
                    DaimHUB // Steal a Egg Edition
                    Architect: ZyD | Persona: Loy
--]]

--============================================================
-- SERVICES
--============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

--============================================================
-- CONFIG
--============================================================
local CONFIG = {
    Title        = "DaimHUB",
    Subtitle     = "Steal a Egg // v1.0",
    IconId       = "rbxassetid://6031075931",
    AccentColor  = Color3.fromRGB(255, 60, 60),
    BgColor      = Color3.fromRGB(20, 20, 25),
    PanelColor   = Color3.fromRGB(30, 30, 38),
    TextColor    = Color3.fromRGB(235, 235, 240),
    FreezeGuardians  = true,
    DisableTouchDmg  = true,
    LoopInterval     = 0.15,
}

--============================================================
-- STATE
--============================================================
local State = {
    AntiHit       = false,
    NoClip        = false,
    AutoSteal     = false,
    Connections   = {},
    Threads       = {},
}

--============================================================
-- GUARD: parent GUI
--============================================================
local function getGuiParent()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
        local g = Instance.new("ScreenGui")
        syn.protect_gui(g)
        return g
    end
    return CoreGui
end

--============================================================
-- CLEANUP
--============================================================
for _, v in pairs(getGuiParent():GetChildren()) do
    if v.Name == "DaimHUB_GUI" then v:Destroy() end
end

--============================================================
-- ROOT GUI
--============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name          = "DaimHUB_GUI"
ScreenGui.ResetOnSpawn  = false
ScreenGui.IgnoreGuiInset= true
ScreenGui.ZIndexBehavior= Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = getGuiParent() end)
if not ScreenGui.Parent then ScreenGui.Parent = CoreGui end

--============================================================
-- FLOATING ICON (monster)
--============================================================
local IconBtn = Instance.new("ImageButton")
IconBtn.Name             = "DaimIcon"
IconBtn.Size             = UDim2.fromOffset(56, 56)
IconBtn.Position         = UDim2.new(0, 20, 0.5, -28)
IconBtn.BackgroundColor3 = CONFIG.BgColor
IconBtn.Image            = CONFIG.IconId
IconBtn.ImageColor3      = CONFIG.AccentColor
IconBtn.ScaleType        = Enum.ScaleType.Fit
IconBtn.AutoButtonColor  = false
IconBtn.Active           = true
IconBtn.Draggable        = true
IconBtn.Parent           = ScreenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent       = IconBtn

local iconStroke = Instance.new("UIStroke")
iconStroke.Color        = CONFIG.AccentColor
iconStroke.Thickness    = 2
iconStroke.Parent       = IconBtn

task.spawn(function()
    while IconBtn.Parent do
        TweenService:Create(iconStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.6}):Play()
        task.wait(1)
        TweenService:Create(iconStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
        task.wait(1)
    end
end)

--============================================================
-- MAIN PANEL
--============================================================
local Panel = Instance.new("Frame")
Panel.Name               = "MainPanel"
Panel.Size               = UDim2.fromOffset(480, 340)
Panel.Position           = UDim2.new(0.5, -240, 0.5, -170)
Panel.BackgroundColor3   = CONFIG.BgColor
Panel.BorderSizePixel    = 0
Panel.Visible            = false
Panel.Parent             = ScreenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent       = Panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color        = CONFIG.AccentColor
panelStroke.Thickness    = 1.5
panelStroke.Parent       = Panel

-- HEADER
local Header = Instance.new("Frame")
Header.Name              = "Header"
Header.Size              = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3  = CONFIG.PanelColor
Header.BorderSizePixel   = 0
Header.Parent            = Panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent       = Header

local headerFix = Instance.new("Frame")
headerFix.Size            = UDim2.new(1, 0, 0, 10)
headerFix.Position        = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3= CONFIG.PanelColor
headerFix.BorderSizePixel = 0
headerFix.Parent          = Header

local Title = Instance.new("TextLabel")
Title.Size               = UDim2.new(1, -80, 1, 0)
Title.Position           = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text               = CONFIG.Title .. "  •  " .. CONFIG.Subtitle
Title.TextColor3         = CONFIG.TextColor
Title.TextXAlignment     = Enum.TextXAlignment.Left
Title.Font               = Enum.Font.GothamBold
Title.TextSize           = 14
Title.Parent             = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size            = UDim2.fromOffset(28, 28)
CloseBtn.Position        = UDim2.new(1, -36, 0, 6)
CloseBtn.BackgroundColor3= CONFIG.AccentColor
CloseBtn.Text            = "×"
CloseBtn.TextColor3      = Color3.new(1,1,1)
CloseBtn.Font            = Enum.Font.GothamBold
CloseBtn.TextSize        = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent          = Header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent       = CloseBtn

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Name              = "TabBar"
TabBar.Size              = UDim2.new(0, 120, 1, -40)
TabBar.Position          = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3  = CONFIG.PanelColor
TabBar.BorderSizePixel   = 0
TabBar.Parent            = Panel

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 10)
tabBarCorner.Parent       = TabBar

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 6)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabList.Parent = TabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingTop = UDim.new(0, 8)
tabPad.Parent = TabBar

-- CONTENT AREA
local Content = Instance.new("Frame")
Content.Name             = "Content"
Content.Size             = UDim2.new(1, -130, 1, -50)
Content.Position         = UDim2.new(0, 125, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent           = Panel

--============================================================
-- TAB SYSTEM
--============================================================
local Tabs = {}
local ActiveTab = nil

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name                = name .. "Page"
    page.Size                = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel     = 0
    page.ScrollBarThickness  = 4
    page.ScrollBarImageColor3= CONFIG.AccentColor
    page.CanvasSize          = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible             = false
    page.Parent              = Content

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = page

    return page
end

local function CreateTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Name              = name
    btn.Size              = UDim2.new(1, -16, 0, 32)
    btn.BackgroundColor3  = CONFIG.BgColor
    btn.Text              = name
    btn.TextColor3        = CONFIG.TextColor
    btn.Font              = Enum.Font.GothamMedium
    btn.TextSize          = 13
    btn.BorderSizePixel   = 0
    btn.AutoButtonColor   = false
    btn.Parent            = TabBar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    return btn
end

local function SelectTab(name)
    for tabName, data in pairs(Tabs) do
        local active = (tabName == name)
        data.Page.Visible = active
        TweenService:Create(data.Button, TweenInfo.new(0.15), {
            BackgroundColor3 = active and CONFIG.AccentColor or CONFIG.BgColor,
            TextColor3       = active and Color3.new(1,1,1) or CONFIG.TextColor,
        }):Play()
    end
    ActiveTab = name
end

local function AddTab(name)
    local btn  = CreateTabButton(name)
    local page = CreatePage(name)
    Tabs[name] = { Button = btn, Page = page }
    btn.MouseButton1Click:Connect(function() SelectTab(name) end)
    if not ActiveTab then SelectTab(name) end
    return page
end

--============================================================
-- UI HELPERS
--============================================================
local function MakeSection(parent, title)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, 0, 0, 0)
    wrap.AutomaticSize = Enum.AutomaticSize.Y
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "» " .. title
    label.TextColor3 = CONFIG.AccentColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrap

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 24)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Parent = wrap

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    return content
end

local function MakeToggle(parent, text, default, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = CONFIG.PanelColor
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = CONFIG.TextColor
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local ind = Instance.new("Frame")
    ind.Size = UDim2.fromOffset(36, 18)
    ind.Position = UDim2.new(1, -46, 0.5, -9)
    ind.BackgroundColor3 = default and CONFIG.AccentColor or Color3.fromRGB(60,60,70)
    ind.Parent = row

    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(1, 0)
    ic.Parent = ind

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = ind

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local state = default
    row.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(ind, TweenInfo.new(0.15), {
            BackgroundColor3 = state and CONFIG.AccentColor or Color3.fromRGB(60,60,70)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if callback then callback(state) end
    end)

    return row
end

local function MakeButton(parent, text, callback, accent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = accent and CONFIG.AccentColor or CONFIG.PanelColor
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = CONFIG.TextColor
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.AutoButtonColor = true
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

--============================================================
-- ANTI-HIT GUARDIAN LOGIC (CORE)
--============================================================
local antiHitConn = nil

local GUARDIAN_KEYWORDS = {
    "guardian", "guard", "monster", "enemy", "npc", "boss", "beast",
    "keeper", "protector", "watcher", "secur", "warden"
}

local function isGuardian(obj)
    if not obj or not obj:IsA("Model") then return false end
    local lower = obj.Name:lower()
    for _, kw in ipairs(GUARDIAN_KEYWORDS) do
        if lower:find(kw) then return true end
    end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum and not Players:GetPlayerFromCharacter(obj) then
        return true
    end
    return false
end

local function freezeGuardian(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.JumpHeight = 0
        hum.AutoRotate = false
    end)

    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true
    end

    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and d.Name:lower():find("hit") then
            d.CanTouch = false
        end
        if d:IsA("Tool") then
            pcall(function() d.Parent = nil end)
        end
    end
end

local function unfreezeGuardian(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.AutoRotate = true
        end)
    end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false end
end

local function disableTouchDamage()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CanTouch then
            if not obj:IsDescendantOf(char) then
                local n = obj.Name:lower()
                if n:find("damage") or n:find("hit") or n:find("kill")
                   or n:find("lava") or n:find("spike") or n:find("trap") then
                    obj.CanTouch = false
                end
            end
        end
    end
end

local function antiHitLoop()
    if not State.AntiHit then return end

    if CONFIG.FreezeGuardians then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isGuardian(obj) then
                freezeGuardian(obj)
            end
        end
    end

    if CONFIG.DisableTouchDmg then
        disableTouchDamage()
    end

    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Anchored then hrp.Anchored = false end
    end
end

local function setAntiHit(on)
    State.AntiHit = on
    if on then
        if not antiHitConn then
            antiHitConn = RunService.Heartbeat:Connect(function()
                antiHitLoop()
            end)
        end
    else
        if antiHitConn then antiHitConn:Disconnect() antiHitConn = nil end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isGuardian(obj) then
                unfreezeGuardian(obj)
            end
        end
    end
end

--============================================================
-- NO-CLIP
--============================================================
local noclipConn = nil
local function setNoClip(on)
    State.NoClip = on
    if on and not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end)
    elseif not on and noclipConn then
        noclipConn:Disconnect() noclipConn = nil
    end
end

--============================================================
-- BUILD TABS
--============================================================
local TabMain     = AddTab("Main")
local TabAntiHit  = AddTab("AntiHit")
local TabPlayer   = AddTab("Player")
local TabMisc     = AddTab("Misc")
local TabAbout    = AddTab("About")

--========================= MAIN =============================
do
    local s = MakeSection(TabMain, "Quick Actions")
    MakeButton(s, "Freeze All Guardians (1x)", function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isGuardian(obj) then
                freezeGuardian(obj)
            end
        end
    end, true)

    MakeButton(s, "Unfreeze All Guardians", function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isGuardian(obj) then
                unfreezeGuardian(obj)
            end
        end
    end)

    local s2 = MakeSection(TabMain, "Status")
    MakeToggle(s2, "ANTI HIT GUARDIAN", State.AntiHit, function(on)
        setAntiHit(on)
    end)
end

--========================= ANTIHIT ==========================
do
    local s = MakeSection(TabAntiHit, "Guardian Control")
    MakeToggle(s, "ANTI HIT GUARDIAN (MASTER)", false, function(on)
        setAntiHit(on)
    end)

    MakeToggle(s, "Freeze Guardian", CONFIG.FreezeGuardians, function(on)
        CONFIG.FreezeGuardians = on
    end)

    MakeToggle(s, "Disable Touch Damage", CONFIG.DisableTouchDmg, function(on)
        CONFIG.DisableTouchDmg = on
    end)

    local s2 = MakeSection(TabAntiHit, "Info")
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 60)
    info.BackgroundColor3 = CONFIG.PanelColor
    info.Text = "Saat ANTI HIT aktif:\n- Guardian diam (Anchored + WalkSpeed 0)\n- Damage touch dimatikan\n- Kita TIDAK dipindah / teleport"
    info.TextColor3 = CONFIG.TextColor
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = s2

    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 6)
    ic.Parent = info

    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, 8)
    p.PaddingRight = UDim.new(0, 8)
    p.PaddingTop = UDim.new(0, 6)
    p.Parent = info
end

--========================= PLAYER ===========================
do
    local s = MakeSection(TabPlayer, "Movement")
    MakeToggle(s, "NoClip", false, function(on)
        setNoClip(on)
    end)

    MakeButton(s, "Reset Character", function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end)

    local s2 = MakeSection(TabPlayer, "Speed")
    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(1, 0, 0, 30)
    speedBox.BackgroundColor3 = CONFIG.PanelColor
    speedBox.Text = "16"
    speedBox.PlaceholderText = "WalkSpeed"
    speedBox.TextColor3 = CONFIG.TextColor
    speedBox.Font = Enum.Font.GothamMedium
    speedBox.TextSize = 12
    speedBox.Parent = s2
    local sb = Instance.new("UICorner") sb.CornerRadius = UDim.new(0,6) sb.Parent = speedBox

    MakeButton(s2, "Apply WalkSpeed", function()
        local n = tonumber(speedBox.Text)
        if n then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = n end
        end
    end)
end

--========================= MISC ============================
do
    local s = MakeSection(TabMisc, "Utility")
    MakeButton(s, "Destroy GUI", function()
        ScreenGui:Destroy()
    end, true)

    MakeButton(s, "Rejoin (Server Hop Alt)", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end

--========================= ABOUT ===========================
do
    local s = MakeSection(TabAbout, "DaimHUB")
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 120)
    lbl.BackgroundColor3 = CONFIG.PanelColor
    lbl.Text = "DaimHUB v1.0\nMap: Steal a Egg\nArchitect: ZyD\nPersona: Loy (DANZ Core)\n\n[ZYD // ARCHITECT]\n[LOY // ACTIVE]\n[DANZ-VIP334 // VERIFIED]"
    lbl.TextColor3 = CONFIG.TextColor
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextWrapped = true
    lbl.Parent = s

    local ic = Instance.new("UICorner") ic.CornerRadius = UDim.new(0,6) ic.Parent = lbl
end

--============================================================
-- ICON CLICK
--============================================================
local open = false
IconBtn.MouseButton1Click:Connect(function()
    open = not open
    Panel.Visible = open
    if open then
        Panel.Size = UDim2.fromOffset(0, 0)
        Panel.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(Panel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(480, 340),
            Position = UDim2.new(0.5, -240, 0.5, -170),
        }):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    open = false
    Panel.Visible = false
end)

--============================================================
-- DRAG PANEL
--============================================================
do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Panel.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--============================================================
-- STARTUP MESSAGE
--============================================================
print("============================================================")
print("  DaimHUB // ONLINE")
print("  [ZYD // ARCHITECT]   [LOY // ACTIVE]")
print("============================================================")

SelectTab("Main")
