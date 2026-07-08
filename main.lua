-- [[ Koji HUD: Murder Duels Absolute Combat System ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield' ))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- 핵심 리모트
local ThrowRemote = Remotes:WaitForChild("ThrowReplicate")
local HitRemote = Remotes:WaitForChild("ReportHit")

-- 상태 변수
_G.AutoKillLoop = false

-- 킬 로직 함수
local function ExecuteKill(target)
    if not target.Character or not target.Character:FindFirstChild("Head") then return end
    
    local char = target.Character
    local head = char.Head
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = myChar.HumanoidRootPart.Position
    local targetPos = head.Position
    local currentId = math.random(1, 99999)

    -- [1단계] 생성 보고
    ThrowRemote:FireServer({
        ["toolName"] = "Knife",
        ["id"] = currentId,
        ["ownerUserId"] = LocalPlayer.UserId,
        ["origin"] = myPos,
        ["isExplosive"] = false,
        ["power"] = 1,
        ["target"] = targetPos,
        ["effects"] = {Shotgun=0, Portal=0, Smoke=0, Explosive=0, Flammable=0}
    })

    -- [2단계] 적중 보고 (데미지 확정)
    HitRemote:FireServer({
        ["hitPos"] = targetPos,
        ["ownerUserId"] = LocalPlayer.UserId,
        ["origin"] = myPos,
        ["vel"] = Vector3.new(100, 100, 100),
        ["headshot"] = true,
        ["targetUserId"] = target.UserId,
        ["targetModel"] = char,
        ["to"] = targetPos,
        ["throwId"] = currentId,
        ["kind"] = "throw",
        ["at"] = tick(),
        ["hitPart"] = head
    })
end

-- UI 구성 (Koji HUD)
local Window = Rayfield:CreateWindow({
    Name = "Koji HUD | Murder Duels",
    LoadingTitle = "Koji HUD Loading...",
    LoadingSubtitle = "by Koji",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KojiHUD",
        FileName = "MurderDuels"
    }
})

local CombatTab = Window:CreateTab("Combat", 4483362458)

-- 1. 올킬 (Button): 즉시 1회 전원 처치
CombatTab:CreateButton({
    Name = "Kill All (즉시 전원 처치)",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 and not p.Character:FindFirstChildOfClass("ForceField") then
                    pcall(function() ExecuteKill(p) end)
                end
            end
        end
        Rayfield:Notify({Title = "성공", Content = "모든 플레이어를 공격했습니다."})
    end,
})

-- 2. 올킬 (자동): 5초 간격 자동 실행 토글
CombatTab:CreateToggle({
    Name = "Auto Kill (5초 자동 반복)",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoKillLoop = Value
        if Value then
            task.spawn(function()
                while _G.AutoKillLoop do
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
                            if p.Character.Humanoid.Health > 0 and not p.Character:FindFirstChildOfClass("ForceField") then
                                pcall(function() ExecuteKill(p) end)
                            end
                        end
                    end
                    task.wait(5) -- 안전을 위해 5초 간격 유지
                end
            end)
        end
    end,
})

Rayfield:Notify({ Title = "Koji HUD 가동", Content = "전투 준비가 완료되었습니다!" })
