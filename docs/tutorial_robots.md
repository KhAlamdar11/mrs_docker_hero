# Real robots

In this tutorial you will fly a real Crazyflie and drive a real herover. Do the [simulation tutorial](tutorial_simulation.md) first: the real herover takes the same commands as the simulated one.

**Always fly and drive with a supervisor in the room.** Before any take-off, everyone stays out of the flying area.

---
## Crazyflies

Crazyflies are tiny quadcopters, about 27 g. Each one talks to your laptop through a **Crazyradio** USB dongle and has an address like `radio://0/90/2M/E7E7E7E7E1`.

A Crazyflie can't tell where it is by itself. The **motion capture** system (OptiTrack cameras around the room) tracks a marker on each Crazyflie and sends its position to the laptop. The **Crazyflie server** passes it on to the drone and gives you the same services as in the simulator: `takeoff`, `go_to`, `land`.

Which Crazyflies you fly, their addresses and their start positions are in `~/ros2_ws/src/hero_mrs/config/crazyflies_real.yaml`.

**NOTA BENE**
- **Emergency stop**: this cuts the motors of every Crazyflie at once, and they drop. Have it typed in a terminal before every take-off:
    ```bash
    ros2 service call /all/emergency std_srvs/srv/Empty
    ```
- **Battery**: `ros2 topic echo /cf_1/status` shows `battery_voltage`. Above 4 V is full, around 3.1 V is empty. The voltage dips during take-off and climbing, so read it while hovering.
- **cfclient**, the Crazyflie app, is handy for checking a single drone. Close it before starting the Crazyflie server: both can't use the radio at once.

### Hands-on #1

Do this with a supervisor.

1. Plug in the Crazyradio. Put the Crazyflies on the floor at their start positions and switch them on.
2. In `~/ros2_ws/src/hero_mrs/config/crazyflies_real.yaml`, set `enabled: true` only for the Crazyflies on the floor, and `enabled: false` for the rest.
3. Start the Crazyflie server, motion capture and RViz:
    ```bash
    cd ~/ros2_ws/src/hero_mrs/startup
    ./start.sh
    ```
4. Wait until the server prints `All Crazyflies are fully connected!`. Don't fly before that.
5. Open a new tmux window (`Ctrl+b, c`) and type the emergency stop command from above, without pressing Enter yet.
6. Take off, move 0.3 m from where it is, and land. Start small like this, with a low height and a short move:
    ```bash
    ros2 service call /cf_1/takeoff crazyflie_interfaces/srv/Takeoff "{height: 0.5, duration: {sec: 2}}"
    ros2 service call /cf_1/go_to crazyflie_interfaces/srv/GoTo "{goal: {x: 0.3, y: 0.0, z: 0.0}, relative: true, duration: {sec: 3}}"
    ros2 service call /cf_1/land crazyflie_interfaces/srv/Land "{height: 0.0, duration: {sec: 2}}"
    ```
7. Stop everything with `Ctrl+b, k`.

---
## herover

The herover is a small ground robot with mecanum wheels: it can drive forward, sideways and turn on the spot. It gets commands over WiFi, so your laptop must be on the same WiFi network as the robot.

On the laptop, the **bridge** listens to `/herover_1/cmd_vel` and sends every command to the robot. It's the same topic as in the simulator. The robot's address is in `~/ros2_ws/src/herover/config/robots.yaml`.

**NOTA BENE**
- The real herover is slow: at most about 0.17 m/s.
- `go_to` exists only in the simulator. On the real robot, use `cmd_vel`.
- The robot keeps its last command. Always send a stop (`"{}"`) when you're done.

### Hands-on #2

Do this with a supervisor.

1. Connect your laptop to the robots' WiFi and switch the herover on.
2. Start the bridge:
    ```bash
    ros2 run herover cmd_vel_bridge
    ```
3. In another tmux pane, drive it a little and stop it:
    ```bash
    ros2 topic pub --once /herover_1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.1}}"
    ros2 topic pub --once /herover_1/cmd_vel geometry_msgs/msg/Twist "{}"
    ```
4. Drive it with a gamepad (Logitech F710, switch on the back set to **X**). Hold **LB** to drive. The left stick moves it, the right stick turns it, and holding **RB** too makes it faster:
    ```bash
    ros2 launch herover joy_teleop.launch.py
    ```

---
## From simulation to the real robots

The topic and service names are the same, so the same code runs on both. What changes:

| | hero_sim | Real robots |
|---|---|---|
| Positions | perfect | from motion capture, with a little noise |
| Speed | anything you ask, up to 2 m/s | herover about 0.17 m/s, Crazyflies slower than you'd think indoors |
| Ground robot `go_to` | yes | no, use `cmd_vel` |
| Collisions | the robot stops | the robot crashes |

Test in hero_sim first, then on the real robots with low speeds.
