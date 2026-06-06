# LF2 DAT Reference

This document is a converter-oriented reference for original Little Fighter 2
`.dat` files. It collects the LF Empire data-changing notes into a structure
that can be used to convert original LF2 data into the current `presets/lf2`
format and to identify missing LF2 behavior in this preset.

The source articles were fetched on 2026-05-25. For every
`/lf2-empire/data-changing` page, only the article content under
`id="maincontent"` should be treated as source material. The sound list is plain
text.

## Source Inventory

Keep these links exact. Some pages rely on the query string to expose the full
article.

| Topic | Source |
| --- | --- |
| Type 0 - Characters | https://lf-empire.de/lf2-empire/data-changing/types/167-type-0-characters |
| Type 1 - Light Weapons | https://lf-empire.de/lf2-empire/data-changing/types/168-type-1-light-weapons |
| Type 2 - Heavy Weapons | https://lf-empire.de/lf2-empire/data-changing/types/169-type-2-heavy-weapons |
| Type 3 - Attacks | https://lf-empire.de/lf2-empire/data-changing/types/170-type-3-attacks |
| Type 4 - Throw Weapons | https://lf-empire.de/lf2-empire/data-changing/types/171-type-4-throw-weapons |
| Type 5 - Other | https://lf-empire.de/lf2-empire/data-changing/types/172-type-5-other |
| Type 6 - Drinks | https://lf-empire.de/lf2-empire/data-changing/types/173-type-6-drinks |
| bpoint | https://lf-empire.de/lf2-empire/data-changing/frame-elements/176-bpoint-blood-point |
| cpoint | https://lf-empire.de/lf2-empire/data-changing/frame-elements/177-cpoint-catch-point?showall=1 |
| opoint | https://lf-empire.de/lf2-empire/data-changing/frame-elements/178-opoint-object-point |
| wpoint | https://lf-empire.de/lf2-empire/data-changing/frame-elements/179-wpoint-weapon-point |
| itr | https://lf-empire.de/lf2-empire/data-changing/frame-elements/174-itr-interaction?showall=1 |
| States | https://lf-empire.de/lf2-empire/data-changing/reference-pages/182-states?showall=1 |
| Effects | https://lf-empire.de/lf2-empire/data-changing/reference-pages/181-effects |
| Sound list | https://lf-empire.de/downloads/readmes/Soundlist_eng.txt |

## Object Types

LF2 object type controls which header fields, frame ranges, state machines, and
hardcoded interactions are active. The current preset stores object data in
`presets/lf2/data/*.dat`, state logic in `presets/lf2/data/states`, kind logic
in `presets/lf2/data/kinds`, and common damage settings in
`presets/lf2/data/sys/dtypes.dat`.

| Type | Meaning | Important source fields | Converter notes |
| --- | --- | --- | --- |
| 0 | Characters | `name`, `head`, `small`, `file`, movement speeds, jump/dash/rowing values, frame fields, frame elements | Source frame ids above 399 are ignored by LF2 for characters. The preset already uses character-style frames and states, but weapon holding, cpoint, full armor, and many special states are incomplete. |
| 1 | Light weapons | sprite rows/cols, `weapon_hit_sound`, `weapon_drop_sound`, `weapon_broken_sound`, `weapon_strength_list`, frames 0/20-35/40/60/70 | `weapon_strength_list` entries are selected by character `wpoint.attacking` and feed itr kind 5. Current preset has no complete light weapon lifecycle. |
| 2 | Heavy weapons | same bitmap sound fields as weapons, frames 0/10/20/21 | Heavy weapons use state 2000/2001/2004 and can be picked up through itr kind 2. Current preset has no complete heavy weapon lifecycle. |
| 3 | Attacks | projectile bitmap data, `weapon_broken_sound`, frame `hit_a`, `hit_d`, `hit_j`, `hit_Fa`, ball states 3000-3006 | Type 3 ignores gravity and uses `hit_j` for Z movement. It needs projectile spawning, timers, rebound/hit frame routing, and effect handling. |
| 4 | Throw weapons | weapon strength list, projectile-like movement fields, frames 0/20-35/40/60/70 | Source article repeats several type 3 terms, but the object behaves as a throwable weapon. Needs both weapon and projectile conversion paths. |
| 5 | Other | bitmap fields and generic frames | Used for objects such as `criminal.dat`, `etc.dat`, and `broken_weapon.dat`. Several ids have hardcoded behavior. |
| 6 | Drinks | weapon-like bitmap sound fields, frames 0/20-35/40/60/70 | Milk and beer combine weapon/drop behavior with state 17 drinking recovery. Current preset has a stub state 17. |

