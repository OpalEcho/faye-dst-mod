-- faye_twilight_blindfold.lua
-- scripts/prefabs/faye_twilight_blindfold.lua
-- ============================================================
-- TWILIGHT BLINDFOLD - Faye's starting armor
-- A silken blindfold that shields Faye from the worst of daylight.
--
-- Stats (v1 placeholder — uses Mole Hat art):
--   Slot:        Head
--   Armor:       20% damage absorption, 100 durability
--   Faye bonus:  While equipped, reduces daytime sanity drain from
--                ~15/min to ~4.5/min (she can tolerate the sun)
--   Lore:        The blindfold does NOT give night vision — that's
--                innate to Faye. It simply dims the sun's assault.
--
-- Placeholder art: borrows Mole Hat (mole_hat) animation bank.
-- Replace OverrideSymbol calls with custom build when art is ready.
-- ============================================================

local assets = {
    Asset("SCRIPT", "scripts/prefabs/faye_twilight_blindfold.lua"),
}

-- ─── TUNING ──────────────────────────────────────────────────────────────────
local ARMOR_USES       = 100   -- durability (hits absorbed before the item breaks)
local ARMOR_ABSORPTION = 0.20  -- 20% of damage absorbed (same as Leather Armor)
-- Note: for reference, Football Helmet = 80% / Wood Armor = 80% / Grass Suit = 60%
-- 20% is light armor — enough to matter without making her a tank in daylight.

-- ─── EQUIP / UNEQUIP ─────────────────────────────────────────────────────────

local function OnEquip(inst, owner)
    -- ── Placeholder visual: borrow Mole Hat's head swap sprite ───────────────
    -- "mole_hat" is a build file in DST's base game anim folder.
    -- swap_hat is the symbol slot on the player character for head items.
    -- When custom art is ready, replace "mole_hat" with your own build name.
    owner.AnimState:OverrideSymbol("swap_hat", "mole_hat", "swap_hat")

    -- ── Faye-specific: activate blindfold protection ──────────────────────────
    -- This flag is read by faye.lua's TickSanity function every 4 seconds.
    -- If true, daytime sanity drain is reduced to SANITY_DAY_BLINDFOLD rate.
    -- We check HasTag("faye") so the item works on any player but only
    -- activates the special effect when Faye herself equips it.
    if owner:HasTag("faye") then
        owner._blindfold_equipped = true
    end
end

local function OnUnequip(inst, owner)
    -- ── Remove Mole Hat head sprite ───────────────────────────────────────────
    owner.AnimState:ClearOverrideSymbol("swap_hat")

    -- ── Faye-specific: deactivate blindfold protection ───────────────────────
    if owner:HasTag("faye") then
        owner._blindfold_equipped = false
    end
end

-- ─── PREFAB FUNCTION ─────────────────────────────────────────────────────────

local function fn()
    local inst = CreateEntity()

    -- Base entity components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- ── Placeholder art: use Mole Hat animation bank ─────────────────────────
    -- "mole_hat" animation bank exists in DST's base game.
    -- This makes the item look like a Mole Hat when dropped on the ground.
    inst.AnimState:SetBank("mole_hat")
    inst.AnimState:SetBuild("mole_hat")
    inst.AnimState:PlayAnimation("idle")

    -- Custom identification tag
    inst:AddTag("twilight_blindfold")

    -- Physics for ground placement
    MakeInventoryPhysics(inst)

    -- Mark network setup done
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- ── SERVER-ONLY COMPONENTS ───────────────────────────────────────────────

    -- Inspect text (uses STRINGS.CHARACTERS.*.DESCRIBE.FAYE_TWILIGHT_BLINDFOLD)
    inst:AddComponent("inspectable")

    -- Inventory item
    inst:AddComponent("inventoryitem")
    -- Use Mole Hat's existing inventory icon (safe — base game file)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mole_hat.xml"
    inst.components.inventoryitem:ChangeImageName("mole_hat")

    -- Equippable: worn in the head slot
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    -- Armor component: absorbs a portion of incoming damage
    -- InitCondition(max_uses, absorption_percent)
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(ARMOR_USES, ARMOR_ABSORPTION)

    -- Hauntable
    MakeHauntable(inst)

    return inst
end

-- ─── REGISTER ────────────────────────────────────────────────────────────────
return Prefab("faye_twilight_blindfold", fn, assets)
