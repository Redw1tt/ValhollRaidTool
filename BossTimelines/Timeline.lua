local addonName, VRT = ...

--[[
Format attendu pour chaque fichier de boss (rempli au fur et à mesure des kills) :

VRT.Timelines["MidnightS1"]["Beloren"] = {
    name = "Beloren",
    journalEncounterID = nil,
    phases = {
        { name = "Phase 1", events = {
            { time = 8,  spellID = nil, text = "Premier cast", duration = 4 },
            { time = 20, spellID = nil, text = "Mécanique X", duration = 0 },
        }},
    },
}
]]

VRT.Timelines = VRT.Timelines or {}
for _, tier in ipairs(VRT.RAID_TIERS) do
    VRT.Timelines[tier] = VRT.Timelines[tier] or {}
end

local BossTimelines = {}
VRT:RegisterModule("BossTimelines", BossTimelines)

local activeTimeline = nil
local encounterStart = nil
local timerFrame = CreateFrame("Frame")

function BossTimelines:GetTimeline(tier, boss)
    local tierData = VRT.Timelines[tier]
    return tierData and tierData[boss]
end

function BossTimelines:StartEncounter(tier, boss)
    local timeline = self:GetTimeline(tier, boss)
    if not timeline then return end
    activeTimeline = timeline
    encounterStart = GetTime()
end

function BossTimelines:StopEncounter()
    activeTimeline = nil
    encounterStart = nil
end

function BossTimelines:GetElapsed()
    if not encounterStart then return nil end
    return GetTime() - encounterStart
end

-- Enregistré au chargement du fichier (pas dans un handler PLAYER_LOGIN retardé) :
-- s'enregistrer pendant un combat en cours peut déclencher ADDON_ACTION_FORBIDDEN.
timerFrame:RegisterEvent("ENCOUNTER_START")
timerFrame:RegisterEvent("ENCOUNTER_END")
timerFrame:SetScript("OnEvent", function(self, event, encounterID, encounterName, ...)
    local db = VRT.db and VRT.db.modules.BossTimelines
    if not db or not db.enabled then return end

    if event == "ENCOUNTER_START" then
        for tier, bosses in pairs(VRT.BOSS_LIST) do
            for _, boss in ipairs(bosses) do
                local timeline = BossTimelines:GetTimeline(tier, boss)
                if timeline and timeline.journalEncounterID == encounterID then
                    BossTimelines:StartEncounter(tier, boss)
                    return
                end
            end
        end
    elseif event == "ENCOUNTER_END" then
        BossTimelines:StopEncounter()
    end
end)
