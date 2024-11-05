# Hello world deb package

This example demonstrates how to create a simple "Hello, world!" application packaged as a `.deb` file. The project includes:

1. A Python script (`hello.py`) that prints "Hello, world!".
2. A Dockerfile and `docker-compose.yml` to containerize and manage the application.
3. A shell script (`create_deb.sh`) that packages the application files into a `.deb` file.

Upon installing the `.deb` package, a post-installation script runs `docker-compose` to build and execute the Docker container, printing "Hello, world!" via Docker logs. This example shows how to package and deploy a basic Dockerized app in a Debian-compatible format.

### Install the Package

Run the create-deb.sh script to rebuild the .deb package:
```bash
./create-deb.sh
```
To install and uninstall the `.deb` package for your Docker-based project, you can use the following commands:

### Installation

To install the `.deb` package, use the `dpkg` command:

```bash
sudo dpkg -i hello-world-docker_1.0.0_all.deb
```

This command will:
- Unpack and install your application files to `/usr/local/hello-world-docker`.
- Run the `postinst` script, which starts the Docker container using Docker Compose.

If you encounter any dependency issues during installation, you can resolve them by running:

```bash
sudo apt-get install -f
```

### Check Docker Logs

To verify the output, check the logs of the running container:
```bash
docker logs hello_world_container
```

This should display:
```bash
Hello, world!
```

### Uninstallation

To uninstall the package and stop the Docker container, you need to:
1. Stop and remove the Docker container manually if it’s still running.
2. Remove the `.deb` package and its installed files.

#### Step 1: Stop and Remove the Docker Container

Run this command to stop and remove the Docker container:

```bash
sudo docker-compose -f /usr/local/hello-world-docker/docker-compose.yml down
```

This command stops and removes the `hello_world_container` container, as well as any associated Docker resources (networks, etc.).

#### Step 2: Uninstall the Package

Then, to remove the `.deb` package and all files installed by it, use `dpkg -r`:

```bash
sudo dpkg -r hello-world-docker
```

### Cleanup After Uninstall

The `dpkg -r` command will:
- Remove the files installed by the package.
- Run any cleanup commands in the `postrm` script (if you define one).

If you'd like the package to automatically stop the Docker container during uninstallation, you can add a **`postrm` script** to your package structure.

### Adding a `postrm` Script to `create-deb.sh`

To add a `postrm` script that stops the Docker container during uninstallation, modify your `create-deb.sh` script as follows:

```bash
# Create a post-removal script to stop Docker container
cat <<EOF > ${PACKAGE_DIR}/DEBIAN/postrm
#!/bin/bash
# Stop and remove the Docker container on uninstall
docker-compose -f /usr/local/${PACKAGE_NAME}/docker-compose.yml down
EOF
chmod +x ${PACKAGE_DIR}/DEBIAN/postrm
```

This `postrm` script ensures the container is stopped and removed when you uninstall the package.