--[[
    ===========================================================================
    PROJECT GLASS - ÉDITION SEQUOIA (MAC OS / IOS DESIGN)
    Développeur : Will
    Statut : V2.0 - Refonte Totale Glassmorphism, Cartes & Spring Engine
    ===========================================================================
--]]

local Library = {
    Registry = {}, 
    ToggleKey = Enum.KeyCode.RightShift,
    IsOpen = true
}
Library.__index = Library

-- [ SERVICES ROBLOX ]
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- [ SÉCURITÉ : GÉNÉRATEUR DE NOMS ALÉATOIRES ]
local function generateRandomName()
    local length = math.random(16, 24)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local randomString = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        randomString = randomString .. string.sub(chars, rand, rand)
    end
    return randomString
end

-- [ MOTEUR D'ANIMATION : SPRING (PHYSIQUE CUSTOM) ]
local Spring = {}
Spring.__index = Spring
function Spring.new(mass, damping, stiffness, initialPosition)
    local self = setmetatable({
        Target = initialPosition,
        Position = initialPosition,
        Velocity = 0,
        Mass = mass or 1,
        Damping = damping or 15,
        Stiffness = stiffness or 200
    }, Spring)
    return self
end

function Spring:Update(dt)
    local force = -self.Stiffness * (self.Position - self.Target) - self.Damping * self.Velocity
    local acceleration = force / self.Mass
    self.Velocity = self.Velocity + acceleration * dt
    self.Position = self.Position + self.Velocity * dt
    return self.Position
end

-- [ FONCTION PRINCIPALE : CRÉATION DE LA FENÊTRE ]
function Library:CreateWindow(titleText)
    local Window = {}
    local targetParent = (gethui and gethui()) or CoreGui
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = generateRandomName()
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetParent

    -- FENÊTRE PRINCIPALE (CANVASGROUP POUR CLIPPING ET OPACITÉ GLOBALE)
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = generateRandomName()
    MainFrame.Size = UDim2.new(0, 760, 0, 540) -- Format plus large (Sequoia)
    MainFrame.Position = UDim2.new(0.5, -380, 0.5, -270)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 45) -- Bleu nuit profond Apple
    MainFrame.GroupTransparency = 0.12 -- Légère translucidité globale
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14) -- Coins plus arrondis
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.5
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.85
    MainStroke.Parent = MainFrame

    -- [ SIDEBAR GAUCHE ASYMÉTRIQUE ]
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 210, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 15, 20) -- Plus sombre pour l'ancrage
    Sidebar.BackgroundTransparency = 0.3
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local AppTitle = Instance.new("TextLabel")
    AppTitle.Size = UDim2.new(1, -40, 0, 50)
    AppTitle.Position = UDim2.new(0, 20, 0, 10)
    AppTitle.BackgroundTransparency = 1
    AppTitle.Text = "✨ " .. titleText
    AppTitle.Font = Enum.Font.GothamBold
    AppTitle.TextSize = 16
    AppTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AppTitle.TextXAlignment = Enum.TextXAlignment.Left
    AppTitle.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -20, 1, -140)
    TabContainer.Position = UDim2.new(0, 10, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabContainer

    -- Profil Utilisateur (En bas de la Sidebar)
    local UserProfile = Instance.new("Frame")
    UserProfile.Size = UDim2.new(1, -20, 0, 50)
    UserProfile.Position = UDim2.new(0, 10, 1, -60)
    UserProfile.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UserProfile.BackgroundTransparency = 0.95
    UserProfile.Parent = Sidebar
    Instance.new("UICorner", UserProfile).CornerRadius = UDim.new(0, 10)

    local Avatar = Instance.new("Frame")
    Avatar.Size = UDim2.new(0, 30, 0, 30)
    Avatar.Position = UDim2.new(0, 10, 0.5, -15)
    Avatar.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
    Avatar.Parent = UserProfile
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
    local AvatarInit = Instance.new("TextLabel", Avatar)
    AvatarInit.Size = UDim2.new(1,0,1,0)
    AvatarInit.BackgroundTransparency = 1
    AvatarInit.Text = "PO"
    AvatarInit.TextColor3 = Color3.fromRGB(255,255,255)
    AvatarInit.Font = Enum.Font.GothamBold
    AvatarInit.TextSize = 12

    local UserText = Instance.new("TextLabel")
    UserText.Size = UDim2.new(1, -60, 1, 0)
    UserText.Position = UDim2.new(0, 50, 0, 0)
    UserText.BackgroundTransparency = 1
    UserText.Text = "poncipp\n<font color='#888888'>@pondot</font>"
    UserText.RichText = true
    UserText.Font = Enum.Font.GothamMedium
    UserText.TextSize = 12
    UserText.TextColor3 = Color3.fromRGB(240, 240, 240)
    UserText.TextXAlignment = Enum.TextXAlignment.Left
    UserText.Parent = UserProfile

    -- [ CONTENU DROIT ]
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -210, 1, 0)
    ContentContainer.Position = UDim2.new(0, 210, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- Barre de recherche décorative
    local SearchBar = Instance.new("Frame")
    SearchBar.Size = UDim2.new(1, -40, 0, 30)
    SearchBar.Position = UDim2.new(0, 20, 0, 20)
    SearchBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SearchBar.BackgroundTransparency = 0.7
    SearchBar.Parent = ContentContainer
    Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 8)
    local SearchText = Instance.new("TextLabel", SearchBar)
    SearchText.Size = UDim2.new(1, -30, 1, 0)
    SearchText.Position = UDim2.new(0, 30, 0, 0)
    SearchText.BackgroundTransparency = 1
    SearchText.Text = "Search"
    SearchText.TextColor3 = Color3.fromRGB(150, 150, 150)
    SearchText.Font = Enum.Font.Gotham
    SearchText.TextSize = 13
    SearchText.TextXAlignment = Enum.TextXAlignment.Left

    -- Pill Dock Décoratif (Bas)
    local PillDock = Instance.new("Frame")
    PillDock.Size = UDim2.new(0, 340, 0, 44)
    PillDock.Position = UDim2.new(0.5, -170, 1, -60)
    PillDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PillDock.BackgroundTransparency = 0.95
    PillDock.Parent = ContentContainer
    Instance.new("UICorner", PillDock).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", PillDock).Transparency = 0.85
    local PillText = Instance.new("TextLabel", PillDock)
    PillText.Size = UDim2.new(1,0,1,0)
    PillText.BackgroundTransparency = 1
    PillText.Text = "⌘   ⌥   ⇧   ⌃   App Dock Area"
    PillText.Font = Enum.Font.GothamMedium
    PillText.TextSize = 14
    PillText.TextColor3 = Color3.fromRGB(150, 160, 170)

    -- [ GESTION DE L'OUVERTURE/FERMETURE ]
    local openSpring = Spring.new(1, 15, 200, 1)
    local alphaSpring = Spring.new(1, 15, 200, 0.12)

    RunService.RenderStepped:Connect(function(dt)
        local currentScale = openSpring:Update(dt)
        local currentAlpha = alphaSpring:Update(dt)
        MainFrame.Size = UDim2.new(0, 760 * currentScale, 0, 540 * currentScale)
        MainFrame.Position = UDim2.new(0.5, -(760 * currentScale) / 2, 0.5, -(540 * currentScale) / 2)
        MainFrame.GroupTransparency = currentAlpha
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Library.ToggleKey then
            Library.IsOpen = not Library.IsOpen
            if Library.IsOpen then
                MainFrame.Visible = true
                openSpring.Target = 1
                alphaSpring.Target = 0.12
            else
                openSpring.Target = 0.90
                alphaSpring.Target = 1
                task.delay(0.3, function() if not Library.IsOpen then MainFrame.Visible = false end end)
            end
        end
    end)

    Window.FirstTab = true
    Window.Tabs = {}

    -- [ MÉTHODE : CRÉATION D'UN ONGLET ]
    function Window:CreateTab(tabName)
        local Tab = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = "    " .. tabName
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextColor3 = Color3.fromRGB(160, 170, 180)
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabContainer
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -40, 1, -140)
        Page.Position = UDim2.new(0, 20, 0, 70)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.Parent = ContentContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 16)
        PageLayout.Parent = Page

        table.insert(Window.Tabs, {Button = TabButton, Page = Page})

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(160, 170, 180)}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        if Window.FirstTab then
            Page.Visible = true
            TabButton.BackgroundTransparency = 0.9
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.FirstTab = false
        end

        -- [ SYSTÈME DE CARTES : CRÉATION D'UNE SECTION APPLE ]
        function Tab:CreateSection(sectionTitle)
            local Section = {}

            -- Titre de la section (Gris bleuté, majuscules)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, 0, 0, 20)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = "  " .. string.upper(sectionTitle)
            SectionLabel.Font = Enum.Font.GothamMedium
            SectionLabel.TextSize = 11
            SectionLabel.TextColor3 = Color3.fromRGB(130, 145, 160)
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = Page

            -- Carte de regroupement (Fond très translucide)
            local CardFrame = Instance.new("Frame")
            CardFrame.Size = UDim2.new(1, 0, 0, 0)
            CardFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            CardFrame.BackgroundTransparency = 0.96 -- 4% d'opacité max
            CardFrame.ClipsDescendants = true
            CardFrame.Parent = Page
            
            Instance.new("UICorner", CardFrame).CornerRadius = UDim.new(0, 12)
            local CardStroke = Instance.new("UIStroke", CardFrame)
            CardStroke.Thickness = 1
            CardStroke.Color = Color3.fromRGB(255, 255, 255)
            CardStroke.Transparency = 0.90

            local CardLayout = Instance.new("UIListLayout", CardFrame)
            CardLayout.SortOrder = Enum.SortOrder.LayoutOrder

            CardLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                CardFrame.Size = UDim2.new(1, 0, 0, CardLayout.AbsoluteContentSize.Y)
            end)

            -- Fonction utilitaire pour ajouter une ligne séparatrice
            local function AddSeparator()
                if #CardFrame:GetChildren() > 2 then -- Plus que le UIListLayout et le 1er composant
                    local sep = Instance.new("Frame")
                    sep.Size = UDim2.new(1, -30, 0, 1)
                    sep.Position = UDim2.new(0, 30, 0, 0)
                    sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    sep.BackgroundTransparency = 0.92
                    sep.BorderSizePixel = 0
                    sep.LayoutOrder = #CardFrame:GetChildren()
                    sep.Parent = CardFrame
                end
            end

            -- [[ COMPOSANTS INTÉGRÉS À LA CARTE ]]

            function Section:CreateButton(buttonText, callback)
                AddSeparator()
                local BtnFrame = Instance.new("TextButton")
                BtnFrame.Size = UDim2.new(1, 0, 0, 44)
                BtnFrame.BackgroundTransparency = 1
                BtnFrame.Text = "   " .. buttonText
                BtnFrame.Font = Enum.Font.GothamMedium
                BtnFrame.TextSize = 13
                BtnFrame.TextColor3 = Color3.fromRGB(230, 230, 230)
                BtnFrame.TextXAlignment = Enum.TextXAlignment.Left
                BtnFrame.LayoutOrder = #CardFrame:GetChildren()
                BtnFrame.Parent = CardFrame

                BtnFrame.MouseEnter:Connect(function()
                    TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
                end)
                BtnFrame.MouseLeave:Connect(function()
                    TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                end)
                BtnFrame.MouseButton1Click:Connect(function()
                    if callback then pcall(callback) end
                end)
            end

            function Section:CreateToggle(toggleText, defaultState, callback)
                AddSeparator()
                local ToggleState = defaultState or false
                Library.Registry[toggleText] = {State = ToggleState}

                local TglFrame = Instance.new("TextButton")
                TglFrame.Size = UDim2.new(1, 0, 0, 44)
                TglFrame.BackgroundTransparency = 1
                TglFrame.Text = "   " .. toggleText
                TglFrame.Font = Enum.Font.GothamMedium
                TglFrame.TextSize = 13
                TglFrame.TextColor3 = Color3.fromRGB(230, 230, 230)
                TglFrame.TextXAlignment = Enum.TextXAlignment.Left
                TglFrame.LayoutOrder = #CardFrame:GetChildren()
                TglFrame.Parent = CardFrame

                -- Arrière-plan du Switch
                local SwitchBg = Instance.new("Frame")
                SwitchBg.Size = UDim2.new(0, 40, 0, 22)
                SwitchBg.Position = UDim2.new(1, -55, 0.5, -11)
                SwitchBg.BackgroundColor3 = ToggleState and Color3.fromRGB(10, 132, 255) or Color3.fromRGB(60, 60, 60)
                SwitchBg.Parent = TglFrame
                Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

                -- Indicateur (Bille blanche)
                local Indicator = Instance.new("Frame")
                Indicator.Size = UDim2.new(0, 18, 0, 18)
                Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Indicator.Parent = SwitchBg
                Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

                -- SPRING PHYSICS POUR L'INDICATEUR
                local tglSpring = Spring.new(1, 14, 180, ToggleState and 1 or 0)
                
                RunService.RenderStepped:Connect(function(dt)
                    local val = tglSpring:Update(dt)
                    -- Interpolation de X: de 2 (G) à 20 (D)
                    Indicator.Position = UDim2.new(0, 2 + (18 * val), 0.5, -9)
                end)

                local function FireToggle(state)
                    ToggleState = state
                    Library.Registry[toggleText].State = ToggleState
                    tglSpring.Target = ToggleState and 1 or 0
                    TweenService:Create(SwitchBg, TweenInfo.new(0.25), {
                        BackgroundColor3 = ToggleState and Color3.fromRGB(10, 132, 255) or Color3.fromRGB(60, 60, 60)
                    }):Play()
                    if callback then pcall(callback, ToggleState) end
                end

                TglFrame.MouseButton1Click:Connect(function()
                    FireToggle(not ToggleState)
                end)
            end

            function Section:CreateSlider(sliderText, min, max, default, callback)
                AddSeparator()
                local SliderValue = default or min
                Library.Registry[sliderText] = {Value = SliderValue}

                local SldFrame = Instance.new("Frame")
                SldFrame.Size = UDim2.new(1, 0, 0, 56)
                SldFrame.BackgroundTransparency = 1
                SldFrame.LayoutOrder = #CardFrame:GetChildren()
                SldFrame.Parent = CardFrame

                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -30, 0, 25)
                Title.Position = UDim2.new(0, 15, 0, 5)
                Title.BackgroundTransparency = 1
                Title.Text = sliderText
                Title.Font = Enum.Font.GothamMedium
                Title.TextSize = 13
                Title.TextColor3 = Color3.fromRGB(230, 230, 230)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = SldFrame

                local ValueText = Title:Clone()
                ValueText.TextXAlignment = Enum.TextXAlignment.Right
                ValueText.Text = tostring(SliderValue)
                ValueText.Parent = SldFrame

                local TrackBg = Instance.new("TextButton")
                TrackBg.Size = UDim2.new(1, -30, 0, 6)
                TrackBg.Position = UDim2.new(0, 15, 0, 36)
                TrackBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                TrackBg.Text = ""
                TrackBg.Parent = SldFrame
                Instance.new("UICorner", TrackBg).CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(math.clamp((SliderValue - min) / (max - min), 0, 1), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Fill.Parent = TrackBg
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                -- Poignée du slider
                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 14, 0, 14)
                Knob.Position = UDim2.new(1, -7, 0.5, -7)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Fill
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
                Instance.new("UIStroke", Knob).Color = Color3.fromRGB(200, 200, 200)

                local dragging = false
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                    SliderValue = math.floor(min + ((max - min) * pos))
                    Library.Registry[sliderText].Value = SliderValue
                    ValueText.Text = tostring(SliderValue)
                    TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                    if callback then pcall(callback, SliderValue) end
                end

                TrackBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
            end

            -- NOUVEAU : SÉLECTEUR DE SEGMENTS (Style Compact / Default / Spacious)
            function Section:CreateSegmentedControl(options, defaultIndex, callback)
                AddSeparator()
                local SegFrame = Instance.new("Frame")
                SegFrame.Size = UDim2.new(1, 0, 0, 50)
                SegFrame.BackgroundTransparency = 1
                SegFrame.LayoutOrder = #CardFrame:GetChildren()
                SegFrame.Parent = CardFrame

                local PillBg = Instance.new("Frame")
                PillBg.Size = UDim2.new(1, -30, 0, 32)
                PillBg.Position = UDim2.new(0, 15, 0.5, -16)
                PillBg.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
                PillBg.BackgroundTransparency = 0.5
                PillBg.Parent = SegFrame
                Instance.new("UICorner", PillBg).CornerRadius = UDim.new(0, 8)
                Instance.new("UIStroke", PillBg).Transparency = 0.8

                local numOptions = #options
                local btnWidth = 1 / numOptions

                -- Highlight mobile
                local Highlight = Instance.new("Frame")
                Highlight.Size = UDim2.new(btnWidth, -4, 1, -4)
                Highlight.Position = UDim2.new((defaultIndex - 1) * btnWidth, 2, 0, 2)
                Highlight.BackgroundColor3 = Color3.fromRGB(200, 210, 220) -- Couleur sable/or pâle ou blanc
                Highlight.Parent = PillBg
                Instance.new("UICorner", Highlight).CornerRadius = UDim.new(0, 6)

                local HighlightSpring = Spring.new(1, 14, 150, (defaultIndex - 1) * btnWidth)
                RunService.RenderStepped:Connect(function(dt)
                    local val = HighlightSpring:Update(dt)
                    Highlight.Position = UDim2.new(val, 2, 0, 2)
                end)

                for i, optionText in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(btnWidth, 0, 1, 0)
                    OptBtn.Position = UDim2.new((i - 1) * btnWidth, 0, 0, 0)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = optionText
                    OptBtn.Font = Enum.Font.GothamMedium
                    OptBtn.TextSize = 12
                    OptBtn.TextColor3 = i == defaultIndex and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(180, 180, 180)
                    OptBtn.Parent = PillBg

                    OptBtn.MouseButton1Click:Connect(function()
                        HighlightSpring.Target = (i - 1) * btnWidth
                        for _, child in pairs(PillBg:GetChildren()) do
                            if child:IsA("TextButton") then
                                TweenService:Create(child, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                            end
                        end
                        TweenService:Create(OptBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(20, 20, 20)}):Play()
                        if callback then pcall(callback, optionText) end
                    end)
                end
            end

            return Section
        end
       
        return Tab
    end

    return Window
