-- modmain.lua
-- ============================================================
-- FAYE - The Elven Shadow Warrior
-- Entry point: registers character, loads prefabs, sets strings.
-- NO custom art assets declared here - all placeholder art uses
-- base-game files, which are always present.
-- ============================================================

-- ─── ASSETS ──────────────────────────────────────────────────────────────────
-- Empty for now. We reference ONLY base-game art files (nightsword, mole_hat),
-- which DST already has loaded. Do NOT list files that don't exist in your mod
-- folder here — that's what caused "Dedicated server failed to start."
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
-- DST auto-loads scripts/speech_faye.lua and assigns it to
-- STRINGS.CHARACTERS.FAYE when the language system initialises.
AddModCharacter("faye", "FEMALE")

-- ─── ITEM NAMES ──────────────────────────────────────────────────────────────
-- STRINGS.NAMES keys must be UPPERCASE versions of the prefab name.
-- The game looks up STRINGS.NAMES[prefab:upper()] for the display name.
GLOBAL.STRINGS.NAMES.FAYE_SHADOWBLADE           = "Shadowblade"
GLOBAL.STRINGS.NAMES.FAYE_TWILIGHT_BLINDFOLD    = "Twilight Blindfold"

-- ─── ITEM DESCRIPTIONS (recipe tooltips / item inspect text) ─────────────────
GLOBAL.STRINGS.RECIPE_DESC.FAYE_SHADOWBLADE         = "A blade forged from condensed shadow. Deadly in darkness."
GLOBAL.STRINGS.RECIPE_DESC.FAYE_TWILIGHT_BLINDFOLD  = "A silken blindfold that dims the cruelty of daylight."

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

-- ─── OPTIONAL: Load extra strings file ───────────────────────────────────────
-- If you add more strings to scripts/strings/faye_strings.lua, uncomment below.
-- modimport("scripts/strings/faye_strings.lua")
