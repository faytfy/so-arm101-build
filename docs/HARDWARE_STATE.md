# Hardware State Tracker

## Model: SO-ARM101 (12V high-torque variant)

## Components Inventory
- [x] 3D printed parts — for 2 arms (leader + follower)
- [x] STS3215 servo motors — 12 total
  - Leader arm: 2x C044 (1:191, 7.4V), 1x C001 (1:345, 7.4V), 3x C046 (1:147, 7.4V)
  - Follower arm: 6x C047 (1:345, 12V) — 30 kg·cm torque
  - NOTE: Follower uses 12V motors, leader uses 7.4V motors
- [x] Servo driver board — Bus Servo Driver Board for XIAO v1.0 (x2, one per arm)
  - USB-C connection works out of the box — no jumper or solder bridge needed
- [x] Power supply
  - 12V/5A — for follower arm (correct for SO-ARM101)
  - 5V — for leader arm (leader motors are 7.4V but passive, 5V works for ID programming)
- [x] USB cable (USB-C)
- [x] Screws, bearings, misc hardware — used during assembly
- [x] Cables / servo extension wires — daisy-chained during assembly
- [x] 3D-printed desk clamps (2 per arm) with thumbscrews

## Prep Status
- 3D parts: Cleaned and sorted into leader/follower piles
- Motors: Sorted into leader (7.4V) and follower (12V) piles
- Power supplies: Labeled (12V/5A → follower, 5V → leader)
- Power connection: DC pigtail cable (barrel jack → bare wires) into green screw terminal (red=+, black=-)
- Screws/cables: Used during assembly — all accounted for

## Assembly Status
- Follower arm: ASSEMBLED & MOUNTED
- Leader arm: ASSEMBLED & MOUNTED
- Mounting: 3D-printed desk clamps (2 per arm)

## Motor IDs Assigned

### Follower arm (12V, all 1:345 / C047)
| ID | Joint |
|:---:|---|
| 1 | Shoulder Pan |
| 2 | Shoulder Lift |
| 3 | Elbow Flex |
| 4 | Wrist Flex |
| 5 | Wrist Roll |
| 6 | Gripper |

### Leader arm (7.4V, mixed ratios)
| ID | Joint | Gear Ratio | Motor |
|:---:|---|:---:|:---:|
| 1 | Shoulder Pan | 1/191 | C044 |
| 2 | Shoulder Lift | 1/345 | C001 |
| 3 | Elbow Flex | 1/191 | C044 |
| 4 | Wrist Flex | 1/147 | C046 |
| 5 | Wrist Roll | 1/147 | C046 |
| 6 | Gripper | 1/147 | C046 |

### Board ports
**Mac:**
- Follower: /dev/tty.usbmodem5AAF2626601
- Leader: /dev/tty.usbmodem5AAF2625931

**Jetson:**
- Follower: /dev/ttyACM0
- Leader: /dev/ttyACM1
- Note: `sudo chmod 666 /dev/ttyACM*` needed after each reboot/reconnect

## Calibration Status
- Follower: CALIBRATED on both Mac and Jetson (id=follower)
- Leader: CALIBRATED on both Mac and Jetson (id=leader)
- Teleoperation: VERIFIED on both Mac and Jetson

## Jetson AGX Orin
- IP: <JETSON_IP> (SSH as <user>@, key auth configured) — IP may change after reboot (DHCP)
- Hostname: <jetson-hostname>
- JetPack: 6.2.2 / CUDA 12.6
- RAM: 64GB unified
- Disk: 915GB NVMe (839GB free)
- Conda env: lerobot (Python 3.12.13)
- PyTorch: 2.6.0 (built from source with TORCH_CUDA_ARCH_LIST=8.7 for sm_87 Orin support)
- torchvision: 0.21.0 (built from source)
- FFmpeg: 7.1.1
- LeRobot: 0.5.1 (source install at ~/lerobot)

## PC (Training Machine)
- IP: <PC_IP> (SSH as <user>@, key auth configured)
- OS: Ubuntu
- GPU: NVIDIA RTX 5060 Ti (Blackwell, sm_120)
- Conda env: lerobot (Python 3.12)
- PyTorch: 2.7.0+cu128 (pre-built wheels, sm_120 support)
- FFmpeg: 7.1.1
- LeRobot: 0.5.1 (source install at ~/lerobot)
- Training speed: ~5.4 steps/sec (~6x faster than Jetson)
- Note: torchcodec incompatible with PyTorch 2.7 — use `--dataset.video_backend=pyav`

## Cameras
- Lenovo 500 FHD → assigned as `top` (overhead view)
  - Mac: OpenCV index 0
  - Jetson: /dev/video2
- Logitech VU0029 → assigned as `front` (workspace-facing view)
  - Mac: OpenCV index 1
  - Jetson: /dev/video0
- Resolution: 640x480 @ 30fps

## Known Issues
- Gripper motor (ID 6) throws "Overload error" on disconnect — harmless, recording completes fine
- Headless mode on Jetson (SSH) — no camera preview, but recording works normally
