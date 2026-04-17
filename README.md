# Super Mario Bros - x86 Assembly (MASM)

An authentic, low-level recreation of the classic **Super Mario Bros** platformer. This project demonstrates mastery of computer organization, memory management, and real-time game physics using **MASM615**.

---

## Key Features

### Roll Number Customization: "High Jump Mario"
This version is uniquely customized based on **Roll No: 24I-0857**.
* **Double Jump Mechanics**: Mario can perform a second jump while in mid-air.
* **Spring Mushroom**: Added a custom green mushroom that increases jump height by 60%.
* **Interactive Audio**: Jump sound effects feature distinct two-tone melodies.
* **Visual Identity**: Mario wears a green shirt based on roll number parity.

### Technical Implementation
* **Pure Assembly Logic**: Implementation strictly avoids high-level constructs like `if/else` or `while` loops, utilizing raw `CMP` and `JMP` instructions for all logic.
* **Physics Engine**: Features real-time gravity, variable jump height, and horizontal acceleration/deceleration.
* **Persistent Progress**: Integrated File I/O system to save and load high scores via `scores.txt`.
* **Sound System**: Comprehensive 8-bit audio for jumps, coin collection, and enemy defeats.

---

## How to Play

### Controls
| Action | Key |
| :--- | :--- |
| **Move Left/Right** | `A` / `D` or Arrow Keys |
| **Jump / High Jump** | `W` or `UP` (Hold for height) |
| **Sprint** | Hold `Shift` |
| **Fire Projectile** | `F` (When Fire Master is active) |
| **Pause Game** | `P` |

### Game Elements
* **Enemies**: Avoid or stomp on Goombas (G), Air Enemies (V), and Flying Turtles (K).
* **Power-ups**: Collect Super Mushrooms to grow and Fire Flowers to shoot blue fireballs.
* **Goal**: Reach the flagpole at the end of the level to advance.

---

## Project Structure

```text
Super-Mario-MASM/
├── src/
│   └── Source.asm          # Core Game Logic and State Machine
├── assets/
│   └── scores.txt          # Persistent High Score Database
├── docs/
│   └── Coal Lab Project.docx # Technical Requirements
├── screenshots/            # Visual proof of implementation
│   ├── title_screen.png    # Shows Roll No and Menu
│   └── gameplay.png        # Shows HUD and Level Map
└── README.md               # Project Documentation