local addonName, addonTable = ...

-- Base de données des sorts d'interruption majeurs
local INTERRUPTS = {
    [1766]   = 15, -- Coup de pied (Voleur)
    [6552]   = 15, -- Volée de coups (Guerrier)
    [2139]   = 24, -- Contresort (Mage)
    [57994]  = 12, -- Cisaille de vent (Chaman)
    [96231]  = 15, -- Réprimande (Paladin)
    [47528]  = 15, -- Gel de l'esprit (DK)
    [183752] = 15, -- Interruption / Consommer (DH)
    [106839] = 15, -- Volée de coups (Druide Féral/Gardien)
    [78675]  = 60, -- Rayon solaire (Druide Équilibre)
    [147362] = 24, -- Tir muselé (Chasseur)
    [116705] = 15, -- Pique de la paume (Moine)
    [351338] = 20, -- Quasser (Évokateur)
    [15487]  = 45, -- Silence (Prêtre Ombre)
}

-- Correspondance Classe -> Sort d'interruption
local CLASS_INTERRUPTS = {
    ["ROGUE"]       = 1766, ["WARRIOR"]     = 6552, ["MAGE"]        = 2139,
    ["SHAMAN"]      = 57994, ["PALADIN"]     = 96231, ["DEATHKNIGHT"] = 47528,
    ["DEMONHUNTER"] = 183752, ["DRUID"]       = 106839, ["HUNTER"]      = 147362,
    ["MONK"]        = 116705, ["EVOKER"]      = 351338, ["PRIEST"]      = 15487,
}

-- Couleurs officielles des classes
local CLASS_COLORS = {
    ["DEATHKNIGHT"] = {0.77, 0.12, 0.23}, ["DEMONHUNTER"] = {0.64, 0.19, 0.79},
    ["DRUID"]       = {1.00, 0.49, 0.04}, ["EVOKER"]      = {0.20, 0.58, 0.50},
    ["HUNTER"]      = {0.67, 0.83, 0.45}, ["MAGE"]        = {0.25, 0.78, 0.92},
    ["MONK"]        = {0.00, 1.00, 0.60}, ["PALADIN"]     = {0.96, 0.55, 0.73},
    ["PRIEST"]      = {1.00, 1.00, 1.00}, ["ROGUE"]       = {1.00, 0.96, 0.41},
    ["SHAMAN"]      = {0.00, 0.44, 0.87}, ["WARLOCK"]     = {0.53, 0.53, 0.93},
    ["WARRIOR"]     = {0.78, 0.61, 0.43},
}

-- Valeurs par défaut sauvegardées
local defaultDB = {
    scale = 1.0, width = 180, height = 18, locked = false,
    useClassColors = true, showSelf = true, testMode = false,
    posX = 200, posY = 0, point = "CENTER",
    customColor = {0.20, 0.60, 1.00},
}

-- Fenêtre Principale
local mainFrame = CreateFrame("Frame", "ValhollInterruptFrame", UIParent)
mainFrame:SetSize(defaultDB.width, defaultDB.height)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")

local header = mainFrame:CreateTexture(nil, "BACKGROUND")
header:SetAllPoints()
header:SetColorTexture(0.05, 0.05, 0.05, 0.9)

local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
title:SetPoint("CENTER", mainFrame, "CENTER", 0, 0)
title:SetText("VRT")

local rows = {}
local tracker = {}

local function ApplySettings()
    if not ValhollDB then return end
    mainFrame:SetScale(ValhollDB.scale or 1.0)
    mainFrame:SetWidth(ValhollDB.width or 180)
    mainFrame:SetHeight(ValhollDB.height or 18)

    if ValhollDB.point and ValhollDB.posX then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint(ValhollDB.point, UIParent, ValhollDB.point, ValhollDB.posX, ValhollDB.posY)
    end

    if ValhollDB.locked then
        mainFrame:EnableMouse(false)
        header:SetColorTexture(0, 0, 0, 0)
        title:SetText("")
    else
        mainFrame:EnableMouse(true)
        header:SetColorTexture(0.05, 0.05, 0.05, 0.9)
        title:SetText("VRT")
    end

    for _, row in ipairs(rows) do
        row:SetWidth(ValhollDB.width or 180)
        row:SetHeight(ValhollDB.height or 18)
        row.iconFrame:SetSize(ValhollDB.height or 18, ValhollDB.height or 18)
    end
