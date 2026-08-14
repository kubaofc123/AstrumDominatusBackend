# Setup

1. Download Godot 4.6 Standard from `https://godotengine.org/download/archive/4.6-stable/` and extract content to `engine` folder.

2. Download Standard export templates from `https://godotengine.org/download/archive/4.6-stable/` and extract content to `export_templates` folder.

Automation tasks are adapted for VSCode extension `Task Runner` by `Sana Ajani`.

To locally test client and server applications, variable `backend_address` in `main.tscn` in `Main` node client should be set to `127.0.0.1`. For public address you can use both ip address and domain name.
# Deployment requirements
1. `Docker` & `Docker Compose` installed on remote server
2. Open port as designated in `main.tscn` in `Main` node from variable `port` in the Setup category

# Deployment
This workflow uses Docker to prepare the server application.

1. Run VSCode task `Package Release` - produces `build/bin/AstrumDominatus.x86_64` and `astrum-dominatus-backend.tar`
2. If old docker container is running on remote server, needs to be stopped and removed with command `docker compose -f /path/to/docker-compose.yml down`.
3. If old docker image is loaded in running server, needs to be removed with `docker rmi astrum-dominatus-backend`.
4. `astrum-dominatus-backend.tar` file is being used to load as image into Docker, copy it into your remote server and run terminal command on the server with `docker image load -i ./astrum-dominatus-backend.tar`
5. Use command `docker compose -f /path/to/docker-compose.yml up -d` to start the image as container.