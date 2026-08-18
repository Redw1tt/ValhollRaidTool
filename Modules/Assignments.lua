local addonName, VRT = ...

-- Attribution de rôles/tâches par boss (ex: "Interrupt 1: Rogwitt", "Kite: Paladin").
-- VRT.db.modules.Assignments.data[tier][boss] = { { role = "", player = "" }, ... }

local Assignments = {}
VRT:RegisterModule("Assignments", Assignments)

function Assignments:GetForBoss(tier, boss)
    local db = VRT.db.modules.Assignments
    if not db or not db.enabled then return {} end
    db.data = db.data or {}
    db.data[tier] = db.data[tier] or {}
    db.data[tier][boss] = db.data[tier][boss] or {}
    return db.data[tier][boss]
end

function Assignments:AddAssignment(tier, boss, role, player)
    local list = self:GetForBoss(tier, boss)
    table.insert(list, { role = role, player = player })
end

function Assignments:RemoveAssignment(tier, boss, index)
    local list = self:GetForBoss(tier, boss)
    table.remove(list, index)
end

function Assignments:OnInitialize()
    local db = VRT.db.modules.Assignments
    if not db or not db.enabled then return end
    db.data = db.data or {}
end
