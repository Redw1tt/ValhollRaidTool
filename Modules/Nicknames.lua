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

-- ===== Panneau intégré au shell d'options (onglet "Surnoms") =====

local rows = {}
local ROW_HEIGHT = 24
local listContainer

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

function Nicknames:RefreshOptionsPanel()
    if not listContainer then return end
    local names = GetGroupFullNames()

    for i, fullName in ipairs(names) do
        local row = rows[i]
        if not row then
            row = CreateRow(listContainer, i)
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

function Nicknames:BuildOptionsPanel(container)
    local hint = container:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    hint:SetText("Groupe/raid actuel — Entrée pour valider")

    listContainer = CreateFrame("Frame", nil, container)
    listContainer:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -10)
    listContainer:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    listContainer:SetHeight(280)

    local refreshBtn = UI.CreateFlatButton(container, "ValhollNicknamesRefreshBtn", "Actualiser la liste", 160, 22)
    refreshBtn:SetPoint("TOPLEFT", listContainer, "BOTTOMLEFT", 0, -10)
    refreshBtn:SetScript("OnClick", function() Nicknames:RefreshOptionsPanel() end)

    -- hint(20) + gap(10) + liste(280) + gap(10) + bouton(22)
    container.contentHeight = 20 + 10 + 280 + 10 + 22

    self:RefreshOptionsPanel()
end

function Nicknames:OnInitialize()
    VRT.db.nicknames = VRT.db.nicknames or {}
end
