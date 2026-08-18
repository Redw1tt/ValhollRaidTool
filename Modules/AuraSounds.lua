local addonName, VRT = ...

-- Joue un son quand une aura surveillée apparaît/disparaît.
-- VRT.db.modules.AuraSounds.rules = { [spellID] = { onGain = soundFile, onFade = soundFile } }

local AuraSounds = {}
VRT:RegisterModule("AuraSounds", AuraSounds)

local lastSeen = {} -- [unit][spellID] = true

function AuraSounds:OnAuraUpdate(unit)
    local db = VRT.db.modules.AuraSounds
    if not db or not db.enabled then return end
    local rules = db.rules or {}

    local tracking = VRT:GetModule("AuraTracking")
    local current = tracking and tracking:GetActiveAuras(unit) or {}

    lastSeen[unit] = lastSeen[unit] or {}

    for spellID, rule in pairs(rules) do
        local isActive = current[spellID] ~= nil
        local wasActive = lastSeen[unit][spellID] or false

        if isActive and not wasActive and rule.onGain then
            PlaySoundFile(rule.onGain, "Master")
        elseif not isActive and wasActive and rule.onFade then
            PlaySoundFile(rule.onFade, "Master")
        end

        lastSeen[unit][spellID] = isActive
    end
end

function AuraSounds:OnInitialize()
    local db = VRT.db.modules.AuraSounds
    if not db or not db.enabled then return end
    db.rules = db.rules or {}
end
