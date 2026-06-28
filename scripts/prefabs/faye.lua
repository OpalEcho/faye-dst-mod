-- faye.lua
-- scripts/prefabs/faye.lua
-- ============================================================
-- FAYE - The Elven Shadow Warrior
-- An elven warrior naturally bonded to darkness:
--   * Permanent night vision (light source, Charlie immune)
--   * Powered by darkness: damage up, sanity gain, hunger slows
--   * Weakened by daylight: sanity drain, hunger spike, damage down
--   * 25% damage reduction (innate armor)
--   * 10% life steal on hit
--   * Can ONLY sleep during daytime (handled in modmain.lua)
--
-- NOTE ON STRUCTURE:
-- player_common's MakePlayerCharacter BUILDS the entity for us. We must
-- NOT call CreateEntity / AddTransform ourselves and we must NOT call
-- MakePlayerCharacter(inst, ...). Instead we hand it two callbacks:
--   common_postinit(inst) -> runs on BOTH client and server
--   master_postinit(inst) -> runs on the SERVER / host only
-- and we RETURN MakePlayerCharacter(...).
-- ============================================================

local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/faye.lua"),
}

-- Prefabs this character depends on at spawn (its starting items).
local prefabs = {
    "faye_shadowblade",
    "faye_twilight_blindfold",
}

-- ─── STARTING INVENTORY ──────────────────────────────────────────────────────
-- Passed to MakePlayerCharacter as the starting_inventory argument.
-- player_common gives these ONLY on a brand-new spawn and persists the
-- inventory afterwards, so they are not duplicated on respawn / reconnect.
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
local NIGHTVISION_RANGE     = 3
local NIGHTVISION_FALLOFF   = 0.7
local NIGHTVISION_INTENSITY = 0.4
local NIGHTVISION_R         = 0.4   -- subtle purple color
local NIGHTVISION_G         = 0.0
local NIGHTVISION_B         = 0.6

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
-- "onhitother" fires on the attacker AFTER damage resolves and carries
-- data.damage (unlike "onattackother", which fires at swing time and may not).

local function SetupLifeSteal(inst)
    inst:ListenForEvent("onhitother", function(inst, data)
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

-- ─── COMMON POSTINIT (runs on BOTH client and server) ────────────────────────
-- The night-vision light lives here so it exists on every machine: that way it
-- renders for all players AND Faye's own LightWatcher reads her as "in light",
-- which is what actually stops Charlie / the grue from attacking her.

local function common_postinit(inst)
    inst.entity:AddLight()
    inst.Light:SetRadius(NIGHTVISION_RANGE)
    inst.Light:SetFalloff(NIGHTVISION_FALLOFF)
    inst.Light:SetIntensity(NIGHTVISION_INTENSITY)
    inst.Light:SetColour(NIGHTVISION_R, NIGHTVISION_G, NIGHTVISION_B)
    inst.Light:Enable(true)
end

-- ─── MASTER POSTINIT (runs on the SERVER / host only) ────────────────────────

local function master_postinit(inst)
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

    -- ── BLINDFOLD FLAG ──────────────────────────────────────────────────────
    -- Set by faye_twilight_blindfold.lua's OnEquip/OnUnequip. Used by TickSanity
    -- to reduce daytime sanity drain. On game load the inventory re-equips items
    -- and re-fires OnEquip, so this flag is restored without manual save/load.
    inst._blindfold_equipped = false

    -- ── INITIAL PHASE STATS ──────────────────────────────────────────────────
    UpdatePhaseStats(inst)

    -- ── PHASE CHANGE WATCHER ─────────────────────────────────────────────────
    -- WatchWorldState fires on the actual day/dusk/night transition (the
    -- "ms_setphase" event is an inbound command and does NOT fire on the
    -- natural clock cycle, which is why the previous version never updated).
    inst:WatchWorldState("phase", function(inst, phase)
        UpdatePhaseStats(inst)
        if phase == "night" then
            SayFaye(inst, "ANNOUNCE_NIGHT")
        elseif phase == "day" then
            SayFaye(inst, "ANNOUNCE_DAY")
        end
        -- Dusk: no announcement (neutral transition)
    end)

    -- ── FULL MOON ────────────────────────────────────────────────────────────
    inst:WatchWorldState("isfullmoon", function(inst, isfullmoon)
        if isfullmoon then
            SayFaye(inst, "ANNOUNCE_FULLMOON")
        end
    end)

    -- ── CAVE SPAWN ANNOUNCE ──────────────────────────────────────────────────
    -- The cave is a separate server shard. When Faye migrates to it she spawns
    -- fresh on that shard. UpdatePhaseStats already treats caves as dark.
    if TheWorld:HasTag("cave") then
        inst:DoTaskInTime(2.0, function()
            SayFaye(inst, "ANNOUNCE_CAVE")
        end)
    end

    -- ── BOSS KILL ANNOUNCE ───────────────────────────────────────────────────
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
    inst:ListenForEvent("respawnfromghost", function(inst)
        SayFaye(inst, "ANNOUNCE_REVIVE")
    end)

    -- ── DEFENSE: CHARLIE IMMUNITY + 25% ARMOR ───────────────────────────────
    SetupDefense(inst)

    -- ── LIFE STEAL ───────────────────────────────────────────────────────────
    SetupLifeSteal(inst)

    -- ── PERIODIC SANITY ──────────────────────────────────────────────────────
    inst:DoPeriodicTask(SANITY_TICK, TickSanity)

    -- Sleep restriction (Faye can only sleep in daylight) is implemented in
    -- modmain.lua via AddComponentPostInit("sleepingbag", ...), because the
    -- player entity has no "sleeper" component to wrap.
end

-- ─── REGISTER ────────────────────────────────────────────────────────────────
return MakePlayerCharacter("faye", prefabs, assets, common_postinit, master_postinit, start_inv)
