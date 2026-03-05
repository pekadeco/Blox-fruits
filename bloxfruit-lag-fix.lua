-- BloxFruits Lag Hub (Wind UI integration) -- Features: --  • Uses Wind UI (set WIND_UI_URL to your Wind UI raw/main.lua URL) --  • Safe, non-destructive lag fixes (disable/turn-off instead of destroy) --  • Full Black (potato) mode --  • Hide players, remove particles/trails, disable post effects, reduce lighting --  • Restore function to revert changes --  • FPS counter --  • Modular structure so you can host/obfuscate loader later

-- === CONFIG === local WIND_UI_URL = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main_example.lua'))()" -- <- REPLACE this with your Wind UI raw main.lua link or host it local AUTO_APPLY = false -- if true, will apply the default Lag Fix on script run

-- === UTILITIES === local HttpService = game:GetService("HttpService") local RunService = game:GetService("RunService") local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local Lighting = game:GetService("Lighting") local Workspace = game:GetService("Workspace")

-- storage for restore local _STATE = { parts = {},         -- [instance] = {Color=..., Material=..., Transparency=..., CanCollide=..., LocalTransparencyModifier=...} effects = {},       -- list of postprocessing effects states objects_modified = {}, otherplayers = {},  -- stores other player original transparency states lighting = {}, appliedModes = {}, }

-- safe helper for pcall local function safeCall(fn, ...) local ok, res = pcall(fn, ...) if not ok then warn("safeCall error:", res) end return ok, res end

-- Save and modify helpers local function savePartState(part) if typeof(part) ~= "Instance" then return end if _STATE.parts[part] then return end local record = {} if part:IsA("BasePart") then record.Color = part.Color record.Material = part.Material record.Reflectance = part.Reflectance record.Transparency = part.Transparency record.LocalTransparencyModifier = (part.LocalTransparencyModifier or 0) record.CastShadow = part.CastShadow end _STATE.parts[part] = record end

local function restorePartState(part, record) if not record then return end if part:IsA("BasePart") then safeCall(function() part.Color = record.Color part.Material = record.Material part.Reflectance = record.Reflectance part.Transparency = record.Transparency if record.LocalTransparencyModifier then part.LocalTransparencyModifier = record.LocalTransparencyModifier end if record.CastShadow ~= nil then part.CastShadow = record.CastShadow end end) end end

-- Save lighting state local function saveLighting() if next(_STATE.lighting) then return end local props = {"GlobalShadows","Brightness","ClockTime","FogStart","FogEnd","Ambient","OutdoorAmbient","ColorShift_Top","ColorShift_Bottom","EnvironmentDiffuseScale","EnvironmentSpecularScale"} for _,p in ipairs(props) do _STATE.lighting[p] = Lighting[p] end -- Save postprocess effects for _, eff in ipairs(Lighting:GetChildren()) do if eff:IsA("PostEffect") or eff:IsA("Atmosphere") or eff:IsA("Sky") then _STATE.effects[eff] = {ClassName = eff.ClassName, Enabled = (eff.Enabled ~= false)} end end end

local function restoreLighting() for k,v in pairs(_STATE.lighting) do safeCall(function() Lighting[k] = v end) end for eff, rec in pairs(_STATE.effects) do if eff and eff.Parent then safeCall(function() eff.Enabled = rec.Enabled end) end end end

-- === LAG FIX IMPLEMENTATIONS ===

