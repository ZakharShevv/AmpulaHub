local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ампула Hub",
   LoadingTitle = "Ампула Hub",
   LoadingSubtitle = "tg:@WISKASCCE",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false }
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local flyEnabled = false
local noclip = false
local bhopEnabled = false
local keepSpeed = 16
local autoclickEnabled = false
local cps = 10
local infJump = false
local fullBrightEnabled = false

-- Обновление персонажа
local function refreshCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
end
player.CharacterAdded:Connect(refreshCharacter)

-- Основное окно
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        keepSpeed = Value
        if humanoid then humanoid.WalkSpeed = Value end
    end,
})

RunService.Heartbeat:Connect(function()
    if humanoid and humanoid.WalkSpeed ~= keepSpeed then
        humanoid.WalkSpeed = keepSpeed
    end
end)

MainTab:CreateToggle({
    Name = "Toggle Fly",
    CurrentValue = false,
    Callback = function(Value)
        flyEnabled = Value
    end,
})

RunService.RenderStepped:Connect(function()
    if flyEnabled and character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local moveDir = humanoid.MoveDirection
        hrp.Velocity = Vector3.new(moveDir.X * 50, 0, moveDir.Z * 50)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hrp.Velocity = hrp.Velocity + Vector3.new(0, 50, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            hrp.Velocity = hrp.Velocity + Vector3.new(0, -50, 0)
        end
    end
end)

MainTab:CreateButton({
    Name = "Instant Respawn",
    Callback = function()
        refreshCharacter()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local spawnLocation = workspace:FindFirstChild("SpawnLocation")
            if spawnLocation then
                character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0,5,0)
            else
                character:MoveTo(Vector3.new(0,10,0))
            end
        end
    end,
})

-- Вкладка Others
local OthersTab = Window:CreateTab("Others", 4483362458)

OthersTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(Value)
        noclip = Value
    end,
})

RunService.Stepped:Connect(function()
    if noclip and character then
        for _,v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

OthersTab:CreateButton({
    Name = "ESP",
    Callback = function()
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                if not plr.Character:FindFirstChild("ESP_Highlight") then
                    local esp = Instance.new("Highlight")
                    esp.Name = "ESP_Highlight"
                    esp.FillTransparency = 1
                    esp.OutlineColor = Color3.fromRGB(255,0,0)
                    esp.OutlineTransparency = 0
                    esp.Parent = plr.Character
                end
            end
        end
    end,
})

OthersTab:CreateToggle({
    Name = "BunnyHop",
    CurrentValue = false,
    Callback = function(Value)
        bhopEnabled = Value
    end,
})

RunService.RenderStepped:Connect(function()
    if bhopEnabled and humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Вкладка Misc
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(Value)
        if Value then
            player.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
        end
    end,
})

-- Безопасный автокликер
MiscTab:CreateToggle({
    Name = "AutoClicker",
    CurrentValue = false,
    Callback = function(Value)
        autoclickEnabled = Value
    end,
})

MiscTab:CreateSlider({
    Name = "CPS",
    Range = {1, 50},
    Increment = 1,
    Suffix = "CPS",
    CurrentValue = 10,
    Callback = function(Value)
        cps = Value
    end,
})

task.spawn(function()
    while true do
        if autoclickEnabled then
            local target = mouse.Target
            if target and not target:IsDescendantOf(player.PlayerGui) then
                VirtualUser:ClickButton1(Vector2.new(0,0))
            end
            task.wait(1/cps)
        else
            task.wait(0.1)
        end
    end
end)

-- Infinite Jump
MiscTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        infJump = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if infJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Gravity
MiscTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 300},
    Increment = 10,
    Suffix = "G",
    CurrentValue = workspace.Gravity,
    Callback = function(Value)
        workspace.Gravity = Value
    end,
})

-- FullBright
MiscTab:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Callback = function(Value)
        fullBrightEnabled = Value
        if Value then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = Color3.new(0.5,0.5,0.5)
            Lighting.Brightness = 1
        end
    end,
})

-- FPS Boost (перекрашивание объектов, без удаления)
MiscTab:CreateButton({
    Name = "FPS Boost",
    Callback = function()
        for _,v in pairs(workspace:GetDescendants()) do
            if not v:IsDescendantOf(player.Character) then
                if v:IsA("Texture") or v:IsA("Decal") then
                    v.Color3 = Color3.new(0.5,0.5,0.5) -- серый цвет
                elseif v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Color = Color3.new(0.5,0.5,0.5)
                end
            end
        end
    end,
})

-- ReConnect
MiscTab:CreateButton({
    Name = "ReConnect",
    Callback = function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end,
})

Rayfield:LoadConfiguration()
