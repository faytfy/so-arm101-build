# Session 1.2 Handout: Servos & Wiring

## Concepts Covered

### 1. How Servo Motors Work

A servo motor is **four things in one housing:**
- **DC motor** — spins
- **Gearbox** — trades speed for torque (rotational force)
- **Position encoder** — knows exactly where the shaft is pointing
- **Control circuit** — a tiny computer that listens for commands

The STS3215 is a "smart serial servo" — instead of just spinning when given voltage, you can send it commands like "go to position 2048" and it will go there and hold.

### 2. Torque

**Torque = rotational force** — the twisting power a motor can exert.

- More torque = can push/lift heavier things
- Less torque = weaker, but typically faster
- The gearbox multiplies torque by reducing speed
- A 1:345 gearbox means the internal motor spins 345 times for every 1 rotation of the output shaft

**Analogy:** Like using a longer wrench — more leverage, more twisting power.

### 3. Gear Ratios

| Ratio | Meaning | Used for |
|---|---|---|
| 1:345 (high) | More torque, slower | Base, heavy joints |
| 1:191 (medium) | Balanced | Mid-arm joints |
| 1:147 (low) | Less torque, faster | Wrist, gripper |

### 4. Bus Communication & Daisy Chain

- All 6 motors share a **single data wire** (half-duplex serial bus)
- **Daisy chain:** Board -> Motor 1 -> Motor 2 -> ... -> Motor 6
- Each motor has 2 ports (in/out) for chaining
- The chain carries both **data and power**
- Each motor has a **unique ID** — the board addresses commands to specific motors by ID
- If two motors share the same ID, their signals **collide on the wire** and communication breaks down entirely

**Analogy:** Like a group phone call where everyone listens, but only the person whose name is called answers.

### 5. The Driver Board

The board is a **translator** between your computer and the motors:
- Converts USB (computer language) to TTL serial (motor language)
- Feeds power from the power supply to the motors

**Each arm gets its own board.** The leader and follower don't talk to each other directly — the computer reads from the leader board and writes to the follower board.

```
Computer (USB 1) -> Board 1 -> 6 Leader motors
Computer (USB 2) -> Board 2 -> 6 Follower motors
```

### 6. Leader vs Follower Arms

| | Follower | Leader |
|---|---|---|
| Purpose | The actual robot — does work | Your input device — you move it by hand |
| Motors | Powered, high torque (1:345) | Passive, mixed ratios |
| Gears | Kept in — needs torque | Removed later — so you can move freely |
| Key part | Motor power | Position encoder only |

**During teleoperation:** Computer reads leader positions -> sends to follower -> follower mirrors you in real time. Cameras record everything for training data.

**Why not use a keyboard/controller?** The leader arm gives you intuitive, simultaneous control of all 6 joints at once, producing smooth, natural training data. A controller would be one joint at a time — jerky and unnatural.

**VR alternative:** A Meta Quest can replace the leader arm using hand tracking + inverse kinematics. It works, but adds complexity (coordinate math, no physical feedback). Leader-follower is simpler and more reliable for learning.

---

## Q&A From This Session

**Q: Why does the follower need high-torque motors but the leader doesn't?**
A (Fay): Didn't know initially.
Correction: The follower physically moves things — carries loads, fights gravity. Every joint needs strength. The leader just reads your hand position — the motors aren't doing mechanical work, so torque doesn't matter. We even remove the gears later.

**Q: What happens if two motors have the same ID?**
A (Fay): "They will try to move to the same position but since it won't work so we might break the arm."
Correction: Close! But the collision happens at the communication level first — two motors try to respond on the same wire simultaneously, their electrical signals overlap and corrupt each other. The board gets garbled data and nothing works at all. Breaking the arm is a risk if wrong commands somehow got through, but the primary failure is communication breakdown.

**Q: What is torque?**
A (Fay): Asked for explanation.
Answer: Rotational force — the twisting power a motor can exert. Like pushing harder on a wrench gives more torque on a bolt. Gearboxes trade speed for torque.

**Q: What is the driver board for?**
A (Fay): Asked if it's only for communication and if the leader talks to the follower through it.
Answer: The board is a USB-to-serial translator + power distributor. Each arm has its own board. The leader and follower don't communicate directly — the computer is the brain in the middle, reading from one and writing to the other.

**Q: Can I use Meta Quest instead of a leader arm?**
A (Fay): Friend suggested it.
Answer: Yes! VR teleoperation is real and increasingly popular. Tradeoffs: VR is intuitive but has no physical feedback and needs inverse kinematics math. Leader arm is simpler and produces physically-constrained (always valid) training data.

**Q: Can I make the arms do the Macarena?**
A (Fay): Fun project idea.
Answer: Sort of — you'd get arm-only movements (no body/hips). Could choreograph a simplified version. A more practical fun project: pick-and-place to music.

---

## Hardware Reference

### SO-ARM101 Motor Configuration

**Follower arm** — all identical (12V, 1:345, C047):
| ID | Joint |
|:---:|---|
| 1 | Shoulder Pan |
| 2 | Shoulder Lift |
| 3 | Elbow Flex |
| 4 | Wrist Flex |
| 5 | Wrist Roll |
| 6 | Gripper |

**Leader arm** — mixed ratios (7.4V):
| ID | Joint | Ratio | Motor |
|:---:|---|:---:|:---:|
| 1 | Shoulder Pan | 1/191 | C044 |
| 2 | Shoulder Lift | 1/345 | C001 |
| 3 | Elbow Flex | 1/191 | C044 |
| 4 | Wrist Flex | 1/147 | C046 |
| 5 | Wrist Roll | 1/147 | C046 |
| 6 | Gripper | 1/147 | C046 |

### Board Setup
- Board: Seeed Studio Bus Servo Driver Board for XIAO V1.0
- USB-C connection — works out of the box, no jumper needed
- Power: DC pigtail cable (barrel jack -> bare wires) into green screw terminal (red=+, black=-)
- Follower board port: /dev/tty.usbmodem5AAF2626601
- Leader board port: /dev/tty.usbmodem5AAF2625931

### Power Supplies
- 12V/5A -> Follower arm ONLY
- 5V -> Leader arm ONLY
- NEVER plug 12V into 7.4V leader motors

---

## Vocabulary

| Term | Definition |
|---|---|
| **Servo motor** | Motor with built-in gearbox, position encoder, and control circuit |
| **Torque** | Rotational force — twisting power |
| **Gear ratio** | How many times the internal motor spins per one output rotation (e.g., 1:345) |
| **Daisy chain** | Connecting devices in series — Board -> Motor 1 -> Motor 2 -> ... |
| **Half-duplex** | Only one device can talk on the wire at a time |
| **TTL serial** | The communication protocol the motors use (Transistor-Transistor Logic) |
| **Motor ID** | Unique address (1-6) so the board can talk to specific motors |
| **Bus** | A shared communication wire that multiple devices use |
| **Driver board** | USB-to-serial translator + power distributor between computer and motors |
| **Inverse kinematics** | Math that converts a hand position in 3D space to joint angles |
| **EEPROM** | Non-volatile memory in the motor — settings persist after power off |
| **Barrel jack** | Round cylindrical power connector (5.5mm x 2.1mm) |
| **DC pigtail** | Adapter cable from barrel jack to bare wires |
