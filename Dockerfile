# Use latest Arch stable image:
FROM archlinux:latest

LABEL author="ben@benlavender.co.uk"
LABEL version="1.0"

# Create /etc/wsl.conf:
COPY configs/wsl.conf /etc
COPY configs/profile /etc

# Reinitialise the pacman keyring:
RUN pacman-key --init

# Run pacman update:
RUN pacman -Syu --noconfirm
RUN pacman -Fy

# Create the default user:
# RUN --mount=type=secret,id=my_env source /run/secrets/my_env
# RUN useradd ben --create-home --shell /bin/bash --groups wheel #--password $MY_SECRET
# RUN echo $MY_SECRET > /home/ben/password

# Install sudo:
RUN pacman -S sudo --noconfirm

# Update the /etc/sudoers file so the wheel group can run commands with no password:
RUN sed -i '/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^# *//' /etc/sudoers

# Change root password:
RUN openssl passwd -salt 16 $(openssl rand -base64 24) | passwd --stdin root
    
# Change to the user for the rest of the commands:
USER ben

# Install custom packages for the image:
RUN sudo pacman -S vi azure-cli traceroute less mtr fastfetch which terraform nmap git openssh certbot whois tflint bind dmidecode man-db --needed --noconfirm

WORKDIR /home/ben

# Install azcopy:
RUN curl -L https://aka.ms/downloadazcopy-v10-linux --output azcopy.tar.gz
RUN sudo tar -zxvf azcopy.tar.gz --directory /usr/local/bin
RUN rm -f azcopy.tar.gz

# Install terraform-docs:
RUN curl -L https://github.com/terraform-docs/terraform-docs/releases/download/v0.19.0/terraform-docs-v0.19.0-linux-amd64.tar.gz --output terraform-docs-v0.19.0-linux-amd64.tar.gz
RUN sudo mkdir -p /usr/local/bin/terraform-docs
RUN sudo tar -zxvf terraform-docs-v0.19.0-linux-amd64.tar.gz --directory /usr/local/bin/terraform-docs
RUN rm -f terraform-docs-v0.19.0-linux-amd64.tar.gz

# Update the /etc/sudoers file so the wheel group can run commands with password required:
RUN sudo sed -i '/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^/# /' /etc/sudoers

CMD [ "/bin/bash" ]