-- Basic safe lag fix: disables heavy effects and reduces quality local function basicLagFix() saveLighting() -- Disable most post-processing effects (don't destroy) for _, obj in ipairs(Lighting:GetChildren()) do if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("BlurEffect") then _STATE.effects[obj] = {Enabled = (obj.Enabled ~= false)} safeCall(function() obj.Enabled = false end) end end -- Disable atmosphere & sky: set to defaults/disable for _, eff in ipairs({"Atmosphere","Sky"}) do for _, child in ipairs(Lighting:GetChildren()) do if child.ClassName == eff then _STATE.effects[child] = {Enabled = (child.Enabled ~= false)} safeCall(function() child.Enabled = false end) end end end

-- Lighting properties
safeCall(function()
    Lighting.GlobalShadows = false
    Lighting.FogStart = 1e9
    Lighting.FogEnd = 1e9
    Lighting.Brightness = 0
    Lighting.ClockTime = 14
    Lighting.Ambient = Color3.new(0,0,0)
end)

-- Reduce rendering quality
pcall(function()
    if settings and settings().Rendering then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    end
end)

-- Disable particle-like objects and trails safely (set lifetime to 0 or enabled false)
for _, inst in ipairs(Workspace:GetDescendants()) do
    if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
        _STATE.objects_modified[inst] = _STATE.objects_modified[inst] or {Enabled = inst.Enabled}
        safeCall(function() inst.Enabled = false end)
    end
end

-- Make terrain water less expensive
if workspace:FindFirstChildOfClass("Terrain") then
    pcall(function()
        local t = workspace:FindFirstChildOfClass("Terrain")
        -- No destructive changes; just lower water transparency effect
        -- NOTE: If you want to change wave size or materials, uncomment and test
        -- t.WaveSize = 0
        -- t.WaveSpeed = 0
    end)
end

_STATE.appliedModes.basic = true

end

-- Full black / potato mode: sets parts to black, smooth plastic, removes decals/textures appearance local function fullBlackMode() saveLighting() for _, part in ipairs(Workspace:GetDescendants()) do if part:IsA("BasePart") then savePartState(part) safeCall(function() part.Material = Enum.Material.SmoothPlastic part.Color = Color3.new(0,0,0) part.Reflectance = 0 part.Transparency = 0 part.CastShadow = false end) elseif part:IsA("Decal") or part:IsA("Texture") then _STATE.objects_modified[part] = _STATE.objects_modified[part] or {Transparency = part.Transparency} safeCall(function() part.Transparency = 1 end) elseif part:IsA("ParticleEmitter") or part:IsA("Trail") then _STATE.objects_modified[part] = _STATE.objects_modified[part] or {Enabled = part.Enabled} safeCall(function() part.Enabled = false end) end end -- Lighting: make environment dark safeCall(function() Lighting.Ambient = Color3.new(0,0,0) Lighting.OutdoorAmbient = Color3.new(0,0,0) Lighting.Brightness = 0 Lighting.GlobalShadows = false end)

_STATE.appliedModes.fullblack = true

end

-- Hide other players' character visuals (safe: only set transparency / LocalTransparencyModifier) local function hideOtherPlayers(hide) for _, pl in ipairs(Players:GetPlayers()) do if pl ~= LocalPlayer then local char = pl.Character if char then if not _STATE.otherplayers[pl] then _STATE.otherplayers[pl] = {} for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then _STATE.otherplayers[pl][part] = {Transparency = part.Transparency, LocalTransparencyModifier = (part.LocalTransparencyModifier or 0)} end end end for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then safeCall(function() if hide then part.LocalTransparencyModifier = 1 else local rec = _STATE.otherplayers[pl] and _STATE.otherplayers[pl][part] if rec then part.LocalTransparencyModifier = rec.LocalTransparencyModifier or 0 else part.LocalTransparencyModifier = 0 end end end) end end end end end end

-- Remove textures and decals (makes large impact); we do by setting transparency local function removeTextures() for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("Decal") or obj:IsA("Texture") then _STATE.objects_modified[obj] = _STATE.objects_modified[obj] or {Transparency = obj.Transparency} safeCall(function() obj.Transparency = 1 end) end end end

-- Restore everything we changed local function restoreAll() -- restore parts for part, rec in pairs(_STATE.parts) do if part and part.Parent then restorePartState(part, rec) end end _STATE.parts = {}

-- restore modified objects
for obj, rec in pairs(_STATE.objects_modified) do
    if obj and obj.Parent then
        safeCall(function()
            for k,v in pairs(rec) do
                obj[k] = v
            end
        end)
    end
end
_STATE.objects_modified = {}

-- restore other players
for pl, recs in pairs(_STATE.otherplayers) do
    local char = pl and pl.Character
    if char then
        for part, rec in pairs(recs) do
            if part and part.Parent then
                safeCall(function() part.LocalTransparencyModifier = rec.LocalTransparencyModifier or 0 end)
            end
        end
    end
end
_STATE.otherplayers = {}

-- restore lighting
restoreLighting()

_STATE.appliedModes = {}

end

-- Quick GC/cleanup helper local function quickGC() pcall(function() if collectgarbage then collectgarbage() end end) end

-- === FPS COUNTER === local fpsLabel local showFPS = false local function createFPSLabel() if fpsLabel and fpsLabel.Parent then return end fpsLabel = Instance.new("ScreenGui") fpsLabel.Name = "BF_LagHub_FPS" fpsLabel.ResetOnSpawn = false fpsLabel.Parent = game:GetService("CoreGui") local tl = Instance.new("TextLabel") tl.Size = UDim2.new(0,120,0,20) tl.Position = UDim2.new(0,5,0,5) tl.BackgroundTransparency = 1 tl.Font = Enum.Font.SourceSansBold tl.TextSize = 14 tl.TextColor3 = Color3.fromRGB(255,255,255) tl.Text = "FPS: ?" tl.Name = "BF_LagHub_FPS_Label" tl.Parent = fpsLabel local last = tick() local count = 0 RunService.RenderStepped:Connect(function() count = count + 1 if tick() - last >= 1 then tl.Text = "FPS: " .. tostring(count) count = 0 last = tick() end end) end

-- === WIND UI LOADER === local WindUI local function loadWindUI() if type(WindUI) == "table" then return WindUI end local ok, lib = pcall(function() if typeof(WIND_UI_URL) == "string" and #WIND_UI_URL > 5 then return loadstring(game:HttpGet(WIND_UI_URL))() end end) if ok and lib then WindUI = lib return lib end error("Wind UI could not be loaded. Please set WIND_UI_URL to the raw/main.lua of Wind UI or host Wind UI somewhere accessible.") end

-- === BUILD UI === local function buildUI() local UI = loadWindUI() local window = UI:CreateWindow({ Title = "BloxFruits Lag Hub", SubTitle = "WindUI edition", Size = UDim2.fromOffset(520, 360) })

local perfTab = window:CreateTab("Performance")
perfTab:CreateToggle({
    Name = "Apply Basic Lag Fix",
    Flag = "basic_lag",
    Default = false,
    Callback = function(val)
        if val then
            basicLagFix()
            quickGC()
        else
            restoreAll()
        end
    end
})

perfTab:CreateButton({
    Name = "Ultra Full Black Mode",
    Callback = function()
        fullBlackMode()
        quickGC()
    end
})

perfTab:CreateToggle({
    Name = "Hide Other Players",
    Flag = "hide_players",
    Default = false,
    Callback = function(val)
        hideOtherPlayers(val)
    end
})

perfTab:CreateButton({
    Name = "Remove Textures & Decals",
    Callback = function()
        removeTextures()
        quickGC()
    end
})

perfTab:CreateButton({
    Name = "Restore Graphics",
    Callback = function()
        restoreAll()
        quickGC()
    end
})

local visualTab = window:CreateTab("Visual")
visualTab:CreateToggle({
    Name = "Show FPS",
    Flag = "show_fps",
    Default = false,
    Callback = function(v)
        if v then
            createFPSLabel()
        else
            if fpsLabel and fpsLabel.Parent then
                fpsLabel:Destroy()
                fpsLabel = nil
            end
        end
    end
})

local settingsTab = window:CreateTab("Settings")
settingsTab:CreateButton({
    Name = "Quick GC",
    Callback = quickGC
})

settingsTab:CreateButton({
    Name = "Export Current Config (to clipboard)",
    Callback = function()
        local cfg = HttpService:JSONEncode({lighting = _STATE.lighting and true or false, appliedModes = _STATE.appliedModes})
        pcall(function() setclipboard(cfg) end)
    end
})

return window

end

-- === START === local ok, err = pcall(function() local win = buildUI() if AUTO_APPLY then basicLagFix() end end) if not ok then warn("Lag Hub init error:", err) end

-- === NOTES === -- 1) Replace WIND_UI_URL with the raw link to the Wind UI main.lua you uploaded/hosted. -- 2) This script avoids destroying objects; instead it disables/changes properties and saves original values. -- 3) To make this harder to skid: host the MAIN modules remotely and keep the loader small (loadstring from your raw link). Consider obfuscating modules on the server rather than the small loader. -- 4) I intentionally removed any webhook/logger code that the original obfuscated script had. Do NOT re-add data exfiltration.

-- If you want, I can now: --  • Obfuscate the final loader (I can show options and perform a basic obfuscation) --  • Split modules and produce a loader + hosted modules structure --  • Turn this into a GitHub-ready repo with raw links ready to load

-- Tell me if you want me to also obfuscate and/or split into loader + hosted modules and I will generate those files next.