end

mainFrame:SetScript("OnDragStart", function(self)
    if not ValhollDB.locked then self:StartMoving() end
end)

mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    ValhollDB.point = point
    ValhollDB.posX = x
    ValhollDB.posY = y
end)

local function GetSpellIconID(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then return info.iconID end
    end
    if GetSpellTexture then return GetSpellTexture(spellID) end
    return 136018
end

local function CheckAndAddUnit(unit)
    if not UnitExists(unit) then return end
    if unit == "player" and ValhollDB and not ValhollDB.showSelf then return end

    local guid = UnitGUID(unit)
    if not guid then return end

    local name = UnitName(unit)
    local _, classFileName = UnitClass(unit)

    if not tracker[guid] then
        local spellID = CLASS_INTERRUPTS[classFileName] or 1766
        local icon = GetSpellIconID(spellID)

        tracker[guid] = {
            name = name, spellID = spellID,
            icon = icon, class = classFileName,
            duration = INTERRUPTS[spellID] or 15,
            readyAt = 0
        }
    else
        tracker[guid].name = name
        tracker[guid].class = classFileName
    end
end

local function UpdateGroupRoster()
    if ValhollDB and ValhollDB.testMode then return end
    local oldTracker = CopyTable(tracker)
    tracker = {}

    if not ValhollDB or ValhollDB.showSelf then CheckAndAddUnit("player") end
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do CheckAndAddUnit("raid" .. i) end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do CheckAndAddUnit("party" .. i) end
    end

    for guid, data in pairs(tracker) do
        if oldTracker[guid] then
            tracker[guid].readyAt = oldTracker[guid].readyAt
            tracker[guid].duration = oldTracker[guid].duration
            tracker[guid].spellID = oldTracker[guid].spellID
            if oldTracker[guid].icon then tracker[guid].icon = oldTracker[guid].icon end
        end
    end
end

local function EnableTestMode()
    tracker = {
        ["test1"] = { name = "Rogwitt", class = "ROGUE", duration = 15, readyAt = GetTime() + 10, icon = GetSpellIconID(1766) },
        ["test2"] = { name = "Paladin", class = "PALADIN", duration = 15, readyAt = 0, icon = GetSpellIconID(96231) },
        ["test3"] = { name = "Warrior", class = "WARRIOR", duration = 15, readyAt = GetTime() + 5, icon = GetSpellIconID(6552) },
    }
end

-- Création sécurisée d'un cadre avec bordures sans dépendre de SetBackdrop (obsolète dans WoW moderne)
local function ApplyBorder(frame, r, g, b, a)
    if not frame.borderLines then
        frame.borderLines = {}
        for i = 1, 4 do
            local line = frame:CreateTexture(nil, "OVERLAY")
            line:SetColorTexture(r or 0.1, g or 0.1, b or 0.1, a or 0.6)
            table.insert(frame.borderLines, line)
        end
        -- Top
        frame.borderLines[1]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        frame.borderLines[1]:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -1)
        -- Bottom
        frame.borderLines[2]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        frame.borderLines[2]:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1)
        -- Left
        frame.borderLines[3]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        frame.borderLines[3]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 1, 0)
        -- Right
        frame.borderLines[4]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        frame.borderLines[4]:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -1, 0)
    else
        for _, line in ipairs(frame.borderLines) do
            line:SetColorTexture(r or 0.1, g or 0.1, b or 0.1, a or 0.6)
        end
    end
