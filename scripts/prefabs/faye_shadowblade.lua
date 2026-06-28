-- faye_shadowblade.lua
-- scripts/prefabs/faye_shadowblade.lua
-- ============================================================
-- SHADOWBLADE - Faye's starting weapon
-- A sword condensed from shadow. Its damage scales with darkness.
--
-- Stats (v1 placeholder — uses Night Sword art):
--   Damage:    45 base | 58 at night/cave | 30 during day
--   Durability: 200 uses
--   Special:   Stacks with Faye's own 35%/25% day-night combat mults
--
-- Placeholder art: inherits Night Sword (swap_nightsword) animation.
-- Replace OverrideSymbol calls with custom swap build when art is ready.
-- ============================================================

local assets = {
    Asset("SCRIPT", "scripts/prefabs/faye_shadowblade.lua"),
}

-- ─── TUNING ──────────────────────────────────────────────────────────────────
local BASE_DAMAGE  = 45    -- damage in neutral phase (dusk)
local NIGHT_DAMAGE = 58    -- damage at night or in caves
local DAY_DAMAGE   = 30    -- damage during daytime
local DURABILITY   = 200   -- total uses before the blade shatters

-- ─── PHASE HELPER ────────────────────────────────────────────────────────────
-- Mirrors the logic in faye.lua so the weapon always matches her state.
local function GetCurrentDamage()
    if TheWorld:HasTag("cave") then
        return NIGHT_DAMAGE
    end
    local phase = TheWorld.state and TheWorld.state.phase or "day"
    if phase == "night" or phase == "dusk" then
        return NIGHT_DAMAGE
    end
    return DAY_DAMAGE
end

-- ─── EQUIP / UNEQUIP ─────────────────────────────────────────────────────────

local function OnEquip(inst, owner)
    -- ── Set initial damage for current phase ─────────────────────────────────
    if inst.components.weapon then
        inst.components.weapon:SetDamage(GetCurrentDamage())
    end

    -- ── Placeholder visual: borrow Night Sword's hand swap sprite ────────────
    -- "swap_nightsword" is a build file in DST's base game anim folder.
    -- When custom art is ready, replace "swap_nightsword" with your own build.
    owner.AnimState:OverrideSymbol("swap_object", "swap_nightsword", "swap_nightsword")

    -- ── React to phase changes while equipped ─────────────────────────────────
    -- WatchWorldState fires on the natural day/dusk/night transition.
    -- (ListenForEvent("ms_setphase") only fires on forced phase changes, so the
    -- blade's damage would never have updated during normal play.)
    -- We save the callback so we can stop watching on unequip.
    inst._on_phase_change = function(inst, phase)
        if inst.components.weapon then
            inst.components.weapon:SetDamage(GetCurrentDamage())
        end
    end
    inst:WatchWorldState("phase", inst._on_phase_change)
end

local function OnUnequip(inst, owner)
    -- ── Remove the Night Sword swap sprite ───────────────────────────────────
    owner.AnimState:ClearOverrideSymbol("swap_object")

    -- ── Stop watching phase changes ──────────────────────────────────────────
    if inst._on_phase_change then
        inst:StopWatchingWorldState("phase", inst._on_phase_change)
        inst._on_phase_change = nil
    end
end

-- ─── PREFAB FUNCTION ─────────────────────────────────────────────────────────

local function fn()
    local inst = CreateEntity()

    -- Base entity components (needed for a physical world object)
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- ── Placeholder art: use Night Sword animation bank ──────────────────────
    -- The Night Sword bank ("nightsword") exists in DST's base game anim files.
    -- SetBank = which animation ZIP the idle/held/dropped anims come from.
    -- SetBuild = which texture build to apply to those animations.
    -- Both are "nightsword" here, which is safe — the game already has it.
    inst.AnimState:SetBank("nightsword")
    inst.AnimState:SetBuild("nightsword")
    inst.AnimState:PlayAnimation("idle")

    -- Custom tag for identification (e.g. by other scripts or perks)
    inst:AddTag("shadowblade")

    -- Physics so the item can sit on the ground and be picked up
    MakeInventoryPhysics(inst)

    -- Mark network setup done; split from here
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- ── SERVER-ONLY COMPONENTS ───────────────────────────────────────────────

    -- Makes the item show up in inspect text
    inst:AddComponent("inspectable")

    -- Inventory component: allows the item to be picked up and held
    inst:AddComponent("inventoryitem")
    -- Use Night Sword's existing inventory icon (safe — base game file)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/nightsword.xml"
    inst.components.inventoryitem:ChangeImageName("nightsword")

    -- Weapon component: deals damage when used to attack
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(GetCurrentDamage())  -- set correct damage at spawn

    -- Finite uses: the blade has 200 durability points
    -- Each successful attack consumes 1 use.
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(DURABILITY)
    inst.components.finiteuses:SetUses(DURABILITY)
    inst.components.finiteuses:SetOnFinished(inst.Remove)          -- destroy when empty
    inst.components.finiteuses:SetConsumption(ACTIONS.ATTACK, 1)  -- -1 per attack

    -- Equippable: can be held in the hands slot
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    -- Hauntable: reacts to ghost interaction
    MakeHauntable(inst)

    return inst
end

-- ─── REGISTER ────────────────────────────────────────────────────────────────
return Prefab("faye_shadowblade", fn, assets)
