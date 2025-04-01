local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local characterConnections = {}

local playerGui = game:GetService("CoreGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local textButton = Instance.new("TextButton")
textButton.Name = "ESPButton"
textButton.Size = UDim2.new(0, 200, 0, 50)
textButton.Position = UDim2.new(0.5, -100, 0.1, 0)
textButton.Text = "ESP: Off"
textButton.TextScaled = true
textButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
textButton.TextColor3 = Color3.new(1, 1, 1)
textButton.Parent = screenGui

local dragging = false
local dragInput, dragStart, startPos
local isESPActive = false

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    if player:FindFirstChild("Role") and player.Role.Value == "Beast" then
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
    else
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
    end
    
    player.CharacterAdded:Connect(function(newChar)
        if highlight then highlight:Destroy() end
        highlight = Instance.new("Highlight")
        highlight.Parent = newChar
        highlight.Adornee = newChar
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        if player:FindFirstChild("Role") and player.Role.Value == "Beast" then
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
        else
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
        end
    end)
    
    player.CharacterRemoving:Connect(function()
        if highlight then highlight:Destroy() end
    end)
end

local function RemoveESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

local function updateInput(input)
    if dragging then
        local delta = input.Position - dragStart
        textButton.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end

textButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = textButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

textButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

textButton.MouseButton1Click:Connect(function()
    isESPActive = not isESPActive
    
    if isESPActive then
        textButton.Text = "ESP: On"
        textButton.BackgroundColor3 = Color3.fromRGB(215, 0, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
        
        Players.PlayerAdded:Connect(function(player)
            CreateESP(player)
        end)
    else
        textButton.Text = "ESP: Off"
        textButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        RemoveESP()
    end
end)

if RunService:IsClient() then
    RunService.Heartbeat:Connect(function()
        if isESPActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Highlight") then
                    local highlight = player.Character.Highlight
                    
                    if player:FindFirstChild("Role") and player.Role.Value == "Beast" then
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
                    else
                        highlight.FillColor = Color3.fromRGB(0, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                    end
                end
            end
        end
    end)
end