### Shared Bitmap/Header Fields

| Field | Meaning | Converter target |
| --- | --- | --- |
| `name` | Character/object display name. LF2 uses underscores instead of spaces. | Preserve as `name`. |
| `head` | Character selection portrait, usually 120x120. | Preserve path if asset exists. |
| `small` | Status-bar portrait, 40x45. | Preserve path if asset exists. |
| `file(#-#)` | Sprite sheet path and sheet metadata. The suffix numbers are orientation only. LF2 enumerates cells row by row from zero using `row * col`. | Convert to one or more `<sprite>` declarations with `w`, `h`, and source path. |
| `w`, `h` | Single sprite cell size. Character cells are commonly 79x79 with spacing. | Preserve per sprite source. |
| `row`, `col` | Source sheet layout. | Use to expand LF2 `pic` numbers. |
| `weapon_hit_sound` | Sound when weapon is hit. | Map to sound component data and weapon damage behavior. |
| `weapon_drop_sound` | Sound when weapon lands/drops. | Map to weapon lifecycle behavior. |
| `weapon_broken_sound` | Sound when weapon breaks. | Map to broken weapon behavior and sound data. |
| movement speeds | Character movement constants such as `walking_speed`, `running_speed`, `jump_height`, `dash_distance`, `rowing_distance`. | Preserve as object attributes consumed by state scripts. |

### Shared Frame Fields

| Field | Meaning | Converter target |
| --- | --- | --- |
| `pic` | Sprite cell index, counted row by row from the bitmap header. | Preserve as `pic`; converter should resolve the matching sprite sheet. |
| `state` | Hardcoded LF2 frame behavior. | Map to `<state> N </state>` and ensure a file exists in `presets/lf2/data/states` or record as missing. |
| `wait` | Frame duration in LF2 time units. Effective duration is `wait + 1`. `wait: 0` skips visible first-frame behavior in sequences. | Preserve existing preset semantics, which also uses `data.wait + 1`. |
| `next` | Automatic transition after wait. `999` means frame 0 for many normal transitions; `1000` deletes object; negative values change facing; character `1100-1299` hides Rudolf for 0-199 TU. | Preserve raw value during conversion, then normalize only where the engine explicitly implements the LF2 special value. |
| `dvx`, `dvy`, `dvz` | Initial or controlled movement. Type 0 is affected by gravity/friction; type 3 movement is constant and uses `hit_j` for Z movement. | Preserve raw values and let state/type behavior interpret them. |
| `centerx`, `centery` | Point of the object relative to shadow/position; frame elements are positioned relative to it. | Preserve. Existing collision code uses `centerx` and `centery`. |
| `hit_a`, `hit_d`, `hit_j` | Input transitions for characters. In type 3, `hit_a` is a projectile lifetime code, `hit_d` is target frame after timer, and `hit_j` controls Z drift. | Interpret by object type and state. Do not globally treat these as character input fields. |
| `hit_Fa`, `hit_Fj`, `hit_Ua`, `hit_Uj`, `hit_Da`, `hit_Dj`, `hit_ja` | Special move inputs, usually started with defend plus direction plus attack/jump. | Convert as frame fields and implement through compatibility/input state logic. |
| `mp` | HP/MP cost or gain. Positive `yyxxx` spends HP/MP, negative gains HP/MP; last three digits are MP and leading digits are HP in tens. | Missing as a general preset behavior. |
| `sound` | Frame sound path. | Convert to frame sound entries and/or sound component data. |

