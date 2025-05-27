local I = require("openmw.interfaces")
local S = require('scripts.ErnGearRandomizer.settings')

I.Settings.registerPage {
    key = S.MOD_NAME,
    l10n = S.MOD_NAME,
    name = "name",
    description = "description"
}