local addonName, VRT = ...

-- Stub local : compare seulement la version de l'utilisateur à la dernière connue.
-- La vérification réseau (via Comms/AceComm) entre membres du raid sera ajoutée plus tard.

local VersionCheck = {}
VRT:RegisterModule("VersionCheck", VersionCheck)

function VersionCheck:GetLocalVersion()
    local version = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version")
    return version or GetAddOnMetadata(addonName, "Version")
end

function VersionCheck:OnInitialize()
    local db = VRT.db.modules.VersionCheck
    if not db or not db.enabled then return end
    -- TODO: diffusion de version aux autres membres du raid une fois Comms implémenté.
end