end

-- [ WATERMARK & SAUVEGARDE INCHANGÉS ]
function Library:CreateWatermark(text)
    local targetParent = (gethui and gethui()) or CoreGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = generateRandomName()
    ScreenGui.Parent = targetParent

    local WatermarkFrame = Instance.new("CanvasGroup")
    WatermarkFrame.Size = UDim2.new(0, 0, 0, 26)
    WatermarkFrame.Position = UDim2.new(0, 20, 0, 20)
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 45)
    WatermarkFrame.GroupTransparency = 0.15
    WatermarkFrame.Parent = ScreenGui

    Instance.new("UICorner", WatermarkFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", WatermarkFrame).Transparency = 0.85

    local WMText = Instance.new("TextLabel")
    WMText.Size = UDim2.new(1, -16, 1, 0)
    WMText.Position = UDim2.new(0, 8, 0, 0)
    WMText.BackgroundTransparency = 1
    WMText.Text = text
    WMText.Font = Enum.Font.GothamMedium
    WMText.TextSize = 13
    WMText.TextColor3 = Color3.fromRGB(255, 255, 255)
    WMText.Parent = WatermarkFrame

    WMText:GetPropertyChangedSignal("TextBounds"):Connect(function()
        WatermarkFrame.Size = UDim2.new(0, WMText.TextBounds.X + 16, 0, 26)
    end)
    WatermarkFrame.Size = UDim2.new(0, WMText.TextBounds.X + 16, 0, 26)

    return function(newText) WMText.Text = newText end
end

function Library:SaveConfig(folderName, fileName)
    if writefile and isfolder and makefolder then
        if not isfolder(folderName) then makefolder(folderName) end
        local data = {}
        for key, element in pairs(Library.Registry) do
            data[key] = element.Value or element.State or element.Key
        end
        writefile(folderName .. "/" .. fileName .. ".json", HttpService:JSONEncode(data))
    end
end

return Library
