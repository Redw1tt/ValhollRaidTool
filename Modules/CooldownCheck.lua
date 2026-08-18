local addonName, VRT = ...

-- Liste, pour chaque membre du groupe, si ses cooldowns majeurs (définis manuellement
-- via VRT.db.modules.CooldownCheck.tracked[spellID]) sont prêts. Utile avant un pull.

local CooldownCheck = {}
VRT:RegisterModule("CooldownCheck", CooldownCheck)

function CooldownCheck:GetTrackedSpells()
    local db = VRT.db.modules.CooldownCheck
    return db.tracked or {}
end

function CooldownCheck:CheckUnit(unit)
    if not UnitExists(unit) then return {} end
    local results = {}
    for spellID in pairs(self:GetTrackedSpells()) do
        local cooldownInfo = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(spellID)
        if cooldownInfo then
            local ready = cooldownInfo.startTime == 0 or (cooldownInfo.startTime + cooldownInfo.duration) <= GetTime()
            results[spellID] = ready
        end
    end
    return results
end

-- Retourne la liste des joueurs du groupe qui n'ont pas tous leurs cooldowns suivis prêts
-- Note: seuls les cooldowns du joueur local sont consultables via l'API client;
-- pour les autres membres du groupe, cela nécessitera le module Comms (à venir).
function CooldownCheck:CheckGroup()
    local notReady = {}
    local results = self:CheckUnit("player")
    for spellID, ready in pairs(results) do
        if not ready then
            table.insert(notReady, { name = UnitName("player"), spellID = spellID })
        end
    end
    return notReady
end

function CooldownCheck:OnInitialize()
    local db = VRT.db.modules.CooldownCheck
    if not db or not db.enabled then return end
    db.tracked = db.tracked or {}
end