end

local function CreateBarRow(index)
    local row = CreateFrame("Frame", nil, mainFrame)
    local barWidth = ValhollDB and ValhollDB.width or 180
    local barHeight = ValhollDB and ValhollDB.height or 18
    local SPACING = 2

    row:SetSize(barWidth, barHeight)
    row:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 0, -(index - 1) * (barHeight + SPACING))

    local iconFrame = CreateFrame("Frame", nil, row)
    iconFrame:SetSize(barHeight, barHeight)
    iconFrame:SetPoint("LEFT", row, "LEFT", 0, 0)
    ApplyBorder(iconFrame, 0.1, 0.1, 0.1, 0.6)

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(iconFrame)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local barFrame = CreateFrame("Frame", nil, row)
    barFrame:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", SPACING, 0)
    barFrame:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    ApplyBorder(barFrame, 0.1, 0.1, 0.1, 0.6)

    local statusBar = CreateFrame("StatusBar", nil, barFrame)
    statusBar:SetAllPoints(barFrame)
    statusBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    statusBar:SetMinMaxValues(0, 1)

    local spark = statusBar:CreateTexture(nil, "OVERLAY")
    spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    spark:SetVertexColor(1, 1, 1, 0.2)
    spark:SetSize(barHeight / 2, barHeight)
    spark:SetPoint("CENTER", statusBar:GetStatusBarTexture(), "RIGHT")

    local nameText = statusBar:CreateFontString(nil, "OVERLAY", "SystemFont_Med1")
    nameText:SetPoint("LEFT", statusBar, "LEFT", 4, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetVertexColor(1, 1, 1)

    local timerText = statusBar:CreateFontString(nil, "OVERLAY", "SystemFont_Med1")
    timerText:SetPoint("RIGHT", statusBar, "RIGHT", -4, 0)
    timerText:SetJustifyH("RIGHT")
    timerText:SetVertexColor(1, 1, 1)

    row.icon = icon
    row.iconFrame = iconFrame
    row.barFrame = barFrame
    row.statusBar = statusBar
    row.nameText = nameText
    row.timerText = timerText
    row.spark = spark
    row:Hide()

    return row
end

local function UpdateDisplay()
    local index = 1
    local now = GetTime()
    local SPACING = 2

    for guid, data in pairs(tracker) do
        if not rows[index] then
            rows[index] = CreateBarRow(index)
        end
        local row = rows[index]

        local barHeight = ValhollDB and ValhollDB.height or 18
        local barWidth = ValhollDB and ValhollDB.width or 180
        row:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 0, -(index - 1) * (barHeight + SPACING))

        row.nameText:SetText(data.name or "Allié")
        if data.icon then row.icon:SetTexture(data.icon) end

        if ValhollDB and ValhollDB.useClassColors then
            local color = CLASS_COLORS[data.class] or {0.5, 0.5, 0.5}
            row.statusBar:SetStatusBarColor(color[1], color[2], color[3], 0.85)
        else
            local c = (ValhollDB and ValhollDB.customColor) or defaultDB.customColor
            row.statusBar:SetStatusBarColor(c[1], c[2], c[3], 0.85)
        end

        local totalCD = data.duration or 15
        local cdLeft = data.readyAt - now

        if cdLeft > 0 then
            row.statusBar:SetValue(1 - (cdLeft / totalCD))
            row.timerText:SetText(math.ceil(cdLeft))
            ApplyBorder(row.iconFrame, 1, 0, 0, 0.6)
            ApplyBorder(row.barFrame, 1, 0, 0, 0.6)
            row.icon:SetDesaturated(true)
            row.nameText:SetVertexColor(1, 1, 1, 0.6)
            row.spark:Show()
        else
            row.statusBar:SetValue(1)
            row.timerText:SetText("")
            ApplyBorder(row.iconFrame, 0.1, 0.1, 0.1, 0.6)
            ApplyBorder(row.barFrame, 0.1, 0.1, 0.1, 0.6)
            row.icon:SetDesaturated(false)
            row.nameText:SetVertexColor(1, 1, 1, 0.9)
            row.spark:Hide()
        end

        row:Show()
        index = index + 1
    end

    for i = index, #rows do
        rows[i]:Hide()
    end
