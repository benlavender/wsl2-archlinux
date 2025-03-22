<h1 align="center">
   <img src="images/arch.png" width="300px" /> 
   <br>
      wsl2-archlinux
   <br>
</h1>

## Overview:

Arch Linux configuration files that I use to run on WSL2.

This is a Docker generated image that is built then exported to a tarball and then imported into WSL2.

## Usage:

1. Update the `configs\wsl.conf` file with the correct username and hostname:

```plaintext
#Example
[network]
hostname = "PRD-UXC001"

[user]
default = "ben"
```

2. Create the container image using Docker:

```batch
REM Set the %pass% variable as the desired password for the user specified in the --build-arg:
set pass=your_password
set user=user_name
docker build --tag wsl2arch --secret id=pass,env=pass --build-arg user=%user% .
```

2. Create the container from the image and then export to a tarball:

```batch
docker run --name wsl2arch wsl2arch
docker export --output="wsl2arch.tar" wsl2arch
```

3. Remove the container now it has been exported:

```batch
docker rm wsl2arch
```

4. Import the tarball into WSL2:

```batch
wsl --import Arch <"wsl_store"> <"wsl2arch.tar">
```