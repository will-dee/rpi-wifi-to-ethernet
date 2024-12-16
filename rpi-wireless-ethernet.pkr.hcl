source "arm-image" "raspbian_lite_64" {
  iso_checksum = "45dd65d579ec2b106a1e3181032144406eab61df892fcd2da8d83382fa4f7e51"
  iso_url      = "https://downloads.raspberrypi.com/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2024-10-28/2024-10-22-raspios-bullseye-armhf-lite.img.xz"
}

variable "wifi_ssid" {
  type =  string
}

variable "wifi_password" {
  type =  string
  sensitive = true
}

build {
  sources = ["source.arm-image.raspbian_lite_64"]

  # Ensure the package registry is up to date
  provisioner "shell" {
    inline = ["apt update"]
  }

  # Install required tools
  provisioner "shell" {
    inline = [
        "apt install -y iproute2 dnsmasq vim jq"
    ]
  }

  # Copy over tree of extra files that customise the base OS
  provisioner "file" {
    source = "./root/"
    destination = "/"
  }

  # Substitute the wifi credentials from the packer vars in the /boot/wifi file
  provisioner "shell" {
    inline = [
        "sed -i 's/your-network-name/${var.wifi_ssid}/' /boot/wpa_supplicant.conf",
        "sed -i 's/your-network-password/${var.wifi_password}/' /boot/wpa_supplicant.conf"
    ]
  }

  # Set file permissions
  provisioner "shell" {
    inline = [
        "chmod 644 /opt/setup-net/setup-net.service",
        "chmod 744 /opt/setup-net/bin/*",
        "chmod 644 /opt/establish-nat/establish-nat.service",
        "chmod 744 /opt/establish-nat/bin/*",
        "chmod 644 /opt/dnsmasq-dhcp/dnsmasq-dhcp.service",
        "chmod 744 /opt/dnsmasq-dhcp/bin/*",
    ]
  }

  # Enable systemd services so they start on boot
  provisioner "shell" {
    inline = [
        # Enable SSH
        "systemctl enable ssh.service",

        # Disable default dnsmasq service
        "systemctl mask dnsmasq.service",

        # Link and enable our systemd services
        "systemctl link /opt/setup-net/setup-net.service",
        "systemctl enable setup-net.service",
        "systemctl link /opt/establish-nat/establish-nat.service",
        "systemctl enable establish-nat.service",
        "systemctl link /opt/dnsmasq-dhcp/dnsmasq-dhcp.service",
        "systemctl enable dnsmasq-dhcp.service",
    ]
  }
}