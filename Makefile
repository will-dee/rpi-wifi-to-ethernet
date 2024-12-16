LOGIN_USER := pi
LOGIN_PASSWORD := blueberry

WIFI_SSID := "your-wifi-ssid"
WIFI_PASSWORD := "your-wifi-password"

all: output-raspbian_lite_64/image

.PHONY: clean

clean:
	rm -f root/boot/userconf.txt
	rm -rf output-raspbian_lite_64

./root/boot/userconf.txt:
	echo '$(LOGIN_PASSWORD)' | openssl passwd -6 -stdin | awk '{print "$(LOGIN_USER):"$$1}' > root/boot/userconf.txt

./output-raspbian_lite_64/image: root/boot/userconf.txt
	docker run \
	  --rm \
	  --privileged \
	  -e PACKER_CACHE_DIR=/build/packer_cache \
	  -v /dev:/dev \
	  -v ${PWD}:/build \
	  -v ${PWD}/packer_cache:/build/packer_cache \
	  -v ${PWD}/output-arm-image:/build/output-arm-image \
	  packer-plugin-arm-image:local \
	    build -var wifi_ssid=$(WIFI_SSID) -var wifi_password=$(WIFI_PASSWORD) rpi-wireless-ethernet.pkr.hcl