## Standard Frame Ranges

These ranges matter because many LF2 states and hardcoded transitions jump to
specific frame ids.

| Object | Range | Meaning |
| --- | --- | --- |
| Character | 000-003 | standing |
| Character | 005-008 | walking |
| Character | 009-011 | running |
| Character | 012-015 | heavy object walk |
| Character | 016-018 | heavy object run |
| Character | 019 | heavy stop run |
| Character | 020-028 | normal weapon attack |
| Character | 030-033 | jump weapon attack |
| Character | 035-037 | run weapon attack |
| Character | 040-043 | dash weapon attack |
| Character | 045-047 | light weapon throw |
| Character | 050-051 | heavy weapon throw |
| Character | 052-054 | sky light weapon throw |
| Character | 055-058 | weapon drink |
| Character | 060-068 | punch |
| Character | 070-073 | super punch |
| Character | 080-081 | jump attack |
| Character | 085-087 | run attack |
| Character | 090-091 | dash attack |
| Character | 095 | dash defend |
| Character | 100-109 | rowing/flipping |
| Character | 110-114 | defend and broken defend |
| Character | 115-117 | picking light/heavy |
| Character | 120-144 | catching and caught |
| Character | 180-191 | falling forward/backward |
| Character | 200-206 | ice and fire |
| Character | 207 | tired, no source purpose |
| Character | 210-219 | jump, dash, crouch, stop running |
| Character | 220-229 | injured |
| Light weapon | 0 | in the sky |
| Light weapon | 20-35 | on hand, selected by character `weaponact` |
| Light weapon | 40 | throwing |
| Light weapon | 60 | on ground |
| Light weapon | 70 | just on ground |
| Heavy weapon | 0 | in the sky, or thrown |
| Heavy weapon | 10 | on hand |
| Heavy weapon | 20 | on ground |
| Heavy weapon | 21 | just on ground |
| Attack | 0 | flying |
| Attack | 10 | hitting character/heavy weapon |
| Attack | 20 | hit light weapon or another attack |
| Attack | 30 | rebound |
| Attack | 40 | tail, used by `hit_Fa: 7` |
| Attack | 50 | flying 2, used by `hit_Fa: 14` |
| Attack | 60 | hitting ground, used by `hit_Fa: 7` |

## Frame Elements

### body

`body` is the hittable collision shape. Source pages focus on `itr`, but this
engine also documents bodies in `docs/guide/08-itr-body-kinds.md`.

| Field | Meaning | Converter target |
| --- | --- | --- |
| `kind` | Body kind, usually 0. | Preserve for collision filtering. |
| `x`, `y`, `w`, `h` | Rectangle relative to the current frame. | Convert to `<body>` blocks. |
| `z`, `zwidth` or local depth fields | Z-axis coverage in LF2-like data. | Normalize to the engine depth field used by collision data. Existing examples use `z` and `l`; source itr pages call this `zwidth`. |

### itr

`itr` is the active interaction/hitbox. It collides with `body` and dispatches
by `kind`.

| Field | Meaning | Converter target |
| --- | --- | --- |
| `kind` | Interaction kind. | Maps to `presets/lf2/data/kinds/<kind>.lua`. |
| `x`, `y`, `w`, `h` | Hit area. | Preserve as `<itr>` fields. |
| `dvx`, `dvy`, `dvz` | Velocity applied to target or kind-specific transition value. | Preserve raw. Kind decides semantics. |
| `arest`, `vrest` | Re-hit delay. `arest` is for a single target, `vrest` for multiple targets. | Missing as a general collision cooldown behavior. |
| `fall` | Accumulated fall/stun behavior. Defaults to 20. 20 reaches injured1, 40 reaches injured2/back and can make airborne targets fall, 60 reaches dance of pain and can hit falling targets. | Partially approximated by current kind 0/attribute damage; exact counters are missing. |
| `bdefend` | Defense-break points. Values above 30 break normal defense; 100 ignores defense and destroys weapons. | Partially approximated by current kind 0 defend handling; exact counters and armor are missing. |
| `injury` | Damage amount, or kind-specific healing behavior. | Current kind 0 passes itr data to attributes. Other semantics are incomplete. |
| `zwidth` | Extra Z-axis reach. Default is 12 pixels each side. | Needs explicit mapping to engine collision depth. |
| `effect` | Effect id for kind 0. | Missing as a complete effect table. |

