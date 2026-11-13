# Installation and setup

For students of the MRS course. Do these three steps at home, before the first session. They take about an hour, mostly downloading.

> [!IMPORTANT]
> **You need:**
> - **Ubuntu 22.04 or 24.04** on your laptop
> - **20–25 GB of free disk space**. Check the `Avail` column of `df -h /`

1. [Install Docker](#step-1-install-docker)
2. [Build the image](#step-2-build-the-image)
3. [Bind your package, create the container and run the example](#step-3-bind-your-package-create-the-container-and-run-the-example)

If a step fails, look in [Troubleshooting](#troubleshooting).

## Step 1: Install Docker

1. Install the tools you need for the next steps:
   ```bash
   sudo apt update && sudo apt install -y curl git
   ```
2. Install Docker:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```
   If Docker is already installed, the script warns you and waits 20 seconds. Let it continue: it updates Docker and keeps your images.
3. Let your user run Docker without `sudo` and use USB serial devices:
   ```bash
   sudo usermod -aG docker $USER
   sudo usermod -aG dialout $USER
   ```
   Then restart your laptop.
4. Check that Docker works. It prints `Hello from Docker!`:
   ```bash
   docker run hello-world
   ```
5. Only if your laptop has an NVIDIA GPU, which means `nvidia-smi` prints a table: install the NVIDIA Container Toolkit.
   ```bash
   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
   curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   sudo apt update && sudo apt install -y nvidia-container-toolkit
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```

## Step 2: Build the image

1. Download this repository:
   ```bash
   cd ~
   git clone https://github.com/KhAlamdar11/mrs_docker_hero.git
   cd mrs_docker_hero
   ```
2. Build the image. This takes 30 to 60 minutes:
   ```bash
   docker build -t mrs_hero_image .
   ```
3. Check that it worked. `mrs_hero_image` should be in the list:
   ```bash
   docker images
   ```

## Step 3: Bind your package, create the container and run the example

1. Bind your ROS 2 package into the container: the package where you write your code for the course. Open `~/mrs_docker_hero/first_run.sh` and set `MY_PACKAGE_PATH` at the top to your package's folder on your laptop, with your package's name in place of `MY_PACKAGE_NAME`:
   ```bash
   MY_PACKAGE_PATH="~/MY_PACKAGE_NAME"
   ```
   The folder must exist. In the container, your package is `~/ros2_ws/src/MY_PACKAGE_NAME`. It's the same folder as on your laptop, not a copy: write your code on your laptop with any editor, then build and run it in the container. It stays safe even if you delete the container.
2. If your laptop has no NVIDIA GPU (you skipped step 1.5), delete the `--gpus all \` line in `first_run.sh`.
3. Allow the container to open windows on your screen. This line makes every new terminal do it:
   ```bash
   echo 'xhost +local: > /dev/null 2>&1' >> ~/.bashrc
   source ~/.bashrc
   ```
4. Create the container. It builds the workspace, your package included (a few minutes), and opens a terminal inside the container:
   ```bash
   cd ~/mrs_docker_hero
   ./first_run.sh
   ```
5. In that terminal, start the simulator. RViz opens:
   ```bash
   cd ~/ros2_ws/src/hero_sim/startup
   bash start.sh mrs_world_example.yaml
   ```
6. Open a new tmux window with `Ctrl+b`, then `c`, and drive `herover_3` forward, then stop it:
   ```bash
   ros2 topic pub --once /herover_3/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.3}}"
   ros2 topic pub --once /herover_3/cmd_vel geometry_msgs/msg/Twist "{}"
   ```
   In RViz, that herover drives forward and stops.
7. Stop the simulator with `Ctrl+b`, then `k`. Leave the container with `exit`.

You're done. From now on, use the [quick start](../README.md#quick-start) in the main README.

## Create the container again

Your package is bound only when the container is created. To bind a different package, set `MY_PACKAGE_PATH` again (step 3.1) and create a new container. This deletes everything inside the container except the `mrs_docker_hero` folder and your package:
```bash
cd ~/mrs_docker_hero
docker rm mrs_hero_container
./first_run.sh
```

## Troubleshooting

| Problem | What to do |
|---|---|
| `sudo apt update` fails with `NO_PUBKEY`, `EXPKEYSIG` or `is not signed` | The error names a repository that's broken on your laptop, often an old ROS one. Fix it or delete its file in `/etc/apt/sources.list.d/`, then try again |
| You already had Docker from snap (`snap list docker` lists it) | Two Dockers clash. Remove the snap one with `sudo snap remove docker` (this deletes its images) and restart |
| You already had Docker Desktop (`docker context ls` marks `desktop-linux` with `*`) | Switch to the Docker from step 1: `docker context use default` |
| `permission denied` when running `docker` | Do [step 1.3](#step-1-install-docker) and restart your laptop |
| The build stops with a network error | Run the same `docker build` again. It continues where it stopped |
| `could not select device driver "" with capabilities: [[gpu]]` | No NVIDIA GPU or toolkit: do [step 3.2](#step-3-bind-your-package-create-the-container-and-run-the-example) |
| `Conflict. The container name "/mrs_hero_container" is already in use` | The container already exists: `docker start -i mrs_hero_container`. To create it again, see [Create the container again](#create-the-container-again) |
| RViz doesn't open (`could not connect to display`) | Do [step 3.3](#step-3-bind-your-package-create-the-container-and-run-the-example), then open a new terminal and try again |
| `MY_PACKAGE_PATH at the top of first_run.sh must be an existing folder` | Fix the path in [step 3.1](#step-3-bind-your-package-create-the-container-and-run-the-example). The folder must exist |
| On your laptop, you can't save a file in your package (`permission denied`) | Files made inside the container belong to root. On your laptop: `sudo chown -R $USER ~/MY_PACKAGE_NAME` |
