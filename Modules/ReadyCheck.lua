local addonName, VRT = ...

-- Affichage custom du ready check, avec liste des joueurs n'ayant pas répondu.
local ReadyCheck = {}
VRT:RegisterModule("ReadyCheck", ReadyCheck)

local rcFrame = CreateFrame("Frame")
local pending = {}

local function BuildDisplay()
    local display = VRT.frames.ReadyCheckDisplay
    if not display then
        display = VRT.UI.CreateAnchoredWindow("ValhollReadyCheckDisplay", "Ready Check", 220, 26)
        VRT:GetModule("AnchorManager"):Register("ReadyCheckDisplay", display, "TOP", 0, -100)
        display.text = display:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        display.text:SetPoint("CENTER")
        display:Hide()
        VRT.frames.ReadyCheckDisplay = display
    end
    return display
end

function ReadyCheck:UpdateDisplay()
    local db = VRT.db.modules.ReadyCheck
    if not db or not db.enabled then return end

    local display = BuildDisplay()
    local notReady = {}
    for unit, status in pairs(pending) do
        if status == false then
            table.insert(notReady, UnitName(unit) or unit)
        end
    end

    if #notReady > 0 then
        display.text:SetText("En attente: " .. table.concat(notReady, ", "))
        display:Show()
    else
        display:Hide()
    end
end

function ReadyCheck:OnInitialize()
    local db = VRT.db.modules.ReadyCheck
    if not db or not db.enabled then return end

    rcFrame:RegisterEvent("READY_CHECK")
    rcFrame:RegisterEvent("READY_CHECK_CONFIRM")
    rcFrame:RegisterEvent("READY_CHECK_FINISHED")
    rcFrame:SetScript("OnEvent", function(self, event, unit, isReady)
        if event == "READY_CHECK" then
            pending = {}
            local numMembers = GetNumGroupMembers()
            local prefix = IsInRaid() and "raid" or "party"
            for i = 1, numMembers do
                local u = IsInRaid() and (prefix .. i) or (i < numMembers and (prefix .. i) or "player")
                if UnitExists(u) then pending[u] = false end
            end
            ReadyCheck:UpdateDisplay()
        elseif event == "READY_CHECK_CONFIRM" then
            pending[unit] = isReady
            ReadyCheck:UpdateDisplay()
        elseif event == "READY_CHECK_FINISHED" then
            local display = VRT.frames.ReadyCheckDisplay
            if display then
                C_Timer.After(3, function() display:Hide() end)
            end
        end
    end)
end
