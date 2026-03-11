# Session 1.2: Hardware Assembly — Servos & Wiring

## Session Goals
1. Understand how servo motors work and communicate
2. Understand the daisy-chain bus architecture
3. Sort and clean all 3D printed parts
4. Inventory screws and cables
5. Configure driver board for USB mode
6. Program servo IDs

---

## TEACH: How Servo Motors Work

**Key points to cover:**
- A servo motor = DC motor + gearbox + position encoder + control circuit, all in one package
- The STS3215 is a "smart serial servo" — you send it commands over a data line, not just voltage
- Each servo has a unique ID on the bus (like an address on a network)
- You can command it to: go to position X, read current position, set speed, set torque limit
- Gear ratio matters:
  - Higher ratio (1:345) = more torque, slower speed — used for base, heavy lifting
  - Lower ratio (1:147) = less torque, faster — used for wrist, gripper
  - Your follower uses all 1:345 (needs torque to move under load)
  - Your leader has mixed ratios (passive, so it doesn't matter as much)

**Analogy:** Each servo is like a mini computer that knows its own position. Instead of "dumb" motors that just spin when you give them power, these can be told "go to position 2048" and they'll go there and hold.

**Check understanding:** Ask why the follower needs high-torque motors but the leader doesn't.

- [x] Concept covered and understood

---

## TEACH: Bus Communication & Daisy Chain

**Key points to cover:**
- All 6 motors share a single data wire (half-duplex serial bus)
- The driver board is the "master" — it sends commands, motors respond
- Daisy chain: Board → Motor 1 → Motor 2 → ... → Motor 6
- Each STS3215 has 2 ports (in/out) — this is how you chain them
- The board addresses motors by ID: "Motor 3, go to position 1500"
- This is why IDs must be unique and set BEFORE assembly — if two motors have the same ID, commands collide
- The data bus also carries power — one power supply feeds all 6 motors through the chain
- Protocol: TTL serial at 1Mbps (for reference, USB is much faster — the bottleneck is the bus)

**Analogy:** Like a phone chain — one wire connects everyone, but each person has their own name (ID) so they know when a message is for them.

**Check understanding:** Ask what happens if two motors have the same ID.

- [x] Concept covered and understood

---

## TEACH: Leader vs Follower — Why Two Arms?

**Key points to cover:**
- Follower arm = the actual robot. Motors are powered, it performs tasks.
- Leader arm = your input device. You move it by hand, it reads your joint positions.
- During teleoperation: read leader positions → send those positions to follower → follower mirrors you
- Leader motors have gears REMOVED — so you can move it freely by hand without fighting the gearbox
- Leader only uses the motor's position encoder (the sensor inside), not the motor power
- This is the simplest form of teleoperation — direct joint-to-joint mapping
- More advanced systems use VR controllers, motion capture, etc. — but leader-follower is intuitive and reliable

**Check understanding:** Ask why we remove gears from the leader but not the follower.

- [x] Concept covered and understood

---

## DO: Sort and Clean 3D Printed Parts

- [x] All parts cleaned and sorted (done during 1.1)

---

## DO: Inventory Screws, Cables & Tools

Screws (should be included with servo kit):
- [ ] M2x6mm screws — motor mounting (4 per motor, 48 total)
- [ ] M3x6mm screws — horn screws and structural attachment
- [ ] 3-pin servo cables (7 per arm: 6 motor-to-motor + 1 to board)
- [ ] Motor horns (circular discs, 2 per motor)
- [ ] Phillips screwdriver #0 and #1

- [x] Inventoried (confirmed during session)

---

## DO: Sort Motors

See `docs/HARDWARE_STATE.md` for motor configuration, gear ratios, and power supply specs.

**CRITICAL:** Never plug 12V into 7.4V leader motors — it will burn them.

- [x] Motors sorted and labeled (done during 1.1)
- [x] Power supplies labeled

---

## DO: Configure Driver Board for USB Mode

**Board:** Bus Servo Driver Board for XIAO v1.0

**Result:** Board works via USB-C out of the box — no jumper cap or solder bridge modification needed. This board variant (included with SO-ARM101 kit) comes pre-configured for USB mode.

**Power connection:** DC pigtail cable (barrel jack socket → bare wires) into green screw terminal (red=+, black=-). 12V power supply barrel plug goes into the pigtail socket.

- [x] Board works via USB — confirmed with `lerobot-find-port`

---

## DO: Program Servo IDs

**Prerequisite:** LeRobot installed with Feetech support (done in 1.1)

Connect ONE motor at a time to the driver board + USB + correct power supply.

### Find your port:
```bash
conda activate lerobot
lerobot-find-port
```

### Set follower IDs (use 12V/5A power):
```bash
lerobot-setup-motors \
    --robot.type=so101_follower \
    --robot.port=/dev/tty.YOUR_PORT
```

### Set leader IDs (use leader power supply):
```bash
lerobot-setup-motors \
    --teleop.type=so101_leader \
    --teleop.port=/dev/tty.YOUR_PORT
```

**Motor ID assignment order (script walks you through this):**

| Order | ID | Joint |
|:---:|:---:|---|
| 1st | 6 | Gripper |
| 2nd | 5 | Wrist Roll |
| 3rd | 4 | Wrist Flex |
| 4th | 3 | Elbow Flex |
| 5th | 2 | Shoulder Lift |
| 6th | 1 | Shoulder Pan (base) |

**Reminders:**
- Connect only ONE motor at a time when programming IDs
- Write the ID on each motor with a marker after programming
- Leave motor connected on the 3-pin cable's other end — it'll be in the right place for assembly

- [x] All 6 follower motor IDs set
- [x] All 6 leader motor IDs set

---

## Session Completion Checklist
- [x] TEACH: How servo motors work — covered and understood
- [x] TEACH: Bus communication & daisy chain — covered and understood
- [x] TEACH: Leader vs follower — covered and understood
- [x] DO: 3D parts sorted and cleaned (done during 1.1)
- [x] DO: Screws, cables, tools inventoried
- [x] DO: Motors sorted and labeled (done during 1.1)
- [x] DO: Driver board configured for USB mode (works out of the box, no jumper needed)
- [x] DO: All 12 servo IDs programmed
- [x] COURSE_PROGRESS.md updated
