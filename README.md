# RPi WiFi to Ethernet

The story of the Pi that saved Christmas. Well, not really but I was
prompted to put this little project together in response to my brother
saying that his laptop's lack of functional WiFi might keep him at uni
for more of the Christmas break.

This repository contains automation to minimally configure a Debian 11
derived Raspbian image as a WiFi to Ethernet adapter, providing a NAT
network with DHCP and DNS accessible over Ethernet, forwarding packets
over WiFi to provide access to the internet. This image can then be
flashed to a uSD card and run in a Raspberry Pi single board computer.

## How to build

### Toolbox

To build a disk image of your own, you will need the following tools:

- GNU Make (`make`)
- OpenSSL (`openssl`)
- `awk`
- Docker (`docker`)

You should install these to your system in whichever way works best for
you.

In addition, you will need a copy of the [solo-io packer-plugin-arm-image](https://github.com/solo-io/packer-plugin-arm-image)
Docker image. If you are on an `amd64/linux` machine then you can pull
the upstream image:

```
# Pull the upstream image
docker pull ghcr.io/solo-io/packer-plugin-arm-image

# re-tag it so that it can be used from the Makefile
docker tag ghcr.io/solo-io/packer-plugin-arm-image packer-plugin-arm-image:local
```

Otherwise you will need to build it yourself. As it is a Golang project
it should build nicely on most architectures:

```
# Clone solo-io repo and enter
git clone https://github.com/solo-io/packer-plugin-arm-image
cd packer-plugin-arm-image

# Build the image
docker build -t packer-plugin-arm-image:local .
```

### Building the image

To build the image, first substitute the WiFi credential variables in
the Makefile with the real credentials for your WiFi network:

```
WIFI_SSID := "your-wifi-ssid"
WIFI_PASSWORD := "your-wifi-password"
```

Then run `make`.

After this, you should end up with a file at `./output-raspbian_lite_64/image`

## How to use

After you have built an image, you need to flash it to a uSD card to
use it. The card should be at least 4 Gigs in size. You can use whatever
method you like (e.g. [Balena Etcher](https://etcher.balena.io/)) but for
people who prefer the CLI, you can do the following:

```
# On my Mac
sudo diskutil unmountDisk /dev/rdisk5
sudo /bin/dd if=./output-raspbian_lite_64/image of=/dev/rdisk5 bs=1M status=progress
```

It should then be possible to plug in power to the Pi, and an Ethernet
cable from the Pi's ethernet jack to the device you wish to connect to
the WiFi. After a short while your device should get assigned an address
in the `192.168.123.1/24` range. It may take a couple of minutes for the
WiFi connection to be established and provide onward connectivity to the
internet.

From the device connected by Ethernet, you can SSH into the Pi and see
what is going on:

```
# Password: blueberry
ssh pi@192.168.123.1
```

There is a `getty` process running on the HDMI output of the Pi so you
can also plug in a screen and keyboard.