### bpoint

`bpoint` is character-only. When health is below 25%, LF2 shows a red blood
stain at `x`, `y`.

| Field | Meaning | Converter target |
| --- | --- | --- |
| `x`, `y` | Blood mark position. | Missing visual effect behavior. Preserve raw data for later. |

### cpoint

`cpoint` controls grabbing. Source notes recommend state 9 for the catching
character and state 10 for the caught character.

| Kind | Meaning | Fields |
| --- | --- | --- |
| 1 | catching character | `x`, `y`, `injury`, `vaction`, `aaction`, `jaction`, `taction`, `throwvx`, `throwvy`, `throwvz`, `hurtable`, `throwinjury`, `decrease`, `dircontrol`, `cover` |
| 2 | caught character | `x`, `y`, `fronthurtact`, `backhurtact` |

Converter notes:

- Holding coordinates from catcher and caught frames combine to place the held character.
- Positive `injury` causes hit lag and shaking; negative values avoid hit lag and reduce effective catcher wait by 1.
- `throwvx` is the key drop/throw trigger; `throwvy`, `throwvz`, and `throwinjury` only work with it.
- `decrease` controls forced release and jump/fall destination behavior.
- `cover` encodes both facing alignment and render side.
- Current preset has `states/9.lua` as a cpoint TODO, so cpoint is a major implementation gap.

### opoint

`opoint` spawns objects.

| Field | Meaning | Converter target |
| --- | --- | --- |
| `kind` | 1 spawns normal objects such as balls; 2 spawns a light weapon directly into hand, usually after dropping the old weapon with `wpoint kind: 3`. | Missing object-spawn implementation. |
| `x`, `y` | Spawn position for the spawned object's center point. | Preserve raw. |
| `action` | Starting frame of spawned object. | Preserve as spawn frame. |
| `dvx`, `dvy` | Initial movement. | Preserve. |
| `oid` | Object id from LF2 `data.txt`. Value 0 does not work in LF2. | Must map through converter object-id table. |
| `facing` | Spawn direction and count. 0 front, 1 back, 10 right-side display, 20/21 two objects, 30/31 three objects, and so on. | Missing. Needs exact facing/count decoding. |

### wpoint

`wpoint` controls held weapons and throws.

| Field | Meaning | Converter target |
| --- | --- | --- |
| `kind` | 1 character holds or throws with `dvx/dvy/dvz`; 2 weapon is being held by character; 3 drops weapon without throw velocity. | Missing full weapon link/drop behavior. |
| `x`, `y` | Holding coordinates. | Preserve raw and combine with weapon frame. |
| `weaponact` | Weapon frame shown while held. | Preserve and drive linked weapon frame. |
| `attacking` | Selects weapon strength list entry. 0 means no damage; 1-4 map to normal/jump/run/dash weapon attack by convention. | Missing complete weapon strength handling; itr kind 5 is not implemented separately. |
| `cover` | Render weapon behind character when 1. | Missing complete linked rendering behavior. |
| `dvx`, `dvy`, `dvz` | Throw velocity. Negative `dvy` throws upward and gravity returns the weapon to ground. | Missing complete weapon throw lifecycle. |

## Itr Kinds

