# LF2 State Assembly Crosscheck

This note records the current comparison between the original `lf2.exe`
state handling and the `presets/lf2/data/states` implementation. It is meant
as a working reference for future LF2 compatibility work, not as a complete
decompilation.

Source material used:

- `C:\Games\LittleFighter2\LF2\lf2.exe`
- disassembly cached under `%TEMP%\l2df-lf2-re`
- `docs/guide/12-lf-states.txt`
- `docs/guide/11-lf2-dat-reference.md`

The main object state field appears in the disassembly as comparisons against
`[object + 0x7ac]`.

## Direct State References

Direct state references found in the assembly for states `0..19`:

| State | Evidence / observed role |
| --- | --- |
| `0` | Shares the idle/walk input path with state `1`. The relevant block starts around `0x4133c6` and compares state with `0` and `1`. |
| `1` | Shares the idle/walk input path with state `0`. Handles walking frames, movement, punch, jump, defend, weapon actions, and run startup. |
| `2` | Direct references around `0x406541` and `0x413b22`. The `0x413b22` block handles running input, run attack, jump, defend/rowing, and opposite-direction stopping. |
| `3` | No clear direct state-machine branch was found. Docs describe this as an attack state without a dedicated state machine; behavior is mostly from frame data, collision, and generic landing logic. |
| `4` | Direct references around `0x413a18` and `0x42e7a3`. Handles jumping, airborne movement, air attack, and weapon/special jump branches. |
| `5` | Direct references around `0x41408b` and `0x42e786`. Handles dash movement, direction switching, dash attack, weapon dash attack, and landing/rowing transitions. |
| `6` | No clear direct state-machine branch was found. Docs describe rolling/flipping as similar to state `15`; most behavior is frame/collision/landing driven. |
| `7` | Direct reference around `0x42e7c0`. Defend-specific effects are mostly seen through input transitions and hit/defense handling. |
| `8` | No clear direct state-machine branch was found. Broken defend is mostly controlled by hit/defense logic, especially itr kind `6`. |
| `9` | Direct references around `0x4045c6`, `0x40a196`, and `0x418818`. Handles catching/cpoint-related behavior. |
| `10` | Direct references around `0x41775e` and `0x4184e8`. Handles caught/collision permissions. |
| `11` | No clear direct state-machine branch was found. Docs describe injured as no dedicated state machine; most behavior is frame/hit driven. |
| `12` | Direct references around `0x40e7ac`, `0x40ef52`, `0x417abd`, `0x4184c8`, and `0x42ead8`. Handles falling frame routing, ground transition, bounce, and lying transition. |
| `13` | Direct references around `0x40dc27`, `0x40e930`, `0x41773a`, `0x4178b3`, `0x420eab`, `0x420ecc`, `0x42eabf`, and `0x42fce2`. Handles ice, ice landing, collision, and break/reaction logic. |
| `14` | Direct references around `0x4070e6`, `0x407185`, `0x408d84`, `0x40a0d6`, `0x40a21e`, `0x41b939`, `0x41b98e`, `0x41b9e6`, `0x41ba3e`, and `0x41e695`. Handles lying, death, and related AI/object update behavior. |
| `15` | No clear direct state-machine branch was found. This is the misc/default state; behavior should normally come from frame data, collision, or generic compatibility handling. |
| `16` | Direct reference around `0x417dfc`. Used by dance-of-pain/grab/super-punch interaction logic. |
| `17` | Direct reference around `0x41809e`. Used by drinking/healing behavior for milk and beer. |
| `18` | Direct references around `0x40a602`, `0x40e89e`, `0x4175a7`, `0x4175fc`, `0x41769a`, `0x417801`, `0x42e26d`, and `0x42fd52`. Handles burning frame routing, fire interaction, projectile/collision rules, and ground transition. |
| `19` | Direct references around `0x4175cf`, `0x417624`, `0x41767a`, and `0x42e291`. Firerun also shares the z-axis input movement path with state `301` around `0x413374`. |