end

-- Panneau d'options (flat design, cohérent avec les barres de suivi)
local ACCENT = {0.25, 0.78, 0.92}

local optionsFrame = CreateFrame("Frame", "ValhollOptionsFrame", UIParent)
optionsFrame:SetSize(300, 510)
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
ApplyBorder(optionsFrame, 0.05, 0.05, 0.05, 1)

local titleBar = CreateFrame("Frame", nil, optionsFrame)
titleBar:SetPoint("TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", 0, 0)
titleBar:SetHeight(28)
local titleBarBg = titleBar:CreateTexture(nil, "ARTWORK")
titleBarBg:SetAllPoints()
titleBarBg:SetColorTexture(ACCENT[1] * 0.18, ACCENT[2] * 0.18, ACCENT[3] * 0.18, 1)

optionsFrame.title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
optionsFrame.title:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
optionsFrame.title:SetText("Valhöll Raid Tool")

local closeBtn = CreateFrame("Button", nil, titleBar)
closeBtn:SetSize(20, 20)
closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -6, 0)
local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
closeText:SetAllPoints()
closeText:SetText("x")
closeBtn:SetScript("OnEnter", function() closeText:SetTextColor(1, 0.3, 0.3) end)
closeBtn:SetScript("OnLeave", function() closeText:SetTextColor(1, 1, 1) end)
closeBtn:SetScript("OnClick", function() optionsFrame:Hide() end)

-- Sections / séparateurs
local function CreateSectionLabel(anchor, text, yOff)
    local label = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -16)
    label:SetText(text)
    label:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
    local line = optionsFrame:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.12)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
    line:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -16, 0)
    line:SetPoint("LEFT", optionsFrame, "LEFT", 16, 0)
    return label
end

-- Slider flat custom
local function CreateFlatSlider(name, label, min, max, step, anchor, yOff)
    local slider = CreateFrame("Slider", name, optionsFrame)
    slider:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -28)
    slider:SetSize(260, 14)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:EnableMouse(true)

    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", 0, 0)
    track:SetPoint("RIGHT", 0, 0)
    track:SetHeight(4)
    track:SetColorTexture(0.2, 0.2, 0.22, 1)

    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(12, 16)
    thumb:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    slider:SetThumbTexture(thumb)

    local labelText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 4)
    labelText:SetText(label)

    local valueText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 4)
    slider.valueText = valueText

    return slider
end

local scaleSlider = CreateFlatSlider("ValhollScaleSlider", "Échelle (Scale)", 0.5, 2.0, 0.1, titleBar, -30)
scaleSlider:SetScript("OnValueChanged", function(self, value)
    ValhollDB.scale = value; self.valueText:SetText(string.format("%.1f", value)); ApplySettings()
end)

local widthSlider = CreateFlatSlider("ValhollWidthSlider", "Largeur des barres", 100, 300, 5, scaleSlider, -34)
widthSlider:SetScript("OnValueChanged", function(self, value)
    ValhollDB.width = value; self.valueText:SetText(tostring(math.floor(value))); ApplySettings()
end)

local heightSlider = CreateFlatSlider("ValhollHeightSlider", "Hauteur des barres", 12, 30, 1, widthSlider, -34)
heightSlider:SetScript("OnValueChanged", function(self, value)
    ValhollDB.height = value; self.valueText:SetText(tostring(math.floor(value))); ApplySettings()
end)

