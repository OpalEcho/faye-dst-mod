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

-- ─── SPEECH ──────────────────────────────────────────────────────────────────
-- DST does NOT auto-load a mod character's speech file. We must require it
-- ourselves and assign it to STRINGS.CHARACTERS.<NAME-UPPER>. Without this,
-- STRINGS.CHARACTERS.FAYE stays nil and every custom quote, the death quote,
-- and all examine overrides silently do nothing.
GLOBAL.STRINGS.CHARACTERS.FAYE = GLOBAL.require("speech_faye")

-- ─── CHARACTER SELECT SCREEN STRINGS ─────────────────────────────────────────
-- Keys are the LOWERCASE prefab name. AddModCharacter does not set these for us.
GLOBAL.STRINGS.CHARACTER_NAMES.faye        = "Faye"
GLOBAL.STRINGS.CHARACTER_TITLES.faye       = "The Elven Shadow Warrior"
GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS.faye =
    "*Sees in the dark and cannot be harmed by Charlie\n" ..
    "*Stronger at night and in caves, weakened by daylight\n" ..
    "*Gains sanity in darkness, loses it in the sun"
GLOBAL.STRINGS.CHARACTER_QUOTES.faye       = "\"The shadows call me home.\""

-- ─── CHARACTER REGISTRATION ──────────────────────────────────────────────────
-- Registers Faye on the character select screen.
-- "FEMALE" sets her pronouns in shared world speech and announcements.
AddModCharacter("faye", "FEMALE")

-- ─── SLEEP RESTRICTION ───────────────────────────────────────────────────────
-- Faye can ONLY sleep during the day. The player entity has no "sleeper"
-- component to wrap, so we hook the "sleepingbag" component (used by tents and
-- bedrolls) and refuse the sleep when Faye tries it while it is dark.
AddComponentPostInit("sleepingbag", function(self)
    local _DoSleep = self.DoSleep
    function self:DoSleep(sleeper, ...)
        if sleeper ~= nil and sleeper:HasTag("faye") then
            local world = GLOBAL.TheWorld
            local is_dark = world ~= nil and (
                world:HasTag("cave")
                or (world.state and (world.state.isnight or world.state.isdusk))
            )
            if is_dark then
                if sleeper.components.talker ~= nil then
                    sleeper.components.talker:Say(
                        "Sleep while the shadows play? No. Rest is for daylight."
                    )
                end
                return  -- refuse: no sleep at night / dusk / in caves
            end
        end
        return _DoSleep(self, sleeper, ...)
    end
end)

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