| Kind | Source behavior | Current preset status |
| --- | --- | --- |
| 0 | Normal hit. Uses `dvx`, `dvy`, `arest`, `vrest`, `fall`, `bdefend`, `injury`, `zwidth`, and optional `effect`. | Partial: `kinds/0.lua` applies damage, injured/falling frames, sounds, and simple block response. Exact fall/bdefend counters, effects, zwidth defaults, armor, and rest timers are missing. |
| 1 | Catch dance-of-pain target in state 16, using `catchingact` and `caughtact`. | Stub: `kinds/1.lua` has TODO. |
| 2 | Pick weapon in first punch frame. Uses `vrest: 1`; pickup area should be near character center. | Stub: `kinds/2.lua` has TODO. |
| 3 | Catch any target with a body, used by Louis whirlwind throw. | Missing. |
| 4 | Falling hit, active only when thrown by another character. Reuses normal hit tags. | Stub: `kinds/4.lua` has TODO. |
| 5 | Weapon strength. Values come from weapon strength list selected by `wpoint.attacking`; defaults include `dvx: 8`, `fall: 20`, `bdefend: 16`, `injury: 789`. | Missing as its own file. |
| 6 | Super punch trigger. Broken-weapon and late injured frames make the attacker use super punch instead of normal punch. | Partial: file exists, verify behavior before relying on it. |
| 7 | Pick light weapon while rowing without entering picking-light frames. | Stub: `kinds/7.lua` has TODO. |
| 8 | Heal ball. Sticks to type 0 body, can affect both teams, `dvx` is target frame, `injury` is heal amount. | Missing. |
| 9 | Reflective shield. Reflects or destroys projectiles and can reduce a character attacker to zero health. | Missing. |
| 10 | Sonata of Death. Raises objects to the top of the itr area and repeatedly damages enemies. | Missing. |
| 11 | Sonata helper, suspends characters but overlaps with kind 10. | Missing. |
| 14 | Solid 3D object. Blocks movement and does not damage. | Stub: `kinds/14.lua` has TODO. |
| 15 | Whirlwind wind. Pulls objects in, with normal hit-style tags. | Missing. |
| 16 | Whirlwind freeze. Turns characters into ice and lifts only weapons. | Missing. |

## States

State scripts are loaded from `presets/lf2/data/states`. The current preset has
files for `0-18`, plus `compatibility.lua` and `Default.lua`. State 19 and all
high-numbered LF2 states are currently missing.

