--[[
    ===========================================================================
    PROJECT GLASS - ÉDITION PREMIUM APPLE GLASSMORPHISM (PC ONLY)
    Développeur : Will
    Statut : V1.0 - Core, Sécurité, Moteur Spring & Base UI
    ===========================================================================
--]]

local Library = {
    Registry = {}, -- Stockage des configurations
    ToggleKey = Enum.KeyCode.RightShift,
    IsOpen = true
}
Library.__index = Library

-- [ SERVICES ROBLOX ]
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService") -- Utilisé uniquement pour la couleur/transparence

-- [ SÉCURITÉ : GÉNÉRATEUR DE NOMS ALÉATOIRES (ANTI-DETECT) ]
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
    
    -- Sécurité : Injection dans HiddenUI (gethui) si disponible, sinon CoreGui
    local targetParent = (gethui and gethui()) or CoreGui
    
    -- Interface Globale
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = generateRandomName()
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetParent

    -- Fenêtre Principale (CanvasGroup pour optimiser les performances et la transparence)
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = generateRandomName()
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Fond très sombre
    MainFrame.GroupTransparency = 0.15 -- Effet Glassmorphism
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Arrondis (Apple Style)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    -- Bordure lumineuse translucide (Reflet du verre)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.88
    UIStroke.Parent = MainFrame

    -- Barre de titre et gestion du Drag (Déplacement fluide)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- Zone des Onglets (Sidebar gauche pour un look moderne)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 160, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer

    -- Zone du contenu des Onglets (A droite)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -160, 1, -40)
    ContentContainer.Position = UDim2.new(0, 160, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- [ GESTION DE L'OUVERTURE/FERMETURE (SPRING ANIMATION) ]
    local openSpring = Spring.new(1, 15, 200, 1) -- Target 1 = Ouvert (Scale 1), Target 0 = Fermé (Scale 0.8)
    local alphaSpring = Spring.new(1, 15, 200, 0.15) -- Transparence

    RunService.RenderStepped:Connect(function(dt)
        local currentScale = openSpring:Update(dt)
        local currentAlpha = alphaSpring:Update(dt)
        
        -- Application du zoom fluide
        MainFrame.Size = UDim2.new(0, 600 * currentScale, 0, 400 * currentScale)
        -- Centrage dynamique pendant le redimensionnement
        MainFrame.Position = UDim2.new(0.5, -(600 * currentScale) / 2, 0.5, -(400 * currentScale) / 2)
        -- Application de la transparence
        MainFrame.GroupTransparency = currentAlpha
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Library.ToggleKey then
            Library.IsOpen = not Library.IsOpen
            if Library.IsOpen then
                MainFrame.Visible = true
                openSpring.Target = 1
                alphaSpring.Target = 0.15 -- Retour au Glassmorphism
            else
                openSpring.Target = 0.85 -- Léger dézoom vers l'arrière
                alphaSpring.Target = 1 -- Devient invisible
                task.delay(0.3, function() if not Library.IsOpen then MainFrame.Visible = false end end)
            end
        end
    end)

    Window.FirstTab = true
    Window.Tabs = {}

    -- [ MÉTHODE : CRÉATION D'UN ONGLET ]
    function Window:CreateTab(tabName, iconId)
        local Tab = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -20, 0, 30)
        TabButton.Position = UDim2.new(0, 10, 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 1 -- Invisible par défaut
        TabButton.Text = "   " .. tabName
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabContainer

        local TabUICorner = Instance.new("UICorner")
        TabUICorner.CornerRadius = UDim.new(0, 6)
        TabUICorner.Parent = TabButton

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = ContentContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        table.insert(Window.Tabs, {Button = TabButton, Page = Page})

        -- Logique de sélection de l'onglet
        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
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


-- ZONE D INTEGRATION DES PHASES 2




--[[
    ===========================================================================
    PROJECT GLASS - PHASE 2 : COMPOSANTS (WIDGETS)
    Intégration directe dans la méthode `Window:CreateTab`
    ===========================================================================
--]]

        -- [[ 1. COMPOSANT : BUTTON ]]
        function Tab:CreateButton(buttonText, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 35)
            Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Button.BackgroundTransparency = 0.5
            Button.Text = "  " .. buttonText
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.TextColor3 = Color3.fromRGB(220, 220, 220)
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = Page

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = Button

            local UIStroke = Instance.new("UIStroke")
            UIStroke.Thickness = 1
            UIStroke.Color = Color3.fromRGB(255, 255, 255)
            UIStroke.Transparency = 0.9
            UIStroke.Parent = Button

            -- Animations Premium (Hover & Click)
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
            end)
            Button.MouseButton1Down:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 31)}):Play()
            end)
            Button.MouseButton1Up:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                if callback then pcall(callback) end
            end)
        end

        -- [[ 2. COMPOSANT : TOGGLE (INTERRUPTEUR) ]]
        function Tab:CreateToggle(toggleText, defaultState, callback)
            local ToggleState = defaultState or false
            Library.Registry[toggleText] = {State = ToggleState} -- Enregistrement Config

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            ToggleFrame.BackgroundTransparency = 0.5
            ToggleFrame.Text = "  " .. toggleText
            ToggleFrame.Font = Enum.Font.GothamMedium
            ToggleFrame.TextSize = 13
            ToggleFrame.TextColor3 = Color3.fromRGB(220, 220, 220)
            ToggleFrame.TextXAlignment = Enum.TextXAlignment.Left
            ToggleFrame.Parent = Page

            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", ToggleFrame).Transparency = 0.9

            -- L'indicateur visuel (Le switch Apple)
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Size = UDim2.new(0, 36, 0, 18)
            SwitchBg.Position = UDim2.new(1, -46, 0.5, -9)
            SwitchBg.BackgroundColor3 = ToggleState and Color3.fromRGB(10, 132, 255) or Color3.fromRGB(40, 40, 40)
            SwitchBg.Parent = ToggleFrame
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 14, 0, 14)
            Indicator.Position = ToggleState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Indicator.Parent = SwitchBg
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            local function FireToggle(state)
                ToggleState = state
                Library.Registry[toggleText].State = ToggleState
                
                -- Animation fluide du switch
                local targetColor = ToggleState and Color3.fromRGB(10, 132, 255) or Color3.fromRGB(40, 40, 40)
                local targetPos = ToggleState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                
                TweenService:Create(SwitchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = targetPos}):Play()
                
                if callback then pcall(callback, ToggleState) end
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                FireToggle(not ToggleState)
            end)

            return {
                Set = function(newState) FireToggle(newState) end
            }
        end

        -- [[ 3. COMPOSANT : SLIDER (BARRE DE RÉGLAGE) ]]
        function Tab:CreateSlider(sliderText, min, max, default, callback)
            local SliderValue = default or min
            Library.Registry[sliderText] = {Value = SliderValue}

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SliderFrame.BackgroundTransparency = 0.5
            SliderFrame.Parent = Page
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 25)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Text = sliderText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextColor3 = Color3.fromRGB(220, 220, 220)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = SliderFrame

            local ValueText = Title:Clone()
            ValueText.TextXAlignment = Enum.TextXAlignment.Right
            ValueText.Text = tostring(SliderValue)
            ValueText.Parent = SliderFrame

            local TrackBg = Instance.new("TextButton")
            TrackBg.Size = UDim2.new(1, -20, 0, 6)
            TrackBg.Position = UDim2.new(0, 10, 0, 32)
            TrackBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            TrackBg.Text = ""
            TrackBg.Parent = SliderFrame
            Instance.new("UICorner", TrackBg).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(math.clamp((SliderValue - min) / (max - min), 0, 1), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Fill.Parent = TrackBg
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

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

        -- [[ 4. COMPOSANT : KEYBIND (ASSIGNATION TOUCHE) ]]
        function Tab:CreateKeybind(bindText, defaultKey, callback)
            local CurrentKey = defaultKey or Enum.KeyCode.Unknown
            Library.Registry[bindText] = {Key = CurrentKey}

            local BindFrame = Instance.new("Frame")
            BindFrame.Size = UDim2.new(1, 0, 0, 35)
            BindFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            BindFrame.BackgroundTransparency = 0.5
            BindFrame.Parent = Page
            Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 6)

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -80, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Text = bindText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextColor3 = Color3.fromRGB(220, 220, 220)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = BindFrame

            local BindButton = Instance.new("TextButton")
            BindButton.Size = UDim2.new(0, 60, 0, 20)
            BindButton.Position = UDim2.new(1, -70, 0.5, -10)
            BindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            BindButton.Text = CurrentKey == Enum.KeyCode.Unknown and "None" or CurrentKey.Name
            BindButton.Font = Enum.Font.GothamBold
            BindButton.TextSize = 11
            BindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            BindButton.Parent = BindFrame
            Instance.new("UICorner", BindButton).CornerRadius = UDim.new(0, 4)

            local isBinding = false
            BindButton.MouseButton1Click:Connect(function()
                isBinding = true
                BindButton.Text = "..."
                BindButton.TextColor3 = Color3.fromRGB(10, 132, 255) -- Bleu Apple pendant l'écoute
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
                    isBinding = false
                    CurrentKey = input.KeyCode
                    Library.Registry[bindText].Key = CurrentKey
                    BindButton.Text = CurrentKey.Name
                    BindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                elseif not isBinding and input.KeyCode == CurrentKey and not gameProcessed then
                    if callback then pcall(callback) end
                end
            end)
        end

       
        return Tab
    end

    return Window