Direct references were also found for special states including `301`, `400`,
`401`, `500`, `501`, `1000`, `1002`, `1004`, `1700`, `2000`, `2004`,
`3000`, `3003`, `3005`, `3006`, `9995`, `9996`, `9997`, and `9998`.

## Current Implementation Comparison

| State | Current alignment | Known gaps / next work |
| --- | --- | --- |
| `0`, `1` | Broad idle/walk input behavior exists. | Exact walking frame cycle, weapon branches, random frame details, AI-triggered transitions, and some action priorities are still approximate. |
| `2` | Running, z movement, attack/jump/defend/opposite input are represented. | Weapon-specific run attack branches and exact frame transitions need to be matched more closely. |
| `3` | Minimal attack-state handling exists. | State `3` should not own much behavior. Landing/crouch cleanup probably belongs in generic landing or compatibility logic instead. |
| `4` | Jump and air attack behavior exists. | Weapon/special jump branches and exact frame choices are simplified. |
| `5` | Dash movement, direction switching, and dash attack behavior exist. | Weapon dash attack paths, landing transitions, and exact state timing need refinement. |
| `6` | Rolling/flipping has practical landing cleanup. | Since original state `6` has no obvious state machine, any extra logic here should be reviewed and moved if it is actually generic landing behavior. |
| `7` | Basic defend behavior exists. | Exact defend break, `bdefend`, fall damage, and frame `110/111` behavior need more work in hit/kind logic. |
| `8` | Broken defend is mostly minimal. | Verify itr kind `6` and defense-break logic rather than adding more state-local code. |
| `9` | Cpoint/catching behavior is substantial. | Exact cpoint timing, victim alignment, throw timing, and catch release behavior are still likely approximate. |
| `10` | Caught state exists. | Weapon dropping while caught is still incomplete. |
| `11` | Injured wait behavior exists. | Heavy weapon drop and exact fall/stun interaction are incomplete. |
| `12` | Falling and landing routing exists. | Exact fall thresholds, bounce, low-fall immunity, lying transition, and weapon drop behavior are incomplete. |
| `13` | Ice state and landing damage behavior exist. | Exact no-break velocity threshold, shard/effect spawning, damage amounts, and reaction frames are incomplete. |
| `14` | Lying/dead loop exists. | Alive blink, death warning, retreat/AI-related behavior, and exact death transition details are incomplete. |
| `15` | Generic misc handling exists. | Avoid treating state `15` as a dumping ground. Prefer frame data, generic landing handling, or compatibility logic when behavior is not truly state-specific. |
| `16` | Minimal stunned/dance-of-pain handling exists. | Most catch/super-punch behavior should remain in kinds/collision logic. |
| `17` | Drinking behavior exists for milk/beer ids. | Depends on imported weapon ids/data. Exact heal timing and bottle/weapon behavior should be checked against converted data. |
| `18` | Burning frame routing and some fire interaction behavior exist. | Smoke spawning, exact frame thresholds, self-hit/team-hit exceptions, and projectile immunity rules are incomplete. |
| `19` | Firerun z-axis movement is aligned with the shared state `301` movement branch. | Smoke spawning, fire collision details, and exact interaction exceptions need refinement. |

## Implementation Priorities

1. Keep states `3`, `6`, `8`, `11`, and `15` thin unless a behavior is clearly
   state-owned in the original. These states mostly rely on frame data,
   collision kinds, or generic compatibility behavior.
2. Tighten states `0`, `1`, `2`, `4`, and `5` first because they control core
   play feel: walking, running, jumping, dashing, and weapon attacks.
3. Then tighten states `12`, `13`, `18`, and `19` because falling, ice,
   burning, and firerun still have important threshold/effect differences.
4. Prefer original DAT frame data and existing state/kind entrypoints over
   hardcoded per-character compatibility profiles.