| State | Source behavior | Current preset status |
| --- | --- | --- |
| 0 | Standing. Handles walking, running, punch, defend, jump, weapon attack choice, airborne jump frame 212, hidden standing/walking counters. | Partial: file exists; weapon branches and exact hidden counters are incomplete. |
| 1 | Walking. Uses `walking_speed` and `walking_speedz`; mostly shares state 0 input behavior and supports double-tap run. | Partial: file exists; weapon branches and exact counter behavior are incomplete. |
| 2 | Running. Uses `running_speed` and `running_speedz`; attack to run attack or weapon attack, jump to dash, defend to rowing, opposite direction to stop-running. | Partial: file exists; weapon attack/throw behavior incomplete. |
| 3 | Attack. Like normal action but provokes defense AI when it has an itr. | File exists; verify defense/AI semantics. |
| 4 | Jumping. A can trigger jump weapon attack or jump attack; left/right can turn in air; velocity changes can force falling. | Partial: file exists; jump weapon attack TODO. |
| 5 | Dash. Handles dash direction frames and dash attack/weapon attack. | Partial: file exists; dash weapon attack TODO. |
| 6 | Rowing/flipping. No state machine, but itr kind 7 can pick weapons; landing can go to frame 215. | Partial: file exists; has comments about air/ground details. |
| 7 | Defend. Blocks while fall/bdefend permit it; frame 110 can turn with opposite direction; broken defense routes to frame 112. | Partial: file exists; exact bdefend/fall counters and armor need verification. |
| 8 | Broken defend. No state machine; super punch exposure comes from itr kind 6. | File exists. |
| 9 | Catching. Cpoint-driven; source recommends state 9 with `cpoint kind: 1`. | Stub: file exists with cpoint TODO. |
| 10 | Caught. Used with `cpoint kind: 2` and `next: 0`; drops weapons and prevents control. | Partial/stub: file exists with weapon drop TODO. |
| 11 | Injured. No state machine; armor changes and heavy weapon drop matter. | Partial: file exists with heavy weapon drop TODO. |
| 12 | Falling. Routes frames 180-191 by y velocity/facing, bounces on ground, supports J flip from frames 183/188, drops weapon, immune to attacks with `fall < 41`. | Partial: file exists; weapon drop and low-fall immunity TODO. |
| 13 | Ice. Can be hit by teammates, breaks on impact, creates shards. | Stub: file exists with TODO. |
| 14 | Lying. Alive characters recover; dead characters loop with wait 1; opoints repeat every TU while dead. | File exists; verify death-loop and warning behavior. |
| 15 | Other. No special source function. | File exists. |
| 16 | Dance of pain/injured 2. Can be grabbed by itr kind 1 and can trigger super punch via kind 6. | Partial: file exists with catch TODO. |
| 17 | Drinking. Milk/beer recovery only applies while held in drinking frames. | Stub: file exists with TODO. |
| 18 | Burning. Creates burning smoke, can hit teammates, has fire frame routing and fire immunity rules. | Stub: file exists with TODO. |
| 19 | Firerun. Z movement based on `running_speedz`, fire smoke, no teammate hits, fire immunity rules. | Missing. |
| 100 | Hit ground. On landing, routes to frame 94. | Missing. |
| 301 | Move along Z axis. Like state 3 with fixed Z-axis movement. | Missing. |
| 400/401 | Teleport to nearest enemy or farthest teammate. | Missing. |
| 500/501 | Transform support tied to cpoint/Rudolf transform behavior. | Missing. |
| 1700 | Heal up to dark red health bar, with white HP flash and timed recovery. | Missing. |
| 8000+id | Transform into object id. Uses `pic + 140` sprite offset and changes id/frame. | Missing. |
| 1000 | Light weapon in sky. Damage depends on itr; original light weapons generally have no itr here. | Missing. |
| 1001 | Light weapon on hand, controlled by holder wpoint. | Missing. |
| 1002 | Light weapon being thrown. | Missing. |
| 1003 | Light weapon just on ground. | Missing. |
| 1004 | Light weapon on ground; can be picked up by itr kind 2 and routes character to picking-light. | Missing. |
| 2000 | Heavy weapon in sky; original heavy weapons have itr here. | Missing. |
| 2001 | Heavy weapon on hand, controlled by holder wpoint. | Missing. |
| 2004 | Heavy weapon on ground; picked up through itr kind 2 and routes character to picking-heavy. | Missing. |
| 3000 | Ball flying. Standard projectile state, can hit/rebound with other attacks. | Missing. |
| 3001 | Ball flying/hitting; does not route to hitting frame when it hits a character. | Missing. |
| 3002 | Ball hit frame behavior. | Missing. |
| 3003 | Ball rebound frame behavior. | Missing. |
| 3004 | Ball disappear frame behavior. | Missing. |
| 3005 | Ball no shadow; destroys weaker ball attacks. | Missing. |
| 3006 | Piercing ball; stronger than 3000, not reboundable, destroyed by 3005 or another 3006. | Missing. |
| 9995 | Louis transforms to LouisEX id 50 and frame 0. | Missing. |
| 9996 | Creates Louis armor objects around LouisEX during transform. | Missing. |
| 9997 | Message object, no shadow, visible from anywhere; opoint frames need `dvy: 550` to avoid falling. | Missing. |
| 9998 | Delete object, safer than `next: 1000` around cpoint/weapons. | Missing. |
| 9999 | Broken weapon, same as state 15. | Missing. |

## Effects

Effects are used by `itr kind: 0` and are currently not represented as a
complete preset table. Source notes say unlisted effects behave like effect 5.

