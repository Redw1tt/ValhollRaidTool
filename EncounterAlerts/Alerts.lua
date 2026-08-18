local addonName, VRT = ...

--[[
Format attendu pour chaque fichier de boss :

VRT.Alerts["MidnightS1"]["Beloren"] = {
    { trigger = "SPELL_CAST_START", spellID = nil, message = "Interrompre !", sound = nil, color = {1, 0.2, 0.2} },
}

NOTE: le déclenchement en direct via COMBAT_LOG_EVENT_UNFILTERED a été retiré.
RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") déclenche systématiquement
ADDON_ACTION_FORBIDDEN dans cet environnement (confirmé indépendant du combat,
du timing et du délai d'enregistrement — cause probable : interception de
Frame:RegisterEvent par !BugGrabber). Les données d'alertes (VRT.Alerts) restent
utilisables par d'autres modules (ex: affichage statique dans BossTimelines) ;
seul le déclenchement automatique en combat est désactivé pour l'instant.
]]

VRT.Alerts = VRT.Alerts or {}
for _, tier in ipairs(VRT.RAID_TIERS) do
    VRT.Alerts[tier] = VRT.Alerts[tier] or {}
end

local EncounterAlerts = {}
VRT:RegisterModule("EncounterAlerts", EncounterAlerts)

local activeAlerts = nil
local alertFrame = CreateFrame("Frame")

local function ShowAlertText(message, color)
    -- Fenêtre d'alerte centrale simple (texte temporaire à l'écran)
    local display = VRT.frames.AlertDisplay
    if not display then
        display = VRT.UI.CreateAnchoredWindow("ValhollAlertDisplay", "", 400, 50)
        display:SetFrameStrata("HIGH")
        display.header:Hide()
        display.text = display:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
        display.text:SetPoint("CENTER")
        VRT.frames.AlertDisplay = display
        VRT:GetModule("AnchorManager"):Register("AlertDisplay", display, "CENTER", 0, 200)
        display:Hide()
    end
    display.text:SetText(message)
    if color then
        display.text:SetTextColor(color[1], color[2], color[3])
    else
        display.text:SetTextColor(1, 1, 1)
    end
    display:Show()
    C_Timer.After(3, function() display:Hide() end)
end

function EncounterAlerts:GetAlerts(tier, boss)
    local tierData = VRT.Alerts[tier]
    return tierData and tierData[boss]
end

function EncounterAlerts:StartEncounter(tier, boss)
    activeAlerts = self:GetAlerts(tier, boss)
end

function EncounterAlerts:StopEncounter()
    activeAlerts = nil
end

alertFrame:RegisterEvent("ENCOUNTER_START")
alertFrame:RegisterEvent("ENCOUNTER_END")
alertFrame:SetScript("OnEvent", function(self, event, encounterID, encounterName, ...)
    local db = VRT.db and VRT.db.modules.EncounterAlerts
    if not db or not db.enabled then return end

    if event == "ENCOUNTER_START" then
        for tier, bosses in pairs(VRT.BOSS_LIST) do
            for _, boss in ipairs(bosses) do
                local timeline = VRT:GetModule("BossTimelines"):GetTimeline(tier, boss)
                if timeline and timeline.journalEncounterID == encounterID then
                    EncounterAlerts:StartEncounter(tier, boss)
                    return
                end
            end
        end
    elseif event == "ENCOUNTER_END" then
        EncounterAlerts:StopEncounter()
    end
end)
