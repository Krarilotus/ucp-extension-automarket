# Changelog

## 1.1.0

This minor release changes the multiplayer settings packet and saved Automarket data format. The earlier 1.0.1 PR draft was renamed to 1.1.0 before release.

- Fix an oversized Automarket settings packet that could overwrite neighboring multiplayer commands and synchronization state.
- Synchronize each player's configured market fee with their settings so all peers charge that player the same fee. Fees take effect on **Save & Close** and are preserved in saves.
- Keep fee credit unchanged when a purchase fails because gold or storage is insufficient.
- Allow purchases that exactly meet the gold reserve after fees and earned refunds.
- Pay earned fee credit as soon as it reaches one gold, including exactly 100 hundredths.
- Reject settings commits with invalid player IDs or fee percentages.
- Add automated LuaJIT regression tests for synchronization, trading, and save compatibility.

All multiplayer participants must update together to **1.1.0**. Settings packets differ from 1.0.0; mixed versions are unsupported. Use matching configured fees when the match should charge everyone the same rate. This release synchronizes per-player fees; it does not impose the host's fee on other players.

Older Automarket saves retain thresholds and fee credit, but each player must open Automarket and use **Save & Close** before automated trading resumes. This avoids deriving a missing saved fee from different local configurations. New saves use Automarket data format 2 and cannot be loaded by 1.0.0 without losing Automarket settings.

This patch does not replace the shared protocol transport, provide recovery from arbitrary Lua/native callback failures, or add custom-state support to the game's in-match resync mechanism. Keep the documented LuaJIT stability workaround in mind if the game still crashes.
