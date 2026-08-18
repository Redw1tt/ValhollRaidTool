local addonName, VRT = ...

local AnchorManager = {}
VRT:RegisterModule("AnchorManager", AnchorManager)

local registered = {}

-- Enregistre une fenêtre déplaçable pour qu'elle retienne sa position entre les sessions
function AnchorManager:Register(key, frame, defaultPoint, defaultX, defaultY)
    registered[key] = frame

    frame.OnMoved = function(self)
        local point, _, _, x, y = self:GetPoint()
        VRT.db.anchors[key] = { point = point, x = x, y = y }
    end

    local saved = VRT.db.anchors[key]
    frame:ClearAllPoints()
    if saved then
        frame:SetPoint(saved.point, UIParent, saved.point, saved.x, saved.y)
    else
        frame:SetPoint(defaultPoint or "CENTER", UIParent, defaultPoint or "CENTER", defaultX or 0, defaultY or 0)
    end
end

function AnchorManager:ResetPosition(key, defaultPoint, defaultX, defaultY)
    VRT.db.anchors[key] = nil
    local frame = registered[key]
    if frame then
        frame:ClearAllPoints()
        frame:SetPoint(defaultPoint or "CENTER", UIParent, defaultPoint or "CENTER", defaultX or 0, defaultY or 0)
    end
end

function AnchorManager:SetAllLocked(locked)
    for _, frame in pairs(registered) do
        if frame.SetLocked then frame:SetLocked(locked) end
    end
end

function AnchorManager:GetRegistered()
    return registered
end