-- Checkbox flat custom
local function CreateFlatCheck(name, label, anchor, yOff)
    local check = CreateFrame("CheckButton", name, optionsFrame)
    check:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -18)
    check:SetSize(16, 16)

    local box = check:CreateTexture(nil, "ARTWORK")
    box:SetAllPoints()
    box:SetColorTexture(0.15, 0.15, 0.17, 1)
    ApplyBorder(check, 0.05, 0.05, 0.05, 1)

    local mark = check:CreateTexture(nil, "OVERLAY")
    mark:SetPoint("TOPLEFT", 2, -2)
    mark:SetPoint("BOTTOMRIGHT", -2, 2)
    mark:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    check:SetCheckedTexture(mark)

    local text = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", check, "RIGHT", 8, 0)
    text:SetText(label)

    return check
end

local lockCheck = CreateFlatCheck("ValhollLockCheck", "Verrouiller la position", heightSlider, -30)
lockCheck:SetScript("OnClick", function(self) ValhollDB.locked = self:GetChecked() and true or false; ApplySettings() end)

local colorSectionLabel = CreateSectionLabel(lockCheck, "Couleurs des barres", -20)

local colorCheck = CreateFlatCheck("ValhollColorCheck", "Utiliser les couleurs de classe", colorSectionLabel, -14)
colorCheck:SetScript("OnClick", function(self)
    ValhollDB.useClassColors = self:GetChecked() and true or false
    UpdateDisplay()
end)

-- Bouton d'échantillon de couleur custom (ouvre le ColorPickerFrame natif)
local customColorLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
customColorLabel:SetPoint("TOPLEFT", colorCheck, "BOTTOMLEFT", 0, -14)
customColorLabel:SetText("Couleur personnalisée")

local customColorSwatch = CreateFrame("Button", "ValhollCustomColorSwatch", optionsFrame)
customColorSwatch:SetSize(20, 20)
customColorSwatch:SetPoint("LEFT", customColorLabel, "RIGHT", 10, 0)
local swatchTex = customColorSwatch:CreateTexture(nil, "ARTWORK")
swatchTex:SetAllPoints()
swatchTex:SetColorTexture(1, 1, 1, 1)
ApplyBorder(customColorSwatch, 0.05, 0.05, 0.05, 1)
customColorSwatch.tex = swatchTex

local function RefreshSwatch()
    local c = (ValhollDB and ValhollDB.customColor) or defaultDB.customColor
    swatchTex:SetColorTexture(c[1], c[2], c[3], 1)
end

customColorSwatch:SetScript("OnClick", function()
    local c = (ValhollDB and ValhollDB.customColor) or defaultDB.customColor

    local function OnColorChanged()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        ValhollDB.customColor = {r, g, b}
        RefreshSwatch()
        UpdateDisplay()
    end

    if ColorPickerFrame.SetupColorPickerAndShow then
        -- API moderne (Dragonflight+)
        ColorPickerFrame:SetupColorPickerAndShow({
            r = c[1], g = c[2], b = c[3],
            swatchFunc = OnColorChanged,
            cancelFunc = function(previousValues)
                if previousValues then
                    ValhollDB.customColor = {previousValues.r, previousValues.g, previousValues.b}
                    RefreshSwatch()
                    UpdateDisplay()
                end
            end,
        })
    else
        ColorPickerFrame.func = OnColorChanged
        ColorPickerFrame.cancelFunc = function()
            ValhollDB.customColor = c
            RefreshSwatch()
            UpdateDisplay()
        end
        ColorPickerFrame:SetColorRGB(c[1], c[2], c[3])
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end
end)

local generalSectionLabel = CreateSectionLabel(customColorSwatch, "Général", -18)

local selfCheck = CreateFlatCheck("ValhollSelfCheck", "Afficher mon propre interrupt", generalSectionLabel, -14)
selfCheck:SetScript("OnClick", function(self)
    ValhollDB.showSelf = self:GetChecked() and true or false
    if not ValhollDB.testMode then UpdateGroupRoster() end
    UpdateDisplay()
end)

