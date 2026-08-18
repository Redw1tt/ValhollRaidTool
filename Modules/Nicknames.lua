local addonName, VRT = ...

-- Surnoms locaux affichés à la place du nom de personnage dans les modules Valholl.
-- VRT.db.nicknames[fullName] = "Surnom"

local Nicknames = {}
VRT:RegisterModule("Nicknames", Nicknames)

function Nicknames:Get(fullName)
    local db = VRT.db.modules.Nicknames
    if not db or not db.enabled then return fullName end
    return VRT.db.nicknames[fullName] or fullName
end

function Nicknames:Set(fullName, nickname)
    if nickname == nil or nickname == "" then
        VRT.db.nicknames[fullName] = nil
    else
        VRT.db.nicknames[fullName] = nickname
    end
end

function Nicknames:OnInitialize()
    VRT.db.nicknames = VRT.db.nicknames or {}
end
