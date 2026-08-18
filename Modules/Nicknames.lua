local addonName, VRT = ...
local UI = VRT.UI

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

-- Retourne la liste triée des noms (avec royaume) présents dans le groupe/raid actuel,
-- ou juste le joueur si solo.
local function GetGroupFullNames()
    local names = {}
    local seen = {}

    local function addUnit(unit)
        if not UnitExists(unit) then return end
        local name, realm = UnitName(unit)
        if not name then return end
        if not realm or realm == "" then
            realm = GetRealmName()
        end
        local fullName = name .. "-" .. realm
        if not seen[fullName] then
            seen[fullName] = true
            table.insert(names, fullName)
        end
    end

    addUnit("player")
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do addUnit("raid" .. i) end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do addUnit("party" .. i) end
    end

    table.sort(names)
    return names
end

-- ===== Fenêtre de gestion des surnoms =====

local nicknameFrame
local rows = {}
local ROW_HEIGHT = 24

local function CreateRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(280, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT)

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
    nameText:SetWidth(140)
    nameText:SetJustifyH("LEFT")

    local editBox = CreateFrame("EditBox", nil, row)
    editBox:SetSize(120, 18)
    editBox:SetPoint("LEFT", nameText, "RIGHT", 6, 0)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetMaxLetters(24)

    local editBg = editBox:CreateTexture(nil, "BACKGROUND")
    editBg:SetAllPoints()
    editBg:SetColorTexture(0.15, 0.15, 0.17, 1)
    UI.ApplyBorder(editBox, 0.05, 0.05, 0.05, 1)

    editBox:SetScript("OnEnterPressed", function(self)
        Nicknames:Set(row.fullName, self:GetText())
        self:ClearFocus()
    end)
    editBox:SetScript("OnEscapePressed", function(self)
        self:SetText(VRT.db.nicknames[row.fullName] or "")
        self:ClearFocus()
    end)
    editBox:SetScript("OnEditFocusLost", function(self)
        Nicknames:Set(row.fullName, self:GetText())
    end)

    row.nameText = nameText
    row.editBox = editBox
    return row
end

local function BuildFrame()
    if nicknameFrame then return nicknameFrame end

    nicknameFrame = CreateFrame("Frame", "ValhollNicknamesFrame", UIParent)
    nicknameFrame:SetSize(320, 360)
    local optionsFrame = _G["ValhollOptionsFrame"]
    if optionsFrame then
        nicknameFrame:SetPoint("TOPLEFT", optionsFrame, "TOPRIGHT", 10, 0)
    else
        nicknameFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    end
    nicknameFrame:SetMovable(true)
    nicknameFrame:EnableMouse(true)
    nicknameFrame:RegisterForDrag("LeftButton")
    nicknameFrame:SetScript("OnDragStart", nicknameFrame.StartMoving)
    nicknameFrame:SetScript("OnDragStop", nicknameFrame.StopMovingOrSizing)
    nicknameFrame:SetFrameStrata("DIALOG")
    nicknameFrame:Hide()
    tinsert(UISpecialFrames, "ValhollNicknamesFrame")

    local bg = nicknameFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.07, 0.07, 0.08, 0.97)
    UI.ApplyBorder(nicknameFrame, 0.05, 0.05, 0.05, 1)

    local titleBar = CreateFrame("Frame", nil, nicknameFrame)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(28)
    local titleBarBg = titleBar:CreateTexture(nil, "ARTWORK")
    titleBarBg:SetAllPoints()
    titleBarBg:SetColorTexture(VRT.ACCENT[1] * 0.18, VRT.ACCENT[2] * 0.18, VRT.ACCENT[3] * 0.18, 1)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
    title:SetText("Surnoms")

    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -6, 0)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    closeText:SetAllPoints()
    closeText:SetText("x")
    closeBtn:SetScript("OnEnter", function() closeText:SetTextColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function() closeText:SetTextColor(1, 1, 1) end)
    closeBtn:SetScript("OnClick", function() nicknameFrame:Hide() end)

    local hint = nicknameFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 6, -8)
    hint:SetText("Groupe/raid actuel — Entrée pour valider")

    local listContainer = CreateFrame("Frame", nil, nicknameFrame)
    listContainer:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", -2, -8)
    listContainer:SetPoint("RIGHT", nicknameFrame, "RIGHT", -12, 0)
    listContainer:SetHeight(280)
    nicknameFrame.listContainer = listContainer

    local refreshBtn = UI.CreateFlatButton(nicknameFrame, "ValhollNicknamesRefreshBtn", "Actualiser la liste", 160, 22)
    refreshBtn:SetPoint("BOTTOM", 0, 14)
    refreshBtn:SetScript("OnClick", function() Nicknames:RefreshWindow() end)

    return nicknameFrame
end

function Nicknames:RefreshWindow()
    local frame = BuildFrame()
    local names = GetGroupFullNames()

    for i, fullName in ipairs(names) do
        local row = rows[i]
        if not row then
            row = CreateRow(frame.listContainer, i)
            rows[i] = row
        end
        row.fullName = fullName
        local shortName = fullName:match("^([^%-]+)") or fullName
        row.nameText:SetText(shortName)
        row.editBox:SetText(VRT.db.nicknames[fullName] or "")
        row:Show()
    end

    for i = #names + 1, #rows do
        rows[i]:Hide()
    end
end

function Nicknames:ToggleWindow()
    local frame = BuildFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        self:RefreshWindow()
        frame:Show()
    end
end

function Nicknames:OnInitialize()
    VRT.db.nicknames = VRT.db.nicknames or {}
end
