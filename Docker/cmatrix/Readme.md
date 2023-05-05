# Build Container Image

This Dockerfile builds a Docker image that runs the `cmatrix` program in a container. The `cmatrix` program is a terminal-based screensaver that displays the falling green characters as seen in the movie "The Matrix."

## Building the Image

To build the Docker image, run the following command in the same directory as the Dockerfile:


This will build the Docker image and tag it with the name `cmatrix`.

## Running the Container

To run the `cmatrix` program in a container, use the following command:


This command runs the `cmatrix` program inside a container based on the `cmatrix` Docker image.

## Customizing the Program

By default, the `cmatrix` program runs with the `-b` option, which displays the program in full-screen mode with the background color set to black. You can customize the program options by passing them as arguments to the `docker run` command.

For example, to run the program in windowed mode with a green background, use the following command:


This command runs the `cmatrix` program with the `-C green` and `-s` options, which set the background color to green and run the program in windowed mode.

# Best Practices in the Dockerfile

This Dockerfile follows several best practices for building efficient and lightweight Docker images:

- Using a minimal base image: The Dockerfile uses `alpine` as the base image, which is a lightweight Linux distribution that is optimized for running in containers.

- Minimizing the number of layers: The Dockerfile uses multi-stage builds to minimize the number of layers in the final image. This helps to reduce the image size and improve the build time.

- Using `WORKDIR` to set the working directory: The Dockerfile uses `WORKDIR` to set the working directory to `/cmatrix` for the `cmatrixbuilder` stage. This makes it easier to manage the build process and ensures that all subsequent commands are executed in the correct directory.

- Using `RUN` to execute commands: The Dockerfile uses `RUN` to execute commands that are needed to build the `cmatrix` program and install dependencies. This helps to ensure that all necessary steps are executed during the build process and that the final image is fully functional.

- Using `COPY` to copy files: The Dockerfile uses `COPY` to copy the `cmatrix` binary from the `cmatrixbuilder` stage to the final image. This ensures that only the necessary files are included in the final image and helps to reduce its size.

- Using `ENTRYPOINT` and `CMD` to specify the default command: The Dockerfile uses `ENTRYPOINT` to specify the default command to run when the container starts, which is `./cmatrix`. It also uses `CMD` to specify the default command-line arguments, which is `-b`. This helps to ensure that the `cmatrix` program is started automatically when the container is launched and that it runs with the appropriate options.

By following these best practices, the Dockerfile is optimized for building a lightweight and efficient Docker image that can run the `cmatrix` program in a container.

## Docker Hub Pull

docker pull unpluggedkk/cmatrix:latest

## Credits

This Dockerfile is based on the work of Abhishek V Ashok's [cmatrix repository on GitHub](https://github.com/abhishekvashok/cmatrix). If you have any questions or suggestions, please contact Kishore Kumar at <hello@kishorekumar.today>.
