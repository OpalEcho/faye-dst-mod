-- faye.lua
-- scripts/prefabs/faye.lua
-- ============================================================
-- FAYE - The Elven Shadow Warrior
-- An elven warrior naturally bonded to darkness:
--   * Permanent night vision (light emitter, Charlie immune)
--   * Powered by darkness: damage up, sanity gain, hunger slows
--   * Weakened by daylight: sanity drain, hunger spike, damage down
--   * 25% damage reduction (innate armor)
--   * 10% life steal on hit
--   * Can ONLY sleep during daytime (darkness is too inviting)
-- ============================================================

local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/faye.lua"),
}

-- ─── STARTING INVENTORY ──────────────────────────────────────────────────────
local start_inv = {
    "faye_shadowblade",
    "faye_twilight_blindfold",
}

-- ─── TUNING ──────────────────────────────────────────────────────────────────

-- Base stats
local MAXHEALTH = 150
local MAXHUNGER = 100   -- lower than Wilson (150) — she's slight, not a big eater
local MAXSANITY = 200

-- Combat multipliers (stacks with Shadowblade's own scaling)
local NIGHT_DMG_MULT = 1.35  -- 35% more damage at night / in caves
local DAY_DMG_MULT   = 0.75  -- 25% less damage during day

-- Hunger drain rates (relative to Wilson's baseline)
local NIGHT_HUNGER   = TUNING.WILSON_HUNGER_RATE * 0.75  -- 25% slower at night
local DAY_HUNGER     = TUNING.WILSON_HUNGER_RATE * 1.50  -- 50% faster during day

-- Sanity per periodic tick (tick fires every SANITY_TICK seconds)
local SANITY_TICK          = 4      -- seconds between sanity updates
local SANITY_NIGHT         =  1.0   -- gain 1 per tick at night/cave (~15/min)
local SANITY_DAY           = -1.0   -- lose 1 per tick during day (~15/min drain)
local SANITY_DAY_BLINDFOLD = -0.30  -- with Twilight Blindfold equipped (~4.5/min)

-- Damage reduction: % of incoming damage healed back after the hit
local DMG_REDUCTION  = 0.25  -- 25% innate armor

-- Life steal: % of damage dealt restored as health
local LIFESTEAL_PCT  = 0.10  -- 10% life steal

-- Quote cooldowns (seconds between repeated announcements)
local CHARLIE_SAY_COOLDOWN = 12
local BOSS_SAY_COOLDOWN    = 30

-- Night vision light (subtle purple glow — also prevents Charlie targeting)
-- Range 3, falloff 0.7, intensity 0.4 → dim but enough to keep Charlie away
local NIGHTVISION_RANGE    = 3
local NIGHTVISION_FALLOFF  = 0.7
local NIGHTVISION_INTENSITY = 0.4
local NIGHTVISION_R        = 0.4   -- subtle purple color
local NIGHTVISION_G        = 0.0
local NIGHTVISION_B        = 0.6

-- ─── HELPERS ─────────────────────────────────────────────────────────────────

-- Returns true when Faye should be in her "dark" (powered) state.
-- Covers: nighttime, dusk, and the entire cave shard (always dark).
local function IsDark()
    if TheWorld:HasTag("cave") then
        return true
    end
    local phase = TheWorld.state and TheWorld.state.phase or "day"
    return phase == "night" or phase == "dusk"
end

-- Returns true when it is full, surface daytime.
local function IsDay()
    if TheWorld:HasTag("cave") then
        return false   -- no daytime underground
    end
    local phase = TheWorld.state and TheWorld.state.phase or "day"
    return phase == "day"
end

-- Safe string lookup for Faye's announce strings.
-- Avoids nil errors if speech file hasn't loaded yet.
local function SayFaye(inst, key)
    if not inst.components.talker then return end
    if inst.components.health and inst.components.health:IsDead() then return end
    local str = STRINGS.CHARACTERS.FAYE
    if str and str[key] then
        inst.components.talker:Say(str[key])
    end
end

-- ─── UPDATE PHASE STATS ──────────────────────────────────────────────────────
-- Called on spawn and whenever phase changes.
-- Adjusts combat multiplier and hunger drain rate.

local function UpdatePhaseStats(inst)
    if IsDark() then
        -- NIGHT / CAVE: powered state
        if inst.components.combat then
            inst.components.combat.damagemultiplier = NIGHT_DMG_MULT
        end
        if inst.components.hunger then
            inst.components.hunger.hungerrate = NIGHT_HUNGER
        end
    else
        -- DAY: weakened state
        if inst.components.combat then
            inst.components.combat.damagemultiplier = DAY_DMG_MULT
        end
        if inst.components.hunger then
            inst.components.hunger.hungerrate = DAY_HUNGER
        end
    end
end

-- ─── CHARLIE IMMUNITY + GENERAL DAMAGE REDUCTION ─────────────────────────────
-- Listens for the "attacked" event and:
--   (a) Fully heals Charlie damage (she is immune to darkness)
--   (b) Heals back 25% of all other incoming damage (innate armor)
-- Both effects work by healing AFTER damage is applied, so they're
-- compatible with the standard health system without patching combat.lua.

local function SetupDefense(inst)
    inst._charlie_say_time = -999  -- initialise to allow first quote immediately

    inst:ListenForEvent("attacked", function(inst, data)
        if not data then return end
        if not (inst.components.health and not inst.components.health:IsDead()) then return end

        local attacker = data.attacker
        local dmg      = data.damage or 0

        -- ── Charlie / darkness immunity ─────────────────────────
        -- Darkness entities in DST spawn as prefab "nightmonster".
        -- We also check for the "shadow" tag to be safe with mods.
        local is_charlie = false
        if attacker then
            is_charlie = (attacker.prefab == "nightmonster")
                or (attacker.prefab == "charlie")
                or (attacker:HasTag("shadow") and not attacker:HasTag("player"))
        end

        if is_charlie then
            -- Restore all Charlie damage (full immunity)
            if dmg > 0 then
                inst.components.health:DoDelta(dmg, false, "charlie_immune", true)
            end
            -- Faye senses Charlie but isn't afraid — play her unique quote
            local now = GetTime()
            if (now - inst._charlie_say_time) >= CHARLIE_SAY_COOLDOWN then
                inst._charlie_say_time = now
                SayFaye(inst, "ANNOUNCE_CHARLIE")
            end
            return  -- Skip the armor reduction for Charlie
        end

        -- ── General 25% damage reduction ───────────────────────
        -- Applies to all other damage sources (monsters, traps, etc.)
        if dmg > 0 then
            local reduction = math.max(1, math.floor(dmg * DMG_REDUCTION))
            inst.components.health:DoDelta(reduction, false, "faye_armor", true)
        end
    end)
end

-- ─── LIFE STEAL ──────────────────────────────────────────────────────────────
-- Heals Faye for 10% of every hit she lands.
-- "onattackother" fires on the player entity (not the weapon) after each attack.

local function SetupLifeSteal(inst)
    inst:ListenForEvent("onattackother", function(inst, data)
        if not data then return end
        if not (inst.components.health and not inst.components.health:IsDead()) then return end

        local dmg = data.damage or 0
        if dmg <= 0 then return end

        local heal = math.max(1, math.floor(dmg * LIFESTEAL_PCT))
        inst.components.health:DoDelta(heal, false, "faye_lifesteal", true)
    end)
end

-- ─── PERIODIC SANITY TICK ────────────────────────────────────────────────────
-- Replaces DST's default darkness sanity drain with Faye's inverted system:
--   * Dark / cave → gain sanity
--   * Daytime      → lose sanity (reduced if wearing Twilight Blindfold)
-- Note: inst.components.sanity.neg_aura_mult = 0 prevents the default dark drain.

local function TickSanity(inst)
    if not inst.components.sanity then return end
    if inst.components.health and inst.components.health:IsDead() then return end

    if IsDark() then
        -- In darkness she's home — she calms down
        inst.components.sanity:DoDelta(SANITY_NIGHT, nil, "faye_dark")
    elseif IsDay() then
        -- Daylight is overwhelming — she loses her mind
        local rate = (inst._blindfold_equipped and SANITY_DAY_BLINDFOLD) or SANITY_DAY
        inst.components.sanity:DoDelta(rate, nil, "faye_day")
    end
    -- Dusk: neutral — no sanity change during dusk
end

-- ─── SLEEP RESTRICTION ───────────────────────────────────────────────────────
-- Faye can ONLY sleep during the day (her weakness — sunlight gives her rest).
-- At night the shadows are too alive to ignore.

local function SetupSleepRestriction(inst)
    if not inst.components.sleeper then return end

    local original_GoToSleep = inst.components.sleeper.GoToSleep
    inst.components.sleeper.GoToSleep = function(self, ...)
        if IsDark() then
            -- Can't sleep — it's night / we're in a cave
            if inst.components.talker then
                inst.components.talker:Say(
                    "Sleep while the shadows play? No. Rest is for daylight."
                )
            end
            return false
        end
        -- It's daytime — allowed to sleep
        return original_GoToSleep(self, ...)
    end
end

-- ─── NIGHT VISION LIGHT ──────────────────────────────────────────────────────
-- Adds a subtle personal light source to Faye.
-- Effect 1: Prevents Charlie from targeting her (she always has "enough light").
-- Effect 2: Provides a dim purple glow so she can see in dark areas.
-- Effect 3: Does NOT replace the need for torches if other players are present.

local function SetupNightVision(inst)
    inst:AddComponent("lightemitter")
    inst.components.lightemitter:SetLight(
        NIGHTVISION_RANGE,
        NIGHTVISION_FALLOFF,
        NIGHTVISION_INTENSITY
    )
    inst.components.lightemitter:SetColour(
        NIGHTVISION_R,
        NIGHTVISION_G,
        NIGHTVISION_B
    )
    inst.components.lightemitter:Enable(true)
end

-- ─── MAIN PREFAB FUNCTION ────────────────────────────────────────────────────

local function fn()
    local inst = CreateEntity()

    -- Standard DST player entity setup (ORDER MATTERS — do not rearrange)
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    -- Apply the base player character framework:
    -- locomotion, inventory, combat, health, hunger, sanity, crafting, etc.
    MakePlayerCharacter(inst, assets)

    -- ── Mark network setup complete ──────────────────────────────────────────
    -- Everything ABOVE this line runs on BOTH server and clients.
    -- Everything BELOW runs ONLY on the server / host.
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- ── SERVER-ONLY SETUP ────────────────────────────────────────────────────

    -- Custom tag so items can check "is my owner Faye?"
    inst:AddTag("faye")

    -- ── STATS ────────────────────────────────────────────────────────────────
    inst.components.health:SetMaxHealth(MAXHEALTH)
    inst.components.hunger:SetMax(MAXHUNGER)
    inst.components.sanity:SetMax(MAXSANITY)

    -- Darkness does NOT drain Faye's sanity.
    -- neg_aura_mult = 0 disables the default "standing in the dark" sanity loss.
    -- Our periodic task handles her custom inverted sanity system instead.
    inst.components.sanity.neg_aura_mult = 0

    -- ── NIGHT VISION + CHARLIE IMMUNITY ─────────────────────────────────────
    -- Personal light → prevents Charlie attack logic, faint purple glow.
    SetupNightVision(inst)

    -- ── BLINDFOLD FLAG ──────────────────────────────────────────────────────
    -- Set by faye_twilight_blindfold.lua when equipped / unequipped.
    -- Used by TickSanity to reduce daytime sanity drain.
    inst._blindfold_equipped = false

    -- ── INITIAL PHASE STATS ──────────────────────────────────────────────────
    UpdatePhaseStats(inst)

    -- ── PHASE CHANGE LISTENER ────────────────────────────────────────────────
    inst:ListenForEvent("ms_setphase", TheWorld, function(world, data)
        UpdatePhaseStats(inst)

        -- Announce the transition
        if data and data.phase then
            if data.phase == "night" then
                SayFaye(inst, "ANNOUNCE_NIGHT")
            elseif data.phase == "day" then
                SayFaye(inst, "ANNOUNCE_DAY")
            end
            -- Dusk: no announcement (neutral transition)
        end
    end)

    -- ── FULL MOON ────────────────────────────────────────────────────────────
    inst:ListenForEvent("ms_fullmoon", TheWorld, function()
        SayFaye(inst, "ANNOUNCE_FULLMOON")
    end)

    -- ── CAVE SPAWN ANNOUNCE ──────────────────────────────────────────────────
    -- The cave is a separate server shard. When Faye migrates to it, she
    -- spawns fresh on that shard. Detect this and announce "Sanctuary."
    if TheWorld:HasTag("cave") then
        UpdatePhaseStats(inst)  -- Cave is always dark — apply night stats
        inst:DoTaskInTime(2.0, function()
            SayFaye(inst, "ANNOUNCE_CAVE")
        end)
    end

    -- ── BOSS KILL ANNOUNCE ───────────────────────────────────────────────────
    -- Fires when Faye lands the killing blow on an epic (boss) enemy.
    -- The "killed" event fires on the attacker with data.victim = the dead entity.
    inst._boss_say_time = -999
    inst:ListenForEvent("killed", function(inst, data)
        if not (data and data.victim) then return end
        if data.victim:HasTag("epic") then
            local now = GetTime()
            if (now - inst._boss_say_time) >= BOSS_SAY_COOLDOWN then
                inst._boss_say_time = now
                SayFaye(inst, "ANNOUNCE_KILLBOSS")
            end
        end
    end)

    -- ── REVIVE FROM GHOST ────────────────────────────────────────────────────
    -- Fires when the player respawns after being a ghost.
    inst:ListenForEvent("respawnfromghost", function()
        SayFaye(inst, "ANNOUNCE_REVIVE")
    end)

    -- ── DEFENSE: CHARLIE IMMUNITY + 25% ARMOR ───────────────────────────────
    SetupDefense(inst)

    -- ── LIFE STEAL ───────────────────────────────────────────────────────────
    SetupLifeSteal(inst)

    -- ── PERIODIC SANITY ──────────────────────────────────────────────────────
    inst:DoPeriodicTask(SANITY_TICK, TickSanity)

    -- ── SLEEP RESTRICTION ────────────────────────────────────────────────────
    SetupSleepRestriction(inst)

    -- ── SAVE / LOAD ──────────────────────────────────────────────────────────
    -- start_given: prevents starting items from being given on every respawn.
    -- We use a local variable captured by the OnLoad/OnSave/DoTaskInTime closures.
    local start_given = false

    inst.OnLoad = function(inst, data)
        if data then
            if data.start_given ~= nil then
                start_given = data.start_given
            end
            if data.blindfold_equipped ~= nil then
                inst._blindfold_equipped = data.blindfold_equipped
            end
        end
    end

    inst.OnSave = function(inst, data)
        data.start_given        = start_given
        data.blindfold_equipped = inst._blindfold_equipped or false
    end

    -- ── STARTING ITEMS ───────────────────────────────────────────────────────
    -- DoTaskInTime(0, ...) fires at the start of the NEXT frame.
    -- By that time, OnLoad will have run (if this is a saved game),
    -- setting start_given = true, so we don't duplicate items on load.
    inst:DoTaskInTime(0, function()
        if not start_given and inst.components.inventory then
            start_given = true
            for _, prefabname in ipairs(start_inv) do
                local item = SpawnPrefab(prefabname)
                if item then
                    inst.components.inventory:GiveItem(item)
                else
                    print("[FAYE MOD] WARNING: Could not spawn starting item: " .. tostring(prefabname))
                end
            end
        end
    end)

    return inst
end

-- ─── REGISTER ────────────────────────────────────────────────────────────────
return Prefab("faye", fn, assets)
