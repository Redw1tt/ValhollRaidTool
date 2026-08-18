local addonName, VRT = ...
local UI = VRT.UI

local Options = {}
VRT:RegisterModule("Options", Options)

local optionsFrame

local function BuildFrame()
    if optionsFrame then return optionsFrame end

    optionsFrame = CreateFrame("Frame", "ValhollOptionsFrame", UIParent)
    optionsFrame:SetSize(320, 460)
    optionsFrame:SetPoint("CENTER")
    optionsFrame:SetMovable(true)
    optionsFrame:EnableMouse(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
    optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)
    optionsFrame:SetFrameStrata("DIALOG")
    optionsFrame:Hide()
    tinsert(UISpecialFrames, "ValhollOptionsFrame")

    local bg = optionsFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.07, 0.07, 0.08, 0.97)
    UI.ApplyBorder(optionsFrame, 0.05, 0.05, 0.05, 1)

    local titleBar = CreateFrame("Frame", nil, optionsFrame)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(28)
    local titleBarBg = titleBar:CreateTexture(nil, "ARTWORK")
    titleBarBg:SetAllPoints()
    titleBarBg:SetColorTexture(VRT.ACCENT[1] * 0.18, VRT.ACCENT[2] * 0.18, VRT.ACCENT[3] * 0.18, 1)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
    title:SetText("Valhöll Raid Tool")

    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -6, 0)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    closeText:SetAllPoints()
    closeText:SetText("x")
    closeBtn:SetScript("OnEnter", function() closeText:SetTextColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function() closeText:SetTextColor(1, 1, 1) end)
    closeBtn:SetScript("OnClick", function() optionsFrame:Hide() end)

    -- Section générale
    local generalLabel = UI.CreateSectionLabel(optionsFrame, titleBar, "Général", -18)

    local lockCheck = UI.CreateFlatCheck(optionsFrame, "ValhollLockCheck", "Verrouiller les fenêtres", generalLabel, -14)
    lockCheck:SetScript("OnClick", function(self)
        VRT.db.general.locked = self:GetChecked() and true or false
        VRT:GetModule("AnchorManager"):SetAllLocked(VRT.db.general.locked)
    end)
    optionsFrame.lockCheck = lockCheck

    local scaleSlider = UI.CreateFlatSlider(optionsFrame, "ValhollScaleSlider", "Échelle globale", 0.5, 2.0, 0.1, lockCheck, -30)
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        VRT.db.general.scale = value
        self.valueText:SetText(string.format("%.1f", value))
    end)
    optionsFrame.scaleSlider = scaleSlider

    -- Section modules (activer/désactiver, nécessite /reload pour prendre effet complètement)
    local modulesLabel = UI.CreateSectionLabel(optionsFrame, scaleSlider, "Modules", -30)

    local moduleOrder = {
        "AuraTracking", "AuraSounds", "CooldownCheck", "Reminders", "Nicknames",
        "ReadyCheck", "Assignments", "PaceComparison", "WAImports", "VersionCheck",
        "BossTimelines", "EncounterAlerts",
    }

    local anchor = modulesLabel
    optionsFrame.moduleChecks = {}
    for _, moduleName in ipairs(moduleOrder) do
        local check = UI.CreateFlatCheck(optionsFrame, "ValhollModCheck" .. moduleName, moduleName, anchor, -12)
        check:SetScript("OnClick", function(self)
            VRT.db.modules[moduleName].enabled = self:GetChecked() and true or false
            print("|cFF25C7EB[Valholl]|r " .. moduleName .. " " .. (self:GetChecked() and "activé" or "désactivé") .. " (effectif après /reload).")
        end)
        optionsFrame.moduleChecks[moduleName] = check
        anchor = check
    end

    -- Bouton reset
    local resetBtn = UI.CreateFlatButton(optionsFrame, "ValhollResetBtn", "Réinitialiser", 140, 22)
    resetBtn:SetPoint("BOTTOM", 0, 14)
    resetBtn.bg:SetColorTexture(0.3, 0.12, 0.12, 1)
    resetBtn:SetScript("OnClick", function()
        SlashCmdList["VALHOLLRAIDTOOL"]("reset")
        Options:Refresh()
    end)

    return optionsFrame
end

function Options:Refresh()
    local frame = BuildFrame()
    frame.lockCheck:SetChecked(VRT.db.general.locked and true or false)
    frame.scaleSlider:SetValue(VRT.db.general.scale or 1.0)
    for moduleName, check in pairs(frame.moduleChecks) do
        local modDB = VRT.db.modules[moduleName]
        check:SetChecked(modDB and modDB.enabled and true or false)
    end
end

function Options:Toggle()
    local frame = BuildFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        self:Refresh()
        frame:Show()
    end
end

function Options:OnInitialize()
    -- Le cadre est construit à la demande (lazy) via Toggle().
end
