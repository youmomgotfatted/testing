local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

repeat wait() until game:IsLoaded()
wait(1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local fruitStorage = replicatedStorage:FindFirstChild("Chest") and replicatedStorage.Chest:FindFirstChild("Fruits")

local lplr = Players.LocalPlayer
local name = lplr.Name
local dname = lplr.DisplayName
local userid = lplr.UserId
local executor = identifyexecutor() or "???"
local FilePath = "TestHubSaveKingLegacy"
local SettingsFile = FilePath .. "/CombinedSettings.json"
local combinedData = {}
if not isfolder(FilePath) then
    makefolder(FilePath)
end
combinedData = {
    Settings = {
        autoskhd = true,
        autoskillsea = true,
        autoskhdhop = true,
        autocat = true,
        autobuy = true,
        dropfruit = true,
        chonkey = "Gold Key",
        KL = 1,
        slkey = 99
    }
}
local Settings = combinedData.Settings
local function loadSavedData()
    if isfile(SettingsFile) then
        local success, json = pcall(readfile, SettingsFile)
        if success then
            local decodeSuccess, decodedData = pcall(function()
                return HttpService:JSONDecode(json)
            end)
            if decodeSuccess and type(decodedData) == "table" then
                combinedData = decodedData
                Settings = combinedData.Settings
            else
                warn("Failed to decode settings: " .. tostring(decodedData))
            end
        else
            warn("Failed to read settings file: " .. tostring(json))
        end
    end
end
local function SaveSettings()
    local success, json = pcall(function()
        return HttpService:JSONEncode(combinedData)
    end)
    
    if not success then
        warn("Failed to encode settings: " .. tostring(json))
        return
    end
    local successWrite = pcall(function()
        writefile(SettingsFile, json)
    end)
    
end
loadSavedData()
local placeIdBySea = {
 [1] = 4520749081,
 [2] = 6381829480,
 [3] = 15759515082,
 [4] = 5931540094
}
local function sea(value)
    return game.PlaceId == placeIdBySea[value]
end

local function getBossRoot()
    local workspace = game:GetService("Workspace")
    local bossFolders = {workspace.SeaMonster, workspace.GhostMonster}
    local bosses = {"SeaKing", "HydraSeaKing", "Ghost Ship"}

    for _, folder in ipairs(bossFolders) do
        if folder then
            for _, bossName in ipairs(bosses) do
                local boss = folder:FindFirstChild(bossName)
                if boss and boss:FindFirstChild("HumanoidRootPart") then
                    
                    return boss.HumanoidRootPart
                end
            end
        end
    end
    return nil
end
function ClickButton(path)
    if path then
        game:GetService("GuiService").SelectedObject = path
        if game:GetService("GuiService").SelectedObject == path then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, 13, false, game)
            task.wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, 13, false, game)
        end
        task.wait()
        game:GetService("GuiService").SelectedObject = nil
    end
