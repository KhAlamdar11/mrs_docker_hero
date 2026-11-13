# hero_mrs

The Docker environment for the HERO project. Use it to run the **hero_sim** simulator and to fly the real **Crazyflies** and drive the real **herover** robots.

The container has ROS 2 Humble, crazyswarm2, motion capture tracking, cfclient and [hero_sim](https://github.com/larics/hero_sim).

## Installation and setup

For students: do these three steps at home, before the first session. They take about an hour, mostly downloading. They're in [docs/installation.md](docs/installation.md):

1. [Install Docker](docs/installation.md#step-1-install-docker)
2. [Build the image](docs/installation.md#step-2-build-the-image)
3. [Bind your package, create the container and run the example](docs/installation.md#step-3-bind-your-package-create-the-container-and-run-the-example)

New to Docker, tmux or the robots? After the installation, do the tutorials in this order:

1. [Docker and tmux](docs/tutorial_docker_tmux.md)
2. [Simulation](docs/tutorial_simulation.md)
3. [Real robots](docs/tutorial_robots.md)

## Quick start

Every time you work with the simulator:

1. On your laptop, start the container. You get a terminal inside it:
   ```bash
   docker start -i mrs_hero_container
   ```
2. Start the simulator with a scenario. RViz opens, and you're in a tmux session called `hero_sim`:
   ```bash
   cd ~/ros2_ws/src/hero_sim/startup
   bash start.sh mrs_world_example.yaml
   ```
   For your own scenario, give its path instead, see [Your own scenario](#your-own-scenario-robots-and-map).
3. Open new tmux window with `Ctrl+b`, then `c`, and run your own nodes.
   Alternatively you may also use the following command in a new terminal to attach that terminal to the running container:
   `docker exec -it mrs_hero_container bash`

4. Stop the simulator with `Ctrl+b`, then `k`. Leave the container with `exit`.

In tmux, `Shift` + left/right switches between windows and `Ctrl` + arrows between panes. The [Docker and tmux tutorial](docs/tutorial_docker_tmux.md#tmux) has the rest.

## Your own scenario: robots and map

[hero_sim](https://github.com/larics/hero_sim) is a lightweight simulator. It draws the robots in RViz and moves them exactly as commanded, with no physics. You command the simulated robots through the same ROS 2 topics as the real ones.

A **scenario** defines the robors, where they start, and which map they drive in among other details. In this course, the map format is same as the stage simulator you have used in previous labs..

Keep your scenarios in your package, so they're saved on your laptop. An example of a scenario config file is provided [here](https://github.com/larics/hero_sim/blob/master/config/mrs_world_example.yaml).

You can run the simulation in container with path to your scenario file.

```
cd ~/ros2_ws/src/hero_sim/startup
bash start.sh ~/path/to/your/config/mrs_world.yaml
```

Available maps are provided in the same format as stage simulator in `hero_sim/maps` folder.