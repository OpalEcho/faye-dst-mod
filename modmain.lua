-- modmain.lua
-- ============================================================
-- FAYE - The Elven Shadow Warrior
-- Entry point: registers character, loads prefabs, sets strings.
-- NO custom art assets declared here - all placeholder art uses
-- base-game files, which are always present.
-- ============================================================

-- ─── ASSETS ──────────────────────────────────────────────────────────────────
-- bigportraits/faye.xml is a placeholder atlas that references wendy.tex from
-- the base game. This stops the "Could not find bigportraits/faye.xml" crash
-- on the character select screen. Replace with real art when it's ready.
-- Asset declarations for placeholder XMLs are intentionally omitted.
-- Declaring them as Asset("ATLAS", ...) causes DST to preload them at the C++
-- level using real filesystem paths, where wendy.tex can't be found (it lives
-- in databundles/bigportraits.zip). That load failure breaks network replica
-- registration and crashes on AllocReplica. The XML files still sit in the mod
-- folder and are resolved on-demand via the virtual filesystem (which can reach
-- wendy.tex in bigportraits.zip) when the character select screen requests them.
Assets = {}

-- ─── PREFAB SCRIPTS TO LOAD ──────────────────────────────────────────────────
-- DST looks for these in scripts/prefabs/<name>.lua (inside this mod folder).
PrefabFiles = {
    "faye",
    "faye_shadowblade",
    "faye_twilight_blindfold",
}

-- ─── CHARACTER REGISTRATION ──────────────────────────────────────────────────
-- Registers Faye on the character select screen.
-- "FEMALE" sets her pronouns in shared world speech and announcements.
AddModCharacter("faye", "FEMALE")

-- ─── ITEM NAMES ──────────────────────────────────────────────────────────────
-- STRINGS.NAMES keys must be UPPERCASE versions of the prefab name.
-- The game looks up STRINGS.NAMES[prefab:upper()] for the display name.
GLOBAL.STRINGS.NAMES.FAYE_SHADOWBLADE           = "Shadowblade"
GLOBAL.STRINGS.NAMES.FAYE_TWILIGHT_BLINDFOLD    = "Twilight Blindfold"

-- ─── ITEM DESCRIPTIONS (recipe tooltips / item inspect text) ─────────────────
GLOBAL.STRINGS.RECIPE_DESC.FAYE_SHADOWBLADE         = "A blade forged from condensed shadow. Deadly in darkness."
GLOBAL.STRINGS.RECIPE_DESC.FAYE_TWILIGHT_BLINDFOLD  = "A silken blindfold that dims the cruelty of daylight."

-- ─── STARTING-ITEM SELECT-SCREEN ICONS (Big Book, Chapter 8 fix) ─────────────
-- Custom starting items sometimes show a blank icon on the character-select
-- screen. This override tells that screen which atlas/image to preview.
-- We point at the base-game atlases our placeholders borrow, so it's server-safe.
GLOBAL.TUNING.STARTING_ITEM_IMAGE_OVERRIDE = GLOBAL.TUNING.STARTING_ITEM_IMAGE_OVERRIDE or {}
GLOBAL.TUNING.STARTING_ITEM_IMAGE_OVERRIDE.faye_shadowblade = {
    atlas = "images/inventoryimages/nightsword.xml",
    image = "nightsword.tex",
}
GLOBAL.TUNING.STARTING_ITEM_IMAGE_OVERRIDE.faye_twilight_blindfold = {
    atlas = "images/inventoryimages/mole_hat.xml",
    image = "mole_hat.tex",
}

-- ─── GENERIC EXAMINE STRINGS (what non-Faye characters say about the items) ──
-- DST looks these up as STRINGS.CHARACTERS.GENERIC.DESCRIBE[prefab:upper()].
-- We guard the table creation to avoid overwriting existing entries.
GLOBAL.STRINGS.CHARACTERS.GENERIC = GLOBAL.STRINGS.CHARACTERS.GENERIC or {}
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE = GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE or {}

GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.FAYE_SHADOWBLADE = {
    "It hums with a quiet, hungry energy.",
    "The blade seems to drink in the surrounding darkness.",
    "I can feel the shadows moving inside it.",
}

GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.FAYE_TWILIGHT_BLINDFOLD = {
    "A delicate blindfold. Strangely, it doesn't seem to impair vision.",
    "It's woven from something soft and dark.",
    "Something about it dulls the harshness of the world.",
}

-- ─── PORTRAIT / AVATAR REDIRECT ──────────────────────────────────────────────
-- DST resolves atlas <Texture> paths from the XML's real disk location, not the
-- virtual FS. So bigportraits/faye.xml's reference to "wendy.tex" fails because
-- wendy.tex isn't in the mod folder (it's in bigportraits.zip). Intercepting
-- Image:SetTexture on every widget instance and swapping the three faye paths
-- for wendy's real base-game paths fixes portraits, save-slot icons, and avatars
-- before DST ever touches a file. Widgets don't exist on the dedicated server.
AddClassPostConstruct("widgets/image", function(self)
    local _SetTexture = self.SetTexture
    self.SetTexture = function(self2, atlas, tex, ...)
        if atlas == "bigportraits/faye.xml" then
            atlas, tex = "bigportraits/wendy.xml", "wendy.tex"
        elseif atlas == "images/saveslot_portraits/faye.xml" then
            atlas, tex = "images/saveslot_portraits/wendy.xml", "wendy.tex"
        elseif atlas == "images/avatars/avatar_faye.xml" then
            atlas, tex = "images/avatars/avatar_wendy.xml", "avatar_wendy.tex"
        end
        return _SetTexture(self2, atlas, tex, ...)
    end
end)

-- ─── CHARACTER SELECT STRINGS ────────────────────────────────────────────────
GLOBAL.STRINGS.CHARACTER_NAMES = GLOBAL.STRINGS.CHARACTER_NAMES or {}
GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS = GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS or {}
GLOBAL.STRINGS.CHARACTER_NAMES["faye"]        = "Faye"
GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS["faye"] = "The shadows know her name."

-- ─── OPTIONAL: Load extra strings file ───────────────────────────────────────
-- If you add more strings to scripts/strings/faye_strings.lua, uncomment below.
-- modimport("scripts/strings/faye_strings.lua")