| Effect | Sound | Behavior |
| --- | --- | --- |
| 0 | `001.wav` or `006.wav` | Normal hit; weapons fly away. Can be omitted. |
| 1 | `032.wav` or `033.wav` | Blood hit; weapons fly away. |
| 2 | `070.wav` or `071.wav` | Fire hit; can hit burning characters; weapons fly away. |
| 3 | `065.wav` or `066.wav` | Ice hit; can hit frozen characters; weapons fly away. |
| 4 | `weapon_hit_sound` | Reflects flying attacks with state 3000; weapons fly away; no direct character influence. |
| 5 | none | Reflects flying attacks with state 3000; weapons fly away; characters are hit without sound. |
| 20 | `070.wav` or `071.wav` | Fire; burning characters are immune to effects 20/21; weapons do not fly away. |
| 21 | `070.wav` or `071.wav` | Fire; burning characters are immune to effects 20/21; weapons fly away; avoids teammate hits with state 18. |
| 22 | `070.wav` or `071.wav` | Fire; can hit burning characters; weapons fly away; positive `dvx` moves toward middle; avoids teammate hits with state 18. |
| 23 | `070.wav` or `071.wav` | Normal; character remains hurtable; weapons fly away; positive `dvx` moves toward middle. |
| 30 | `065.wav` | Ice; frozen characters are immune to effect 30; weapons fly away. |

## Sound List

These names come from `Soundlist_eng.txt`. Current preset assets include only a
subset under `presets/lf2/data/sounds`, so conversion must either copy missing
assets or preserve unresolved sound references.

| File | Meaning |
| --- | --- |
| `m_cancel.wav` | Menu Sound - Abort |
| `m_end.wav` | End 1-1 / 2-2 / VS - Battle |
| `m_join.wav` | Menu Sound - Select |
| `m_ok.wav` | Menu Sound - Enter |
| `m_pass.wav` | Stage-End |
| `001.wav` | Punch |
| `002.wav` | Block Punch |
| `003.wav` | Run Tick |
| `004.wav` | Run Tok |
| `005.wav` | Whirlwind Casting Voom |
| `006.wav` | Super Hit Bish |
| `007.wav` | Woob Swing Sound |
| `008.wav` | Wow Swing Sound |
| `009.wav` | Pick up/stop running |
| `010.wav` | Boulder hit |
| `011.wav` | Bat hit |
| `012.wav` | Run Ted |
| `013.wav` | Free Hostage |
| `014.wav` | Grab Attack |
| `015.wav` | Grab |
| `016.wav` | Drop |
| `017.wav` | Jump |
| `018.wav` | John Energy Ball Charge |
| `019.wav` | Shoot John Energy Ball |
| `020.wav` | Explode, energy ball hit and palm |
| `021.wav` | Boulder Break |
| `022.wav` | Pull Arrow |
| `023.wav` | Ice Sword hit |
| `024.wav` | Arrow Shot |
| `025.wav` | Arrow ground hit |
| `026.wav` | Shurinken ting |
| `027.wav` | Weapon ting |
| `028.wav` | Rudolf Blades Shing |
| `029.wav` | Rudolf Keep Blades |
| `030.wav` | Rudolf Shadow/Mirror Image |
| `031.wav` | Louis Thunderpunch/Julian Soulpunch |
| `032.wav` | Bloody Attack |
| `033.wav` | Bloody Heavy Attack |
| `034.wav` | Weapon ting |
| `035.wav` | Crate hit |
| `036.wav` | Crate break |
| `037.wav` | Crate hit |
| `038.wav` | Baseball |
| `039.wav` | Baseball hit by bat |
| `040.wav` | Potion break |
| `041.wav` | Potion hit |
| `042.wav` | Drink |
| `043.wav` | Deep Energy Blast |
| `044.wav` | Jack Flipkick hor! |
| `045.wav` | Deep Dashing Strafe HAR |
| `046.wav` | Dennis Energy Ball |
| `047.wav` | Woody Energy Blast |
| `048.wav` | Davis Energy Ball |
| `049.wav` | Jan Angels/Heal |
| `050.wav` | Casting Heal |
| `051.wav` | Energy Shield Sound |
| `052.wav` | Casting Energy Shield |
| `053.wav` | Energy Shield Gone |
| `054.wav` | Knight Swing Attack 1 |
| `055.wav` | Woody Tiger Dash |
| `056.wav` | Henry Flute 1 |
| `057.wav` | Henry Flute 2 |
| `058.wav` | Henry Flute 3 (long) |
| `059.wav` | Critical Arrow |
| `060.wav` | Multi-Arrow |
| `061.wav` | Rudolf Invisible |
| `062.wav` | Rudolf Clone |
| `063.wav` | Rudolf Transform |
| `064.wav` | Ice Ball |
| `065.wav` | Iced |
| `066.wav` | No longer Iced |
| `067.wav` | Fire ball |
| `068.wav` | Burnt |
| `069.wav` | Punch miss |
| `070.wav` | Inferno |
| `071.wav` | Inferno |
| `072.wav` | Icicle |
| `073.wav` | Whirlwind |
| `074.wav` | Summon Ice Sword |
| `075.wav` | Summon Energy Disk |
| `076.wav` | Energy Disk Fly |
| `077.wav` | Dennis Chasing Ball |
| `078.wav` | Teleport |
| `079.wav` | Scyte Ting |
| `080.wav` | Command COME |
| `081.wav` | Command STAY |
| `082.wav` | Command MOVE |
| `083.wav` | Armor small hit |
| `084.wav` | Armor just hit |
| `085.wav` | Armor class |
| `086.wav` | Bat Lazer |
| `087.wav` | Bat's bats |
| `088.wav` | Bat's bats hit |
| `089.wav` | Julian Big Bang and Soul Bomb Explode |
| `090.wav` | Julian Skull Blast Hit |
| `091.wav` | Summon Skull Blast Projectile |
| `092.wav` | Firzen Cannon shooting |
| `093.wav` | Stage Command I JOIN YOU |
| `094.wav` | Bat break |
| `095.wav` | Davis Uppercut YAH!!! |
| `096.wav` | Henry Dragon Palm HUNK!!! |
| `097.wav` | Louis Palm HEI!!! |
| `098.wav` | Monk Palm HULK! |
| `099.wav` | Woody Tiger Dash HOI!!! |
| `100.wav` | Firzen charge firzen cannon HAI!!! |
| `101.wav` | Henry Flute 4 |
| `102.wav` | Henry Flute 5 (long) |