local testCheck = CreateFlatCheck("ValhollTestCheck", "Mode Test (Barres fictives)", selfCheck, -10)
testCheck:SetScript("OnClick", function(self)
    ValhollDB.testMode = self:GetChecked() and true or false
    if ValhollDB.testMode then EnableTestMode() else UpdateGroupRoster() end
    UpdateDisplay()
end)

-- Bouton reset
local resetBtn = CreateFrame("Button", "ValhollResetBtn", optionsFrame)
resetBtn:SetSize(120, 22)
resetBtn:SetPoint("TOP", testCheck, "BOTTOM", 60, -26)
local resetBg = resetBtn:CreateTexture(nil, "ARTWORK")
resetBg:SetAllPoints()
resetBg:SetColorTexture(0.3, 0.12, 0.12, 1)
ApplyBorder(resetBtn, 0.05, 0.05, 0.05, 1)
local resetText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
resetText:SetAllPoints()
resetText:SetJustifyH("CENTER")
resetText:SetJustifyV("MIDDLE")
resetText:SetText("Réinitialiser")
resetBtn:SetScript("OnEnter", function() resetBg:SetColorTexture(0.45, 0.15, 0.15, 1) end)
resetBtn:SetScript("OnLeave", function() resetBg:SetColorTexture(0.3, 0.12, 0.12, 1) end)
resetBtn:SetScript("OnClick", function()
    ValhollDB = CopyTable(defaultDB); ApplySettings(); UpdateGroupRoster(); UpdateDisplay()
    print("|cFF00FF00[Valhöll]|r Configuration réinitialisée.")
end)

local function OpenOptions()
    scaleSlider:SetValue(ValhollDB.scale or 1.0)
    widthSlider:SetValue(ValhollDB.width or 180)
    heightSlider:SetValue(ValhollDB.height or 18)
    lockCheck:SetChecked(ValhollDB.locked and true or false)
    colorCheck:SetChecked(ValhollDB.useClassColors and true or false)
    selfCheck:SetChecked(ValhollDB.showSelf and true or false)
    testCheck:SetChecked(ValhollDB.testMode and true or false)
    RefreshSwatch()
    optionsFrame:Show()
end

-- Commandes Slash (/vrt)
SLASH_VALHOLLRAIDTOOL1 = "/vrt"
SLASH_VALHOLLRAIDTOOL2 = "/valholl"
SlashCmdList["VALHOLLRAIDTOOL"] = function(msg)
    local cmd = msg:lower():trim()
    if cmd == "reset" then
        ValhollDB = CopyTable(defaultDB); ApplySettings(); UpdateGroupRoster();
        print("|cFF00FF00[Valhöll]|r Configuration réinitialisée.")
    else
        if optionsFrame:IsShown() then optionsFrame:Hide() else OpenOptions() end
    end
end

-- Événements Système
mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
mainFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
mainFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

mainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            ValhollDB = ValhollDB or CopyTable(defaultDB)
            ApplySettings()
            print("|cFF00FF00[Valhöll Raid Tool]|r Chargé ! Tapez |cFFFFD100/vrt|r pour les options.")
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
        C_Timer.After(0.5, function() UpdateGroupRoster(); UpdateDisplay() end)
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        if ValhollDB and ValhollDB.showSelf and not ValhollDB.testMode then
            local playerGUID = UnitGUID("player")
            if tracker[playerGUID] then
                local spellID = tracker[playerGUID].spellID
                local cooldownInfo = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(spellID)
                local start, duration
                if cooldownInfo then start = cooldownInfo.startTime; duration = cooldownInfo.duration else start, duration = GetSpellCooldown(spellID) end
                if start and start > 0 and duration and duration > 1.5 then
                    tracker[playerGUID].duration = duration; tracker[playerGUID].readyAt = start + duration
                end
            end
        end
    end
end)

mainFrame:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 0.03 then UpdateDisplay(); self.timer = 0 end
end)
