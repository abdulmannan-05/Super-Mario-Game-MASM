# ?? Technical Features: High Jump Mario Edition

This document outlines the specific technical implementations and custom logic developed for the **Super Mario Bros** project, as per the individual requirements for **Roll No: 24I-0857**.

---

## ?? 1. Roll Number Customization: High Jump Mario
[cite_start]Following the mandatory requirements for a roll number ending in **7**, this version of the game focuses on enhanced verticality and specific visual parity[cite: 21, 22].

### **Double Jump Logic**
* [cite_start]**Mechanism**: Mario is granted the ability to "Double Jump," allowing a second jump impulse while mid-air[cite: 32].
* **Technical Implementation**: 
    * A `jumpCount` variable tracks the number of jumps since the last ground contact.
    * The system allows a second jump only if `jumpCount < 2`.
    * The counter resets to zero only when the physics engine detects a collision with ground blocks (`#`) or pipes (`P`).

### **Spring Mushroom (Green Mushroom)**
* [cite_start]**Effect**: Collection of the Green Mushroom increases Mario's vertical impulse[cite: 33].
* [cite_start]**Logic**: Upon collection, the `velocityY` constant is modified, increasing the jump height by exactly **60%**[cite: 33].
* [cite_start]**Audio Feedback**: A unique two-tone "Springy" sound effect is triggered using the `Beep` API to distinguish this from a standard jump[cite: 34].

### **Visual Theme**
* [cite_start]**Shirt Parity**: Because **7** is an odd number, Mario wears a **GREEN** shirt in-game[cite: 46].
* [cite_start]**HUD Integration**: The title screen prominently displays **Roll No: 24I-0857** to verify the customization matches the student identity[cite: 95].

---

## ?? 2. Free Creative Choice: Advanced Fire Master System
[cite_start]For the required unique feature[cite: 47], I have implemented an **Advanced Fire Master System**.

* [cite_start]**Blue Fireball Mechanics**: Mario's projectiles are blue instead of the classic red[cite: 37].
* **Entity Collision Matrix**: The fireball doesn't just travel; it constantly scans the map for active enemy coordinates (Goombas, Koopas, and Flying enemies).
* [cite_start]**Dynamic Scoring**: Defeating an enemy with a fireball grants a specialized bonus of **200 points**, promoting a more aggressive playstyle[cite: 270].

---

## ?? 3. Persistent Data & High Scores
[cite_start]To achieve the "Exceptional Implementation" standard[cite: 324], the game includes a robust file handling system.

* **File I/O**: The game reads from and writes to `scores.txt` using raw Assembly file handles.
* **High Score Management**: 
    * The system tracks the top 5 scores.
    * [cite_start]It compares the current player's score at the end of the game[cite: 313].
    * If a new record is set, it performs a shift-and-insert operation in memory and overwrites the file to ensure the data persists across game sessions.

---

## ?? 4. Technical Constraints Compliance
* **Pure Assembly**: The project strictly avoids high-level directives like `.IF` or `.WHILE`. [cite_start]All branching logic is handled through `CMP` and `JMP` variants[cite: 89].
* [cite_start]**Irvine32 Graphics**: The entire user interface, including the 8-bit style HUD and level maps, is rendered using the Irvine32 library's coordinate system[cite: 88].