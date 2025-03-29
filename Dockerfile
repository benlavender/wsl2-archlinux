# Use latest Arch stable image:
FROM archlinux:latest

LABEL author="ben@benlavender.co.uk"
LABEL version="1.0"

# Create /etc/wsl.conf:
COPY configs/wsl.conf /etc
COPY configs/profile /etc

# Update and generate locale:
RUN sed -i '/#en_GB.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
RUN locale-gen
RUN echo "LANG=en_GB.UTF-8" > /etc/locale.conf

# Reinitialise the pacman keyring:
RUN pacman-key --init

# Run pacman update:
RUN pacman -Syu --noconfirm
RUN pacman -Fy

# Create the default user:
ARG user  
RUN useradd $user --create-home --shell /bin/bash --groups wheel
RUN --mount=type=secret,id=pass \
    PASSWORD=$(cat /run/secrets/pass) && \
    echo "$user:$PASSWORD" | chpasswd

# Install sudo:
RUN pacman -S sudo --noconfirm

# Update the /etc/sudoers file so the wheel group can run commands with no password:
RUN sed -i '/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^# *//' /etc/sudoers
RUN sed -i '/# %wheel ALL=(ALL:ALL) ALL/s/^# *//' /etc/sudoers

# Change root password:
RUN openssl passwd -salt 16 $(openssl rand -base64 24) | passwd --stdin root
    
# Change to the user for the rest of the commands:
USER $user

# Install custom packages for the image:
RUN sudo pacman -S \
    vi \
    traceroute \
    less \ 
    mtr \
    fastfetch \
    which \
    nmap \
    git \
    openssh \
    certbot \
    whois \ 
    bind \
    dmidecode \
    man-db \ 
    man-pages\
    tflint \
    azure-cli \
    rsync \
    --needed --noconfirm

# Change working directory to $user:
WORKDIR /home/$user

# Install azcopy:
RUN curl -L https://aka.ms/downloadazcopy-v10-linux --output azcopy.tar.gz
RUN sudo tar -zxvf azcopy.tar.gz --directory /usr/local/bin
RUN rm -f azcopy.tar.gz

# Install terraform-docs:
RUN curl -L https://github.com/terraform-docs/terraform-docs/releases/download/v0.19.0/terraform-docs-v0.19.0-linux-amd64.tar.gz --output terraform-docs-v0.19.0-linux-amd64.tar.gz
RUN sudo mkdir -p /usr/local/bin/terraform-docs
RUN sudo tar -zxvf terraform-docs-v0.19.0-linux-amd64.tar.gz --directory /usr/local/bin/terraform-docs
RUN rm -f terraform-docs-v0.19.0-linux-amd64.tar.gz

# Install Terraform:
RUN curl -L https://releases.hashicorp.com/terraform/1.11.2/terraform_1.11.2_linux_amd64.zip --output terraform_1.11.2_linux_amd64.zip
RUN sudo mkdir -p /usr/local/bin/terraform
RUN sudo bsdtar -xpf terraform_1.11.2_linux_amd64.zip -C /usr/local/bin/terraform
RUN rm -f terraform_1.11.2_linux_amd64.zip

# Update the /etc/sudoers file so the wheel group can run commands with password required:
RUN sudo sed -i '/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^/# /' /etc/sudoers

CMD [ "/bin/bash" ]