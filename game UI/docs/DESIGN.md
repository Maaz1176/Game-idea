WAYFINDER - UI DESIGN
Part 1: Written Design

1. STAMINA BAR
States: Full (100), ready (30-99), low (1-29), or empty (0). Sprint is blocked below 20.
Content in / out: Starts at 65. Sprint takes 20 stamina; Recover adds up to 25. Items can also change it.
No mouse: Press Tab to choose Sprint or Recover, then press Enter or Space.
Feedback: The number and bar change. A message says success or explains a failed action.
Limits / long text: At 0, Sprint cannot work. At 100, Recover cannot work. The number stays short.
Save and load: Yes. The stamina number is saved and restored.
New players: It is always shown in the top-left corner with clear labels.

2. HOTBAR
States: A slot can be empty, filled, or a spent potion (x0). It can be selected and focused. Actions can fail.
Content in / out: Starts with four items and one empty slot. Change with C, clear with Backspace, and use with E.
No mouse: Keys 1-5 select slots. E uses, C changes, and Backspace clears. Tab and Enter also work.
Feedback: The selected slot is highlighted. A message tells us what happened or why it failed.
Limits / long text: There are only five slots. At zero potions, SPENT is shown. Long item text is cut to fit.
Save and load: Yes. The slots, selected slot, and potion amount are saved.
New players: It is shown at the bottom, with keyboard instructions on screen.

3. QUEST LOG
States: Empty (0), some quests (1-4), or full (5). Quests are active or complete; details open or closed.
Content in / out: Starts with two quests. Add adds one; Remove deletes the last. Select a quest to mark it complete.
No mouse: Press J to go to the quests. Use Tab and Enter/Space. Escape closes quest details.
Feedback: A completed quest gets [x]. The quest count and the message also change.
Limits / long text: At 0 it says NO QUESTS. At 5, Add is disabled. READ FULL shows long quest text.
Save and load: Yes. The quest list and completion states are saved.
New players: It is always shown in the top-right corner with Add, Remove, and Read Full buttons.

HOW THEY WORK TOGETHER
1. All three are in one Godot scene. Containers keep the layout organised when the window is resized.
2. One Theme styles every element, including a clear keyboard-focus outline.
3. The panels do not cover each other. Quest details open above them, and shortcuts do not affect the hotbar while that window is open.
4. Save and Load work for all three elements.