## Current Preset Gap Map

This is the minimum implementation backlog implied by the reference.

| Area | Missing or partial work |
| --- | --- |
| Weapon lifecycle | Light/heavy/throw/drink object state machines, on-hand linking, pickup/drop/throw, weapon strength list, weapon sounds, break behavior. |
| Catches | Full `cpoint` placement, held state, throw/release, cover/facing, hurt actions, `itr kind: 1`, and `itr kind: 3`. |
| Projectiles | Type 3 state 3000-3006 behavior, `hit_a` projectile timers, `hit_d` timer targets, `hit_j` Z movement, rebound/hit/hitting frames, and `hit_Fa` special movement/spawn logic. |
| Effects | Complete effect table, fire/ice/blood/silent hit behavior, reflect behavior, teammate/self-hit exceptions, projectile interactions. |
| Collision counters | `arest`, `vrest`, fall counters, bdefend counters, armor thresholds, zwidth defaults, low-fall immunity for falling targets. |
| Object spawning | `opoint` kind 1/2, object id mapping from LF2 `data.txt`, facing/count decoding, initial velocity, display/message objects. |
| Special states | 19, 100, 301, 400/401, 500/501, 1700, 8000+id, 1000-1004, 2000-2004, 3000-3006, 9995-9999. |
| Visual effects | bpoint blood marks, burning smoke, ice shards, message visibility, shadow/no-shadow states, linked weapon cover rendering. |
| Sounds | Full LF2 sound asset list and sound selection by effect, weapon headers, frame `sound`, and state/kind events. |