end

-- [ FONCTION UTILITAIRE : WATERMARK INDÉPENDANT ]
function Library:CreateWatermark(text)
    local targetParent = (gethui and gethui()) or CoreGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = generateRandomName()
    ScreenGui.Parent = targetParent

    local WatermarkFrame = Instance.new("CanvasGroup")
    WatermarkFrame.Size = UDim2.new(0, 0, 0, 26) -- S'ajustera au texte
    WatermarkFrame.Position = UDim2.new(0, 20, 0, 20)
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    WatermarkFrame.GroupTransparency = 0.15
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = WatermarkFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.88
    UIStroke.Parent = WatermarkFrame

    local WMText = Instance.new("TextLabel")
    WMText.Size = UDim2.new(1, -16, 1, 0)
    WMText.Position = UDim2.new(0, 8, 0, 0)
    WMText.BackgroundTransparency = 1
    WMText.Text = text
    WMText.Font = Enum.Font.GothamMedium
    WMText.TextSize = 13
    WMText.TextColor3 = Color3.fromRGB(255, 255, 255)
    WMText.Parent = WatermarkFrame

    -- Auto-ajustement de la taille
    WMText:GetPropertyChangedSignal("TextBounds"):Connect(function()
        WatermarkFrame.Size = UDim2.new(0, WMText.TextBounds.X + 16, 0, 26)
    end)
    -- Trigger initial
    WatermarkFrame.Size = UDim2.new(0, WMText.TextBounds.X + 16, 0, 26)

    return function(newText)
        WMText.Text = newText
    end
end

-- [ SYSTÈME DE SAUVEGARDE (CONFIG JSON) ]
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
