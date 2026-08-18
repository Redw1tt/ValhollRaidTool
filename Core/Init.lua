local addonName, VRT = ...
_G.ValhollRaidTool = VRT

VRT.modules = {}
VRT.frames = {}

function VRT:RegisterModule(name, module)
    self.modules[name] = module
end

function VRT:GetModule(name)
    return self.modules[name]
end

-- Enregistre un événement sur `frame` au tick suivant plutôt qu'immédiatement.
-- RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") peut être refusé (ADDON_ACTION_FORBIDDEN)
-- quand il est appelé depuis la pile d'exécution du chargement d'un fichier .lua ; le
-- reporter via C_Timer.After(0, ...) l'exécute dans un contexte d'exécution neuf et non
-- taint, ce qui règle le souci indépendamment de l'état de combat.
function VRT:SafeRegisterEvent(frame, event)
    C_Timer.After(0, function()
        frame:RegisterEvent(event)
    end)
end

VRT.defaultDB = {
    profileKey = "Default",
    general = {
        locked = false,
        scale = 1.0,
    },
    modules = {
        AuraTracking = { enabled = true },
        AuraSounds = { enabled = true },
        CooldownCheck = { enabled = true },
        Reminders = { enabled = true },
        Nicknames = { enabled = true },
        ReadyCheck = { enabled = true },
        Assignments = { enabled = true },
        PaceComparison = { enabled = true },
        WAImports = { enabled = true },
        VersionCheck = { enabled = true },
        BossTimelines = { enabled = true },
        EncounterAlerts = { enabled = true },
    },
    anchors = {},
    nicknames = {},
}

local function CopyDefaults(src, dst)
    dst = dst or {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event == "ADDON_LOADED" then
        if loadedAddon ~= addonName then return end
        ValhollRaidToolDB = CopyDefaults(VRT.defaultDB, ValhollRaidToolDB)
        VRT.db = ValhollRaidToolDB
    elseif event == "PLAYER_LOGIN" then
        for name, module in pairs(VRT.modules) do
            if module.OnInitialize then
                module:OnInitialize()
            end
        end
        print("|cFF25C7EB[Valholl Raid Tool]|r Chargé. Tapez |cFFFFD100/vrt|r pour les options.")
    end
end)

SLASH_VALHOLLRAIDTOOL1 = "/vrt"
SLASH_VALHOLLRAIDTOOL2 = "/valholl"
SlashCmdList["VALHOLLRAIDTOOL"] = function(msg)
    local cmd = (msg or ""):lower():trim()
    if cmd == "reset" then
        ValhollRaidToolDB = CopyDefaults(VRT.defaultDB, {})
        VRT.db = ValhollRaidToolDB
        print("|cFF25C7EB[Valholl Raid Tool]|r Configuration réinitialisée.")
    else
        local optionsUI = VRT:GetModule("Options")
        if optionsUI and optionsUI.Toggle then
            optionsUI:Toggle()
        end
    end
end
