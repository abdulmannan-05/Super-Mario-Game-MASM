# Technical Features: High Jump Mario Edition

This document outlines the specific technical implementations and custom logic developed for the **Super Mario Bros** project for **Roll No: 24I-0857**.

---

## 1. Roll Number Customization: High Jump Mario
Following the mandatory requirements for a roll number ending in **7**, this version focuses on enhanced verticality.

### **Double Jump Logic**
* **Mechanism**: Mario is granted the ability to "Double Jump," allowing a second jump impulse while mid-air.
* **Technical Implementation**: 
    * A `jumpCount` variable tracks jumps since the last ground contact.
    * The system allows a second jump only if `jumpCount < 2`.
    * The counter resets to zero only when the physics engine detects a collision with ground blocks (`#`) or pipes (`P`).

### **Spring Mushroom (Green Mushroom)**
* **Effect**: Collection of the Green Mushroom increases Mario's vertical impulse.
* **Logic**: Upon collection, the `velocityY` constant is modified, increasing the jump height by exactly 60%.
* **Audio Feedback**: A unique two-tone sound effect is triggered using the `Beep` API.

---

## 2. Free Creative Choice: Advanced Fire Master System
Implemented as the required unique feature to enhance gameplay.

* **Blue Fireball Mechanics**: Mario's projectiles are blue instead of the classic red.
* **Entity Collision Matrix**: The fireball constantly scans the map for active enemy coordinates (Goombas, Koopas, and Flying enemies).
* **Dynamic Scoring**: Defeating an enemy with a fireball grants a specialized bonus of 200 points.

---

## 3. Persistent Data & High Scores
To achieve the "Exceptional Implementation" standard, the game includes a robust file handling system.

* **File I/O**: The game reads from and writes to `scores.txt` using raw Assembly file handles.
* **High Score Management**: 
    * The system tracks the top 5 scores.
    * It compares the current player's score at the end of the game.
    * If a new record is set, it performs a shift-and-insert operation and overwrites the file to ensure data persists across sessions.

---

## 4. Technical Constraints Compliance
* **Pure Assembly**: The project strictly avoids high-level directives like `.IF` or `.WHILE`. All branching logic is handled through `CMP` and `JMP` variants.
* **Irvine32 Graphics**: The entire user interface, including the 8-bit style HUD and level maps, is rendered using the Irvine32 library.