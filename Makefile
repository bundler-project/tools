all: iperf/src/iperf \
	empirical-traffic-gen/bin/etgClient empirical-traffic-gen/bin/etgServer \
	bundler/target/debug/inbox bundler/target/debug/outbox \
	nimbus/target/debug/nimbus

iperf/src/iperf: iperf/src/*.c
	cd iperf && ./autogen.sh && ./configure
	make -C iperf

empirical-traffic-gen/bin/etgClient empirical-traffic-gen/bin/etgServer: empirical-traffic-gen/src/*.c
	make -C empirical-traffic-gen

rustup.sh:
	curl https://sh.rustup.rs -sSf > rustup.sh

~/.cargo/bin/cargo: rustup.sh
	sh rustup.sh -y --default-toolchain=nightly

bundler/target/debug/inbox bundler/target/debug/outbox: ~/.cargo/bin/cargo
	sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y \
		libtool automake autoconf \
		libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnfnetlink-dev \
		bison flex libpcap-dev
	cd bundler && ~/.cargo/bin/cargo build

nimbus/target/debug/nimbus: ~/.cargo/bin/cargo
	cd nimbus && ~/.cargo/bin/cargo build
