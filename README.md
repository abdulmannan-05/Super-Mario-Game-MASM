# ?? Super Mario Bros - x86 Assembly (MASM)

![Assembly](https://img.shields.io/badge/Language-Assembly%20(x86)-red)
![Library](https://img.shields.io/badge/Library-Irvine32-blue)
![Tier](https://img.shields.io/badge/Tier-Academic%20Project-brightgreen)

An authentic, low-level recreation of the classic **Super Mario Bros** platformer. [cite_start]This project demonstrates mastery of computer organization, memory management, and real-time game physics using **MASM615**[cite: 81].

---

## ?? Key Features

### ?? Roll Number Customization: "High Jump Mario"
[cite_start]This version is uniquely customized based on **Roll No: 24I-0857**[cite: 20, 21].
* [cite_start]**Double Jump Mechanics**: Mario can perform a second jump while in mid-air[cite: 32].
* [cite_start]**Spring Mushroom**: Added a custom green mushroom that boosts jump height by 60%[cite: 33].
* [cite_start]**Interactive Audio**: Jump sound effects feature distinct two-tone melodies[cite: 34].
* [cite_start]**Visual Identity**: Mario sports a custom green shirt based on roll number parity[cite: 46].

### ?? Technical Implementation
* [cite_start]**Pure Assembly Logic**: Implementation strictly avoids high-level constructs like `if/else` or `while` loops, utilizing raw `CMP` and `JMP` instructions for all logic[cite: 89].
* [cite_start]**Physics Engine**: Real-time gravity, variable jump height, and horizontal acceleration/deceleration[cite: 196, 205, 208].
* **Persistent Progress**: Integrated File I/O system to save and load high scores via `scores.txt`.
* [cite_start]**Sound System**: Comprehensive 8-bit audio for jumps, coin collection, and enemy defeats[cite: 243, 244].

---

## ?? How to Play

### Controls
| Action | Key |
| :--- | :--- |
| **Move Left/Right** | [cite_start]`A` / `D` or Arrow Keys [cite: 192] |
| **Jump / High Jump** | [cite_start]`W` or `UP` (Hold for height) [cite: 205] |
| **Sprint** | [cite_start]Hold `Shift` [cite: 200] |
| **Fire Projectile** | [cite_start]`F` (When Fire Master is active) [cite: 36] |
| **Pause Game** | [cite_start]`P` [cite: 305] |

### Game Elements
* **Enemies**: Avoid or stomp on Goombas (G), Air Enemies (V), and Flying Turtles (K).
* [cite_start]**Power-ups**: Collect Super Mushrooms to grow and Fire Flowers to shoot blue fireballs[cite: 212, 217].
* [cite_start]**Goal**: Reach the flagpole at the end of the world to advance[cite: 111].

---

## ?? Project Structure

```text
Super-Mario-MASM/
??? src/
?   ??? Source.asm          # Core Game Logic & State Machine
??? assets/
?   ??? scores.txt          # Persistent High Score Database
??? docs/
?   ??? Coal Lab Project.docx # Technical Requirements
??? screenshots/
?   ??? title_screen.png    # Shows Roll No & Menu
?   ??? gameplay.png        # Shows HUD & Level Map
??? README.md               # Project Documentation