end
local Window = Fluent:CreateWindow({
    Title = "King Legacy - Auto Sea Boss ",
    SubTitle = "by ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})
local SeaTab = Window:AddTab({Title = "Main", Icon = "rbxassetid://4483345998"})
local selectedKey = "Copper Key"
local quantityToBuy = 1
local autoBuy = false

local keyTab = Window:AddTab({
    Title = "Key Buying",
    Icon = "rbxassetid://4483345998"
})


getgenv().AutoStoreFruit = false
local function EatFruit()
    local character = player.Character
    if not character then return end

    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function()
            local button = game.Players.LocalPlayer.PlayerGui:FindFirstChild("EatFruitBecky") 
                and game.Players.LocalPlayer.PlayerGui.EatFruitBecky:FindFirstChild("Dialogue") 
                and player.PlayerGui.EatFruitBecky.Dialogue:FindFirstChild("Collect")

            if button then
                ClickButton(button)
          
            end
        end)
    end
end
local function StoreFruit()
    spawn(function()
        while getgenv().AutoStoreFruit do
            task.wait(.5)

            local fruitStore = player.PlayerStats:FindFirstChild("FruitStore")
            local fruitStorageLimit = player.PlayerStats:FindFirstChild("FruitStorage")

            if not fruitStore or not fruitStorageLimit then
                warn("KhÃ´ng tÃ¬m tháº¥y FruitStore hoáº·c FruitStorage!")
                return
            end

            local storedFruits = game:GetService("HttpService"):JSONDecode(fruitStore.Value)
            local storageLimit = fruitStorageLimit.Value
            local backpack = player:FindFirstChild("Backpack")
            local character = player.Character

            if not backpack or not character then return end

            for _, fruit in ipairs(fruitStorage:GetChildren()) do
                if not getgenv().AutoStoreFruit then return end

                local fruitName = fruit.Name
                local currentAmount = storedFruits[fruitName] or 0

                if currentAmount < storageLimit then
                    local foundFruit = backpack:FindFirstChild(fruitName)

                    if foundFruit then
                    

                     
                        foundFruit.Parent = character
                        task.wait(0.5) 
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(300, 300))
                        task.wait(1.5) 
                        EatFruit()
game:GetService("VirtualUser"):ClickButton1(Vector2.new(300, 300))
                        task.wait(1.5) 
                        local startTime = tick()
                        while (backpack:FindFirstChild(fruitName) or character:FindFirstChild(fruitName)) and (tick() - startTime < 5) do
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end)
end
SeaTab:AddToggle("AutoDropToggle", {
    Title = "Auto Drop Fruit",
    Default = Settings.dropfruit or false,
    Callback = function(value)
        Settings.dropfruit = value
        SaveSettings()
        getgenv().AutoDrop = value
        
        local player = game:GetService("Players").LocalPlayer
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

        local function DropFruit()
            local backpack = player:FindFirstChild("Backpack")
            local character = player.Character
            if not backpack or not humanoid or not character then return end

            local equippedTool = humanoid:FindFirstChildOfClass("Tool")
            if not (equippedTool and equippedTool:FindFirstChild("FakeHandle")) then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") and tool.Name ~= "LegacyPose" then
                        humanoid:EquipTool(tool)
                        task.wait(0.5)
                        equippedTool = tool
                        break
                    end
                end
            end

            if equippedTool and equippedTool:FindFirstChild("Handle") then
                print("Äang cáº§m:", equippedTool.Name)
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(50, 50))
                wait(1) 
            end
            
            if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(50, 50))
                wait(1) 
            end

            local gui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("EatFruitBecky")
            local dropButton = gui and gui:FindFirstChild("Dialogue") and gui.Dialogue:FindFirstChild("Drop")

            if dropButton then
                ClickButton(dropButton)
            end

            wait(0.8)
        end

        spawn(function()
            while getgenv().AutoDrop do
                DropFruit()
                wait()
            end
        end)
    end
})
SeaTab:AddToggle("AutoStore",{
    Title = "Auto Store Fruit",
    Default = Settings.autocat,
    Callback = function(Value)
        Settings.autocat = Value
        SaveSettings()
        getgenv().AutoStoreFruit = Value
        if Value then
            StoreFruit()
        end
    end
})
local function Teleport()
    local selectedServer = findValidServer()
    if selectedServer then
        saveTeleportedServers(selectedServer.JobId)
        Window:Notify({
            Title = "ThÃ´ng bÃ¡o",
            Content = "Äang TÃ¬m Server",
            Duration = 3
        })
        TeleportService:TeleportToPlaceInstance(selectedServer.PlaceId, selectedServer.JobId, game.Players.LocalPlayer)
    else
        removeOldestServer()
        Window:Notify({
            Title = "ThÃ´ng bÃ¡o",
            Content = "Äang TÃ¬m Server NÃ¢ng Cao",
            Duration = 5
        })
    end
end
getgenv().AutoSeaKing = false
if sea(2) then
    SeaTab:AddToggle("AutoAim", {
        Title = "Auto Aim Skill HD+SK+GS",
        Default = Settings.autoskillsea,
        Callback = function(value)
            getgenv().AutoS = value
            Settings.autoskillsea = value
            SaveSettings()
            if not value then return end

            task.spawn(function()
                while getgenv().AutoS do
                    task.wait(0.3)
                    pcall(function()
                        local function getBossRoot()
                            local bossFolders = {workspace.SeaMonster, workspace.GhostMonster}
                            local bosses = {"SeaKing", "HydraSeaKing", "Ghost Ship"}
                            
                            for _, folder in ipairs(bossFolders) do
                                if folder then
                                    for _, bossName in ipairs(bosses) do
                                        local boss = folder:FindFirstChild(bossName)
                                        if boss and boss:FindFirstChild("HumanoidRootPart") then
                                            return boss.HumanoidRootPart
                                        end
                                    end
                                end
                            end
                            return nil
                        end

                        local skRoot = getBossRoot()
                        if not skRoot then return end

                        local function sendSkill(toolName, prefix, skill)
                            local args = {
                                [1] = prefix.."_"..toolName.."_"..skill,
                                [2] = {["MouseHit"] = skRoot.CFrame, ["Type"] = skill == "M1" and "Click" or "Down"}
                            }
                            ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer(unpack(args))
                            if skill ~= "M1" then
                                task.wait(0.05)
                                args[2].Type = "Up"
                                ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer(unpack(args))
                            end
                        end

                        local hasOpOp = lplr.Backpack:FindFirstChild("Kioru V2") ~= nil
                        local opeRoom = workspace:FindFirstChild("OpeRoom"..lplr.Name)
                        
                        if opeRoom then
                            local roomCFrame, roomSize = opeRoom.CFrame, opeRoom.Size
                            local bossOutsideCount, totalBosses = 0, 0

                            for _, boss in pairs(workspace.SeaMonster:GetChildren()) do
                                if boss:FindFirstChild("HumanoidRootPart") and boss.Name ~= "Hydra's Minion" then
                                    totalBosses += 1
                                    local bossPos = boss.HumanoidRootPart.Position
                                    local isInside = 
                                        math.abs(bossPos.X - roomCFrame.Position.X) <= roomSize.X / 2 and
                                        math.abs(bossPos.Y - roomCFrame.Position.Y) <= roomSize.Y / 2 and
                                        math.abs(bossPos.Z - roomCFrame.Position.Z) <= roomSize.Z / 2
                                    
                                    if not isInside then
                                        bossOutsideCount += 1
                                    end
                                end
                            end

                            if totalBosses > 0 and (bossOutsideCount / totalBosses) > 0.5 then
                                task.spawn(function()
                                    ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_Z", {["MouseHit"] = CFrame.new(), ["Type"] = "Down"})
                                    task.wait(0.05)
                                    ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_Z", {["MouseHit"] = CFrame.new(), ["Type"] = "Up"})
                                end)
                            end
                        else
                            task.spawn(function()
                                ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_Z", {["MouseHit"] = CFrame.new(), ["Type"] = "Down"})
                                task.wait(0.05)
                                ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_Z", {["MouseHit"] = CFrame.new(), ["Type"] = "Up"})
                            end)
                        end

                        if not hasOpOp then
                            local skills = {"M1", "Z", "X", "C", "V", "E"}
                            for _, tool in ipairs(lplr.Backpack:GetChildren()) do
                                if tool:IsA("Tool") and not tool:FindFirstChild("DevilFruit") and tool.Name ~= "Cyborg" then
                                    lplr.Character.Humanoid:EquipTool(tool)
                                    task.wait(0.2)
                                    for _, skill in ipairs(skills) do
                                        task.spawn(function()
                                            sendSkill(tool.Name, "SW", skill)
                                            sendSkill(tool.Name, "DF", skill)
                                        end)
                                    end
                                end
                            end
                        else
                            local opeSkills = {"X", "C", "V"}
                            local kioruSkills = {"M1", "Z", "X"}
                            
                            for _, skill in ipairs(opeSkills) do
                                task.spawn(function() sendSkill("OpOp", "DF", skill) end)
                            end
                            for _, skill in ipairs(kioruSkills) do
                                task.spawn(function() sendSkill("Kioru V2", "SW", skill) end)
                            end
                        end
                    end)
                end
            end)
        end
    })
    SeaTab:AddToggle("AutoTeleport", {
        Title = "Auto Teleport SK+HD+GS",
        Default = Settings.autoskhd,
        Callback = function(value)
            getgenv().AutoSeaKing = value
            
            Settings.autoskhd = value
            SaveSettings()
            if not value then return end
            
            spawn(function()
                while getgenv().AutoSeaKing do
                    pcall(function()
                        local function getBossRoot()
                            local bossFolders = {workspace.SeaMonster, workspace.GhostMonster}
                            local bosses = {"SeaKing", "HydraSeaKing", "Ghost Ship"}
                            
                            for _, folder in ipairs(bossFolders) do
                                if folder then
                                    for _, bossName in ipairs(bosses) do
                                        local boss = folder:FindFirstChild(bossName)
                                        if boss and boss:FindFirstChild("HumanoidRootPart") then
                                            return boss.HumanoidRootPart
                                        end
                                    end
                                end
                            end
                            return nil
                        end

                        local player = Players.LocalPlayer
                        local workspaceIsland = workspace.Island
                        local seaKing = workspace.SeaMonster:FindFirstChild("SeaKing")
                        local hydra = workspace.SeaMonster:FindFirstChild("HydraSeaKing")
                        local gs = workspace.GhostMonster:FindFirstChild("Ghost Ship")

                        local skHealth = seaKing and seaKing:FindFirstChild("Humanoid") and seaKing.Humanoid.Health or 0
                        local hydraHealth = hydra and hydra:FindFirstChild("Humanoid") and hydra.Humanoid.Health or 0
                        local gsHealth = gs and gs:FindFirstChild("Humanoid") and gs.Humanoid.Health or 0

                        if (not seaKing or skHealth <= 0) and (not hydra or hydraHealth <= 0) and (not gs or gsHealth <= 0) then
                            for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
                                local island = workspaceIsland:FindFirstChild(name)
                                if island and island:FindFirstChild("HydraStand") then
                                    player.Character.HumanoidRootPart.CFrame = island.HydraStand.CFrame*CFrame.new(0,0,0)
                                end
                            end                     

                            local legacyIslands = {"Legacy Island1", "Legacy Island2", "Legacy Island3", "Legacy Island4"}
                            for _, islandName in ipairs(legacyIslands) do
                                local island = workspaceIsland:FindFirstChild(islandName)
                                if island and island:FindFirstChild("ChestSpawner") then
                                    player.Character.HumanoidRootPart.CFrame = island.ChestSpawner.CFrame*CFrame.new(0,0,0)
                                end
                            end

                            local totalChests = 0
                            for i = 1, 5 do
                                if workspace:FindFirstChild("Chest" .. i) then
                                    totalChests = totalChests + 1
                                end
                            end

                            local collected = 0
                            for i = 1, 5 do
                                local chest = workspace:FindFirstChild("Chest" .. i)
                                if chest and chest:FindFirstChild("Top") then
                                    player.Character.HumanoidRootPart.CFrame = chest.Top.CFrame
                                    task.wait(0.3)
                                    collected = collected + 1
                                end
                            end

                            if collected == totalChests then
                                return
                            end
                        else
                            if getBossRoot() then
                                player.Character.HumanoidRootPart.CFrame = getBossRoot().CFrame * CFrame.new(0, -10, 100)
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    })

    SeaTab:AddToggle("AutoHop", {
        Title = "Auto Hop Sea Boss",
        Default = Settings.autoskhdhop,
        Callback = function(value)
            getgenv().SeaKinghop = value
            Settings.autoskhdhop = value
            SaveSettings()
            if not value then return end

            spawn(function()
                while getgenv().SeaKinghop do
                    task.wait(0.6)
                    local Workspace = game:GetService("Workspace")
                    local workspaceIsland = Workspace.Island
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer
                    local PlayerStats = LocalPlayer.PlayerStats
                    local MainGui = LocalPlayer.PlayerGui.MainGui
                    local SecondSea = MainGui.StarterFrame.LegacyPoseFrame.SecondSea

                    local seaKing = Workspace.SeaMonster:FindFirstChild("SeaKing")
                    local hydra = Workspace.SeaMonster:FindFirstChild("HydraSeaKing")
                    local gs = Workspace.GhostMonster:FindFirstChild("Ghost Ship")

                    local skTimeLabel = SecondSea:FindFirstChild("SKTimeLabel")
                    local gsTimeLabel = SecondSea:FindFirstChild("GSTimeLabel")

                    local function ConvertTimeToSeconds(timeStr)
                        local h, m, s = timeStr:match("(%d+):(%d+):(%d+)")
                        if h and m and s then
                            return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s)
                        end
                        return 9999
                    end

                    local skSpawnTime = skTimeLabel and ConvertTimeToSeconds(skTimeLabel.Text) or 9999
                    local gsSpawnTime = gsTimeLabel and ConvertTimeToSeconds(gsTimeLabel.Text) or 9999

                    local function spamTeleport()
                        coroutine.wrap(function()
                            while getgenv().SeaKinghop do
                                local success = pcall(function()
                                    Teleport()
                                end)
                                
                                if success then
                                    break
                                end
                                task.wait(0.2)
                            end
                        end)()
                    end

                    if skSpawnTime < 70 then
                        task.wait()
                    elseif gsSpawnTime < 70 then
                        task.wait()
                    elseif gs and gs:FindFirstChild("HumanoidRootPart") then
                        task.wait()
                    elseif getBossRoot() then
                        task.wait()
                    else
                        local hasSeaKing = false
                        
                        for _, islandName in ipairs({"Legacy Island1", "Legacy Island2", "Legacy Island3", "Legacy Island4"}) do
                            local island = workspaceIsland:FindFirstChild(islandName)
                            if island and island:FindFirstChild("ChestSpawner") then
                                hasSeaKing = true
                            end
                        end

                        local hasHydraStand = false
                        
                        for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
                            local island = workspaceIsland:FindFirstChild(name)
                            if island then
                                if island:FindFirstChild("HydraStand") then
                                    hasHydraStand = true
                                end
                            end
                        end

                        local hasGhostShipChest = false
                        local ghostShipChest = Workspace:FindFirstChild("Chest1")
                        if ghostShipChest then
                            hasGhostShipChest = true
                        end

                        if not hasSeaKing and not hasHydraStand and not hasGhostShipChest and not hydra and (not gs or not gs:FindFirstChild("HumanoidRootPart") or not seaKing:FindFirstChild("HumanoidRootPart")) then
                            spamTeleport()
                        else
                            local function hasCollectedChest()
                                local timeout = 220
                                local elapsedTime = 0

                                while elapsedTime < timeout do
                                    task.wait(0.1)
                                    elapsedTime = elapsedTime + 0.1

                                    local currentBeli = PlayerStats.beli.Value
                                    local currentGem = PlayerStats.Gem.Value

                                    if (hasSeaKing or hasSeaKingChest or hasHydraStand or hasHydraChest) and currentBeli > initialBeli and currentGem > initialGem then
                                        return true
                                    elseif hasGhostShipChest then
                                        return true
                                    end

                                    hasSeaKing = false
                                    hasSeaKingChest = false
                                    for _, islandName in ipairs({"Legacy Island1", "Legacy Island2", "Legacy Island3", "Legacy Island4"}) do
                                        local island = workspaceIsland:FindFirstChild(islandName)
                                        if island and island:FindFirstChild("ChestSpawner") then
                                            hasSeaKing = true
                                            for _, v in pairs(island.ChestSpawner:GetChildren()) do
                                                if v:IsA("Model") and v.Name:match("Chest$") then
                                                    hasSeaKingChest = true
                                                    break
                                                end
                                            end
                                        end
                                        if hasSeaKingChest then break end
                                    end

                                    hasHydraStand = false
                                    hasHydraChest = false
                                    for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
                                        local island = workspaceIsland:FindFirstChild(name)
                                        if island then
                                            if island:FindFirstChild("HydraStand") then
                                                hasHydraStand = true
                                            end
                                            for _, chest in ipairs(island:GetChildren()) do
                                                if chest:IsA("Model") and chest.Name:match("Chest$") then
                                                    hasHydraChest = true
                                                    break
                                                end
                                            end
                                        end
                                        if hasHydraChest then break end
                                    end

                                    local ghostShipChestCheck = Workspace:FindFirstChild("Chest1")
                                    if ghostShipChestCheck and ghostShipChestCheck:FindFirstChild("Top") then
                                        hasGhostShipChest = true
                                    end

                                    local seaKingCheck = Workspace.SeaMonster:FindFirstChild("SeaKing")
                                    local hydraCheck = Workspace.SeaMonster:FindFirstChild("HydraSeaKing")
                                    local gsCheck = Workspace.GhostMonster:FindFirstChild("Ghost Ship")

                                    if not hasSeaKing and not hasSeaKingChest and not hasHydraStand and not hasHydraChest and not hasGhostShipChest and not seaKingCheck and not hydraCheck and (not gsCheck or not gsCheck:FindFirstChild("HumanoidRootPart")) then
                                        return false
                                    end
                                end
                                return false
                            end

                            if hasCollectedChest() then
                                spamTeleport()
                            else
                                spamTeleport()
                            end
                        end
                    end
                end
            end)
        end
    })
end

keyTab:AddDropdown("KeyDropdown", {
    Title = "Select Key",
    Default = Settings.chonkey or "Copper Key",
    Values = {"Copper Key", "Iron Key", "Gold Key", "Platinum Key"},
    Callback = function(value)
        Settings.chonkey = value
        SaveSettings()
        selectedKey = value
    end
})
keyTab:AddSlider("KeySlider", {
    Title = "Amount Key",
    Min = 1,
    Max = 100,
    Default = Settings.slkey or 10,
    Rounding = 1,
    Callback = function(value)
        Settings.slkey = value
        SaveSettings()
        quantityToBuy = value
    end
})
keyTab:AddButton({
    Title = "Buy Key",
    Description = "",
    Callback = function()
        if selectedKey == "Platinum Key" then 
            Window:Notify({
                Title = "ThÃ´ng bÃ¡o",
                Content = "KhÃ´ng Thá»ƒ Mua Key NÃ yâŒ",
                Duration = 3
            })
        else
            local args = {
                [1] = selectedKey,
                [2] = quantityToBuy
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("BuyKey"):InvokeServer(unpack(args))
        end
    end
})
keyTab:AddToggle("AutoBuyToggle", {
    Title = "Auto Buy",
    Default = Settings.autobuy or false,
    Callback = function(state)
        if selectedKey == "Platinum Key" and state == true then 
            Window:Notify({
                Title = "ThÃ´ng bÃ¡o",
                Content = "KhÃ´ng Thá»ƒ Mua Key NÃ yâŒ",
                Duration = 3
            })
        end
        autoBuy = state
        Settings.autobuy = state
        SaveSettings()
        spawn(function()
            while task.wait(0.2) do
                if Settings.autobuy then
                    if not state then return end
                    local args = {
                        [1] = selectedKey,
                        [2] = quantityToBuy
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("BuyKey"):InvokeServer(unpack(args))
                end
            end
        end)
    end
})
keyTab:AddToggle("AutoOpenToggle", {
    Title = "Auto Open X10",
    Default = false,
    Callback = function(state)
        getgenv().autopen = state
        spawn(function()
            while task.wait() do
                if getgenv().autopen then
                    if not state then return end
                    local args = {
                        [1] = selectedKey,
                        [2] = "Open10"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("UseKey"):InvokeServer(unpack(args))
                end
            end
        end)
    end
})
