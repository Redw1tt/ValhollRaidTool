local addonName, VRT = ...

-- Fournit des chaînes d'import WeakAuras pré-configurées, copiables via une boîte de dialogue
-- (WoW n'autorise pas la copie automatique dans le presse-papier).
-- VRT.db.modules.WAImports.presets = { { name = "", importString = "" }, ... }

local WAImports = {}
VRT:RegisterModule("WAImports", WAImports)

function WAImports:GetPresets()
    local db = VRT.db.modules.WAImports
    return db.presets or {}
end

function WAImports:ShowImportDialog(importString)
    local dialog = VRT.frames.WAImportDialog
    if not dialog then
        dialog = CreateFrame("Frame", "ValhollWAImportDialog", UIParent)
        dialog:SetSize(400, 150)
        dialog:SetPoint("CENTER")
        dialog:SetFrameStrata("DIALOG")
        dialog:EnableMouse(true)
        local bg = dialog:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.07, 0.07, 0.08, 0.97)
        VRT.UI.ApplyBorder(dialog, 0.05, 0.05, 0.05, 1)

        local editBox = CreateFrame("EditBox", nil, dialog)
        editBox:SetMultiLine(true)
        editBox:SetSize(360, 100)
        editBox:SetPoint("TOP", 0, -20)
        editBox:SetAutoFocus(true)
        editBox:SetFontObject("ChatFontNormal")
        editBox:SetScript("OnEscapePressed", function() dialog:Hide() end)
        dialog.editBox = editBox

        local closeBtn = VRT.UI.CreateFlatButton(dialog, nil, "Fermer", 80, 22)
        closeBtn:SetPoint("BOTTOM", 0, 14)
        closeBtn:SetScript("OnClick", function() dialog:Hide() end)

        VRT.frames.WAImportDialog = dialog
    end

    dialog.editBox:SetText(importString or "")
    dialog.editBox:HighlightText()
    dialog:Show()
end

function WAImports:OnInitialize()
    local db = VRT.db.modules.WAImports
    if not db or not db.enabled then return end
    db.presets = db.presets or {}
end
