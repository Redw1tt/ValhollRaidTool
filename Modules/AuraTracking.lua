local addonName, VRT = ...

-- Suivi de buffs/debuffs choisis sur le joueur ou le groupe.
-- VRT.db.modules.AuraTracking.watched = { [spellID] = true, ... }

local AuraTracking = {}
VRT:RegisterModule("AuraTracking", AuraTracking)

local watchFrame = CreateFrame("Frame")
local activeAuras = {} -- [unit][spellID] = { expirationTime, icon, count }

function AuraTracking:IsWatched(spellID)
    local db = VRT.db.modules.AuraTracking
    return db.watched and db.watched[spellID]
end

function AuraTracking:ScanUnit(unit)
    if not UnitExists(unit) then return end
    local seen = {}

    for _, filter in ipairs({ "HELPFUL", "HARMFUL" }) do
        for i = 1, 40 do
            local aura = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex and C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
            if not aura then break end

            if self:IsWatched(aura.spellId) then
                seen[aura.spellId] = {
                    expirationTime = aura.expirationTime,
                    icon = aura.icon,
                    count = aura.applications,
                }
            end
        end
    end

    activeAuras[unit] = seen
end

function AuraTracking:GetActiveAuras(unit)
    return activeAuras[unit]
end

function AuraTracking:OnInitialize()
    local db = VRT.db.modules.AuraTracking
    if not db or not db.enabled then return end
    db.watched = db.watched or {}
end

-- Enregistré au chargement du fichier (pas dans un handler PLAYER_LOGIN retardé) :
-- s'enregistrer pendant un combat en cours peut déclencher ADDON_ACTION_FORBIDDEN.
watchFrame:RegisterEvent("UNIT_AURA")
watchFrame:SetScript("OnEvent", function(self, event, unit)
    local db = VRT.db and VRT.db.modules.AuraTracking
    if not db or not db.enabled then return end

    AuraTracking:ScanUnit(unit)
    local sounds = VRT:GetModule("AuraSounds")
    if sounds then sounds:OnAuraUpdate(unit) end
end)
