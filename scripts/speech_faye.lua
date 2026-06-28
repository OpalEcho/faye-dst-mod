-- speech_faye.lua
-- scripts/speech_faye.lua
-- ============================================================
-- FAYE - The Elven Shadow Warrior
-- Complete speech file.
-- 
-- DST auto-loads this file via AddModCharacter("faye") and assigns
-- the returned table to STRINGS.CHARACTERS.FAYE.
--
-- Voice: Faye speaks in short, precise lines. She doesn't explain
-- herself — she observes. Poetic but never florid. Fire annoys her.
-- Light offends her. Darkness is home. Monsters are inconveniences.
-- She finds survival slightly beneath her, but does it anyway.
-- ============================================================

return {

    -- ═══════════════════════════════════════════════════════
    -- CUSTOM ANNOUNCE STRINGS (fired from faye.lua at runtime)
    -- ═══════════════════════════════════════════════════════

    -- Phase transitions
    ANNOUNCE_NIGHT    = "Shadows, lend me your strength.",
    ANNOUNCE_DAY      = "The light is a thief.",

    -- Special events
    ANNOUNCE_FULLMOON = "The Lunar God shines on us.",
    ANNOUNCE_CAVE     = "Sanctuary at last.",
    ANNOUNCE_REVIVE   = "The shadows were not finished with me.",
    ANNOUNCE_KILLBOSS = "A worthy foe consumed by the abyss.",
    ANNOUNCE_CHARLIE  = "Touch 'em, touch 'em, grandma.",

    -- ═══════════════════════════════════════════════════════
    -- STANDARD ANNOUNCE STRINGS (triggered by DST systems)
    -- ═══════════════════════════════════════════════════════
    ANNOUNCE_HUNGRY     = "Hunger is an inconvenience.",
    ANNOUNCE_STARVING   = "The light is winning...",        -- low sanity quote doubled as starvation
    ANNOUNCE_COLD       = "The cold is... almost pleasant.",
    ANNOUNCE_HOT        = "Too much heat. Not enough dark.",
    ANNOUNCE_FREEZING   = "Cold enough to slow even me.",
    ANNOUNCE_OVERHEAT   = "The sun is relentless.",
    ANNOUNCE_INSANE     = "The light is winning...",

    -- ═══════════════════════════════════════════════════════
    -- DEATH QUOTE (shown on the death screen)
    -- ═══════════════════════════════════════════════════════
    DEATH_QUOTE = "\"The eternal abyss calls me home.\"",

    -- ═══════════════════════════════════════════════════════
    -- ITEM EXAMINE STRINGS
    -- Keyed by PREFAB_NAME_UPPERCASE. Tables = random selection.
    -- ═══════════════════════════════════════════════════════
    DESCRIBE = {

        -- ─── FAYE'S OWN ITEMS ──────────────────────────────────────
        FAYE_SHADOWBLADE = {
            "An extension of me.",
            "It drinks well.",
            "Shadow given edge.",
        },
        FAYE_TWILIGHT_BLINDFOLD = {
            "It dims the cruelty of the sun.",
            "A necessary shield against the light.",
            "Without it, daylight is... louder.",
        },

        -- ─── FIRE & LIGHT ──────────────────────────────────────────
        FIREPIT = {
            GENERIC = "Hiss... it buuurns!",
            EMBERS  = "Good. Let it die.",
            COLD    = "Cold ash. As it should be.",
            LIT     = "Must we?",
            FUELED  = "Excessive.",
        },
        CAMPFIRE = {
            GENERIC = "Hiss... it buuurns!",
            EMBERS  = "Almost bearable.",
            COLD    = "Better.",
            LIT     = "A necessary evil.",
            FUELED  = "It'll annoy me for a while.",
        },
        FIREFLY = {
            GENERIC = "A creature that carries its own light. I respect the irony.",
        },
        TORCH = {
            GENERIC = "I carry it for others' sake.",
        },
        LIGHTER = {
            GENERIC = "A small betrayal of my nature.",
        },
        LANTERN = {
            GENERIC = "Too bright. But useful.",
        },
        NIGHTLIGHT = {
            GENERIC = "This one I can tolerate.",
        },
        -- (MINERHAT examine string lives in the ARMOR section below — a single
        --  entry, since duplicate Lua table keys silently keep only the last.)

        -- ─── TOOLS ─────────────────────────────────────────────────
        AXE = {
            GENERIC = "Serviceable.",
        },
        GOLDENAXE = {
            GENERIC = "Shiny. Functional.",
        },
        PICKAXE = {
            GENERIC = "Rock is stubborn. I am more so.",
        },
        GOLDENPICKAXE = {
            GENERIC = "Efficient.",
        },
        SHOVEL = {
            GENERIC = "The earth remembers what it buries.",
        },
        GOLDENSHOVEL = {
            GENERIC = "Faster digging. Fewer memories disturbed.",
        },
        RAZOR = {
            GENERIC = "Sharp, quiet, precise. I approve.",
        },
        PITCHFORK = {
            GENERIC = "A farmer's weapon. I've done worse.",
        },
        COMPASS = {
            GENERIC = "Direction has never been my concern.",
        },

        -- ─── WEAPONS ───────────────────────────────────────────────
        SPEAR = {
            GENERIC = "Reach before contact. Logical.",
        },
        NIGHTSWORD = {
            GENERIC = "A pale imitation of my blade.",
        },
        DARKSWORD = {
            GENERIC = "This one understands the dark. Barely.",
        },
        HAMBAT = {
            GENERIC = "Someone died for this. Probably delicious.",
        },
        TENTACLESPIKE = {
            GENERIC = "Something old. Something patient.",
        },
        BOOMERANG = {
            GENERIC = "It returns. Like bad memories.",
        },
        BLOWDART_FIRE = {
            GENERIC = "Fire again. Of course.",
        },
        BLOWDART_SLEEP = {
            GENERIC = "I prefer a more direct method.",
        },

        -- ─── ARMOR ─────────────────────────────────────────────────
        ARMOR_WOOD = {
            GENERIC = "Protection. Crude but present.",
        },
        ARMOR_GRASS = {
            GENERIC = "Better than nothing. Barely.",
        },
        ARMOR_MARBLE = {
            GENERIC = "Heavy. Reliable.",
        },
        ARMOR_SANITY = {
            GENERIC = "Shadow armor. This, I understand.",
        },
        FOOTBALL_HELMET = {
            GENERIC = "Ugly. But effective.",
        },
        MINERHAT = {
            GENERIC = "Unnecessary for me. I see in the dark.",
        },
        MOLE_HAT = {
            GENERIC = "Another sees what I see. Interesting.",
        },
        EYEBRELLA = {
            GENERIC = "Functional. If a bit theatrical.",
        },

        -- ─── FOOD ──────────────────────────────────────────────────
        BERRIES = {
            GENERIC = "Small. Sufficient.",
        },
        BERRIES_COOKED = {
            GENERIC = "Better when warm.",
        },
        MUSHROOM = {
            GENERIC = "Grows in darkness. We share something.",
        },
        MUSHROOM_COOKED = {
            GENERIC = "Warmth changes everything.",
        },
        MEAT = {
            GENERIC = "Something died. I'll not waste it.",
        },
        MORSEL = {
            GENERIC = "Not much. But enough.",
        },
        CARROT = {
            GENERIC = "A daytime vegetable. The irony is not lost on me.",
        },
        MEATBALLS = {
            GENERIC = "Adequate.",
        },
        DRAGONPIE = {
            GENERIC = "Something that old should be respected, not eaten.",
        },
        HONEY = {
            GENERIC = "Bees are relentless. I respect that.",
        },
        JERKY = {
            GENERIC = "Preserved. Practical.",
        },
        DURIAN = {
            GENERIC = "Pungent. I find it honest.",
        },
        POMEGRANATE = {
            GENERIC = "Bright red. The one fruit I find acceptable.",
        },

        -- ─── CROCKPOT ──────────────────────────────────────────────
        COOKPOT = {
            GENERIC = "From scraps to sustenance.",
        },
        CROCKPOT = {
            GENERIC = "Transformation. Even food can change.",
        },

        -- ─── RESOURCES ─────────────────────────────────────────────
        LOG = {
            GENERIC = "The forest yields to the blade.",
        },
        ROCKS = {
            GENERIC = "Patient. Heavy. Useful.",
        },
        FLINT = {
            GENERIC = "Prehistoric utility.",
        },
        GOLD = {
            GENERIC = "Shiny. I've seen more beautiful things in shadow.",
        },
        CUTGRASS = {
            GENERIC = "For weaving. Everything has a purpose.",
        },
        TWIGS = {
            GENERIC = "Fragile bones of the forest.",
        },
        SILK = {
            GENERIC = "Something died for this too.",
        },
        PIGSKIN = {
            GENERIC = "Useful material. Poor creature.",
        },
        NITRE = {
            GENERIC = "Bitter mineral. Good for explosions.",
        },
        NIGHTMAREFUEL = {
            GENERIC = "This is real. More real than most things here.",
        },
        GEARS = {
            GENERIC = "Made by something patient and precise.",
        },
        BOARDS = {
            GENERIC = "Refined from raw. There's a lesson in that.",
        },
        ROPE = {
            GENERIC = "Restraint. Or rescue. Depends.",
        },
        PAPYRUS = {
            GENERIC = "Knowledge, preserved.",
        },
        PURPLEGEM = {
            GENERIC = "This one is mine.",
        },
        BLUEGEM = {
            GENERIC = "Cold light. Acceptable.",
        },
        REDGEM = {
            GENERIC = "Too much fire inside it.",
        },
        YELLOWGEM = {
            GENERIC = "The sun, crystallised. I'll carry it but I won't like it.",
        },
        ORANGEGEM = {
            GENERIC = "Bright. Irritating.",
        },
        GREENGEM = {
            GENERIC = "Nature's light. Neutral.",
        },

        -- ─── STRUCTURES ────────────────────────────────────────────
        SCIENCEMACHINE = {
            GENERIC = "Someone tried to explain this world. Admirable.",
        },
        ALCHEMYMACHINE = {
            GENERIC = "Deeper understanding. Better.",
        },
        CHEST = {
            GENERIC = "Storage. Civilisation's concession to mortality.",
        },
        ICEBOX = {
            GENERIC = "Cold preserves. I know this.",
        },
        -- (CROCKPOT examine string lives in the CROCKPOT section above. Note the
        --  real prefab is "cookpot" — COOKPOT — so that is the key the game uses.)
        TENT = {
            GENERIC = "For daylight rest. When the sun demands it.",
        },
        BEDROLL_STRAW = {
            GENERIC = "Minimal. Functional.",
        },
        BEDROLL_FURRY = {
            GENERIC = "Extravagant. I'll rest here.",
        },
        FARM = {
            GENERIC = "Patience made tangible.",
        },
        BEEBOX = {
            GENERIC = "The bees answer to no one. A trait I respect.",
        },
        LIGHTNING_ROD = {
            GENERIC = "Redirect the chaos. Wise.",
        },
        SEWING_KIT = {
            GENERIC = "Repair. Nothing is beyond saving.",
        },
        RESEARCHLAB = {
            GENERIC = "Someone tried to understand this place. Brave.",
        },

        -- ─── CREATURES ─────────────────────────────────────────────
        SPIDER = {
            GENERIC  = "Patient hunters. We have something in common.",
            SLEEPING = "Even hunters rest.",
            DEAD     = "Its patience ran out.",
        },
        PIG = {
            GENERIC   = "Almost reasonable. Don't push it.",
            DEAD      = "Unnecessary.",
            SLEEPING  = "Pigs dream. I wonder what of.",
        },
        BEEFALO = {
            GENERIC   = "Enormous and stubborn. I respect it.",
            SLEEPING  = "Let it sleep.",
            FOLLOWER  = "We have an arrangement.",
        },
        RABBIT = {
            GENERIC  = "Quick. Small. Too bright for my taste.",
            SLEEPING = "Even the small rest.",
        },
        HOUND = {
            GENERIC  = "They answer to something I cannot see. Useful to know.",
            SLEEPING = "Dogs dream of the hunt.",
            DEAD     = "The hunt ends here.",
        },
        DEER = {
            GENERIC = "Graceful. Alert. I can respect that.",
        },
        FROG = {
            GENERIC = "Amphibious. Adaptable.",
        },
        CROW = {
            GENERIC = "A bird that knows the night. kin.",
        },
        ROBIN = {
            GENERIC = "Too cheerful. Too much light in its song.",
        },
        BUTTERFLY = {
            GENERIC = "Daylight made manifest. Irritating.",
        },
        BEE = {
            GENERIC = "Diligent. Dangerous. Don't underestimate small things.",
        },
        KILLERBEE = {
            GENERIC = "More aggressive. More interesting.",
        },

        -- ─── BOSSES ────────────────────────────────────────────────
        DEERCLOPS = {
            GENERIC = "Ancient. Cyclopic. A worthy test.",
        },
        BEARGER = {
            GENERIC = "A mountain given hunger.",
        },
        DRAGONFLY = {
            GENERIC = "Something that old shouldn't still be awake.",
        },
        MOOSEGOOSE = {
            GENERIC = "Seasonal fury in animal form.",
        },
        TOADSTOOL = {
            GENERIC = "A king of the dark deep. I respect that.",
        },
        CRABKING = {
            GENERIC = "Ancient. Armored. Persistent.",
        },

        -- ─── WORLD OBJECTS ─────────────────────────────────────────
        MULTIPLAYER_PORTAL = {
            GENERIC = "How I arrived. I don't ask it to explain itself.",
        },
        SKELETON = {
            GENERIC = "Someone didn't survive. They weren't careful enough.",
        },
        GRAVESTONE = {
            GENERIC = "Rest is permanent here. Remember that.",
        },
        RUINS_STATUE = {
            GENERIC = "Old power. Sleeping. Don't wake it.",
        },
        MAXWELL_THRONE = {
            GENERIC = "Power has a cost. This is what it looks like.",
        },
        TENTACLE = {
            GENERIC = "This world has things living inside it. Interesting.",
        },
        WALRUS_CAMP = {
            GENERIC = "Someone else lives here. Noted.",
        },

        -- ─── SHADOW / NIGHTMARE ITEMS ──────────────────────────────
        CODEX_UMBRA = {
            GENERIC = "Written in shadow. I can almost read it.",
        },
        SHADOW_CHESTER = {
            GENERIC = "A creature of shadow and purpose. I respect you.",
        },
        NIGHTMARE_ARMOR = {
            GENERIC = "Shadow-forged protection. This is mine.",
        },
        NIGHT_ARMOR = {
            GENERIC = "The dark made solid. Fitting.",
        },
        LIVING_LOG = {
            GENERIC = "Still alive. Still fighting.",
        },
        TENTACLE_PILLAR = {
            GENERIC = "Ancient and patient.",
        },

        -- ─── THE MOON ──────────────────────────────────────────────
        MOONROCK = {
            GENERIC = "Lunar stone. Cold and distant. I approve.",
        },
        MOONTREE = {
            GENERIC = "The moon grows things. I didn't know.",
        },

    }, -- end DESCRIBE

} -- end return
