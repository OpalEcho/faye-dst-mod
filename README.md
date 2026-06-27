# Faye — The Elven Shadow Warrior
*A Don't Starve Together Character Mod*

> "The shadows call me home."

![DST Character Mod](https://img.shields.io/badge/DST-Character%20Mod-purple)
![Status](https://img.shields.io/badge/status-v1.0%20placeholder-yellow)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## About

Faye is an elven warrior who is **naturally bonded to darkness**. She does not fear the night — she thrives in it. Her night vision is completely innate; she has always been able to see in the dark, and no item or upgrade is needed to grant it. The darkness monster Charlie cannot harm her. She is at her most powerful at night, in caves, or anywhere the sun cannot reach.

In exchange, **daylight is Faye's primary threat**. Prolonged exposure to the sun drains her sanity, accelerates her hunger, and diminishes her combat effectiveness. The Twilight Blindfold — her starting head armor — helps her tolerate sunlight, but it does not give her night vision. That was never the blindfold's purpose.

---

## Stats

| Stat   | Value | Notes                                    |
|--------|-------|------------------------------------------|
| Health | 150   | Lower than Wilson (200) — she's fast, not tanky |
| Hunger | 100   | Lower than Wilson (150) — slight build   |
| Sanity | 200   | Highest possible default value           |

---

## Strengths

- 🌑 **Permanent night vision** — a faint purple personal light, always active
- 🛡️ **Complete Charlie / darkness immunity** — the darkness cannot harm her
- ⚔️ **+35% damage** at night or in caves
- 🧠 **Gains sanity** in darkness (+1 every 4 seconds)
- 🧱 **25% innate damage reduction** on all incoming hits
- 🩸 **10% life steal** on every attack

---

## Weaknesses

- ☀️ **−25% damage** during the day
- 🧠 **Loses sanity** in daylight (−1 every 4 seconds; reduced to −0.3 with the Twilight Blindfold equipped)
- 🍖 **Hunger drains 50% faster** during the day
- 😴 **Can only sleep during daytime** — tents and sleeping bags don't work for her at night
- ☀️ **Daylight is her primary threat** — not monsters, not winter, not hunger

---

## Starting Items

### Shadowblade
Faye's starting weapon. A blade condensed from shadow — it sharpens in darkness and dulls in the sun.

| Phase       | Damage |
|-------------|--------|
| Night / Cave | 58    |
| Dusk        | 45     |
| Day         | 30     |

- **Durability:** 200 uses
- Damage updates dynamically as the world phase changes while equipped
- Stacks with Faye's own day/night damage multiplier
- *Placeholder art: Night Sword*

### Twilight Blindfold
Faye's starting head armor. A silken blindfold woven to dim the cruelty of sunlight.

- **Slot:** Head
- **Armor:** 20% damage absorption, 100 durability
- **Special (Faye only):** Reduces daytime sanity drain from −1/tick to −0.3/tick
- Does **not** grant night vision — that is innate to Faye
- *Placeholder art: Mole Hat*

---

## Character Quotes

| Moment            | Quote |
|-------------------|-------|
| Select screen     | *"The shadows call me home."* |
| Night begins      | *"Shadows, lend me your strength."* |
| Day begins        | *"The light is a thief."* |
| Low sanity        | *"The light is winning..."* |
| Full moon         | *"The Lunar God shines on us."* |
| Entering caves    | *"Sanctuary at last."* |
| Reviving          | *"The shadows were not finished with me."* |
| Killing a boss    | *"A worthy foe consumed by the abyss."* |
| Sensing Charlie   | *"Touch 'em, touch 'em, grandma."* |
| Ghost / death     | *"The eternal abyss calls me home."* |

---

## Installation

```
1. Download or clone this repository.

2. Copy the entire mod folder into your DST mods directory:
      Windows: C:\Users\<you>\Documents\Klei\DoNotStarveTogether\mods\
      Mac:     ~/Documents/Klei/DoNotStarveTogether/mods/
      Linux:   ~/.klei/DoNotStarveTogether/mods/

3. Launch Don't Starve Together.

4. Click Mods → locate "Faye - The Elven Shadow Warrior" → Enable.

5. Start a new game and select Faye on the character screen.
```

> **Multiplayer:** `all_clients_require_mod = true` is set in `modinfo.lua`.
> All players in a server must have the mod enabled.

---

## File Structure

```
faye-dst-mod/                            ← repo root = mod folder (Steam Workshop requirement)
├── modinfo.lua                          ← Mod identity, DST API version, compatibility flags
├── modmain.lua                          ← Entry point: asset list, prefab registration, all strings
├── LICENSE                              ← MIT License
├── README.md                            ← This file
├── .gitignore                           ← Excludes art source files, compiler output, OS clutter
└── scripts/
    ├── prefabs/
    │   ├── faye.lua                     ← Main character prefab: all stats, perks, and event hooks
    │   ├── faye_shadowblade.lua         ← Starting weapon with dynamic day/night damage scaling
    │   └── faye_twilight_blindfold.lua  ← Starting head armor with Faye-specific sanity effect
    ├── speech_faye.lua                  ← All character dialogue, examine strings, and announce quotes
    └── strings/
        └── faye_strings.lua             ← Item string overrides + step-by-step art-replacement notes
```

---

## ⚠️ Placeholder Art Notice

> **v1.0 uses base-game art as a placeholder.** No custom textures, atlases, or animation
> files are included yet — they don't exist and are intentionally absent.
>
> - Faye appears visually as **Wendy**
> - The Shadowblade looks like the **Night Sword**
> - The Twilight Blindfold looks like the **Mole Hat**
>
> All mechanics are **fully functional**. This build exists to verify server stability
> and gameplay balance before committing to custom art production.
>
> Custom art is targeted for **v2.0**. The file `scripts/strings/faye_strings.lua`
> contains a complete checklist of every `SetBuild`, `OverrideSymbol`, and
> `atlasname` line that needs to change when art is ready.

---

## Roadmap

| Version | Status        | Contents                                      |
|---------|---------------|-----------------------------------------------|
| v1.0    | ✅ Complete   | All mechanics, server-safe, placeholder art   |
| v2.0    | 🔲 Planned    | Custom character spritesheet and portraits    |
| v2.1    | 🔲 Planned    | Custom Shadowblade and Blindfold art          |
| v3.0    | 🔲 Planned    | Crafting recipes for Shadowblade and Blindfold|
| v3.1    | 🔲 Planned    | Steam Workshop upload                         |

---

## Technical Notes

For contributors and future modders working from this codebase:

- **`Assets = {}`** is intentionally empty in `modmain.lua`. Declaring custom assets that don't physically exist in the mod folder is the most common cause of "Dedicated server failed to start."
- **Charlie immunity** works by listening for the `"attacked"` event, detecting `attacker.prefab == "nightmonster"`, and immediately healing 100% of the damage back. No patching of Charlie's targeting logic is required.
- **Night vision** is implemented as a `lightemitter` component (range 3, purple tint). Giving the player a persistent light source prevents Charlie's targeting logic from activating, which is simpler and more robust than hooking into the server's darkness system.
- **`sanity.neg_aura_mult = 0`** disables DST's default sanity drain from standing in darkness. Faye's sanity is managed entirely by a periodic task running every 4 seconds instead.
- **`combat.damagemultiplier`** is adjusted on `ms_setphase` world events, applying her day/night damage swing to all weapons including the Shadowblade (which also scales independently — they stack by design).
- **Sleep restriction** wraps `sleeper.GoToSleep` to return `false` and speak a line when `IsDark()` is true.
- **Starting items** use `DoTaskInTime(0, ...)` combined with an `OnSave/OnLoad` flag to prevent re-granting items on every respawn.

---

## Contributing

Pull requests are welcome. Please open an issue before making large mechanical changes so intent can be discussed first.

- All Lua must be compatible with **DST's embedded Lua 5.1**
- Do not add `Assets = {}` entries for files that aren't committed to the repo
- Do not uncomment the `icon_atlas` / `icon` lines in `modinfo.lua` until `modicon.tex` and `modicon.xml` physically exist

---

## License

MIT — see [LICENSE](LICENSE).
