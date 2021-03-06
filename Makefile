all: iperf/src/iperf \
	bundler/target/debug/inbox bundler/target/debug/outbox \
	nimbus/target/debug/nimbus \
	udping/target/debug/udping_server udping/target/debug/udping_client \

iperf/src/iperf: iperf/src/*.c
	cd iperf && ./autogen.sh && ./configure
	make -C iperf

empirical-traffic-gen/bin/etgClient empirical-traffic-gen/bin/etgServer: empirical-traffic-gen/src/*.c
	make -C empirical-traffic-gen

rustup.sh:
	curl https://sh.rustup.rs -sSf > rustup.sh

~/.cargo/bin/cargo: rustup.sh
	sh rustup.sh -y --default-toolchain=nightly

bundler/target/debug/inbox bundler/target/debug/outbox: ~/.cargo/bin/cargo $(shell find bundler/src -name "*.rs")
	sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y \
		libtool automake autoconf \
		llvm llvm-dev clang libclang-dev \
		libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnfnetlink-dev \
		libdb-dev \
		bison flex libpcap-dev
	cd bundler && ~/.cargo/bin/cargo build

nimbus/target/debug/nimbus: ~/.cargo/bin/cargo nimbus/src/lib.rs
	cd nimbus && ~/.cargo/bin/cargo build

mahimahi/src/frontend/mm-delay mahimahi/src/frontend/mm-link: $(shell find mahimahi -name "*.cc")
	sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y \
		protobuf-compiler libprotobuf-dev autotools-dev dh-autoreconf \
		iptables pkg-config dnsmasq-base apache2-bin apache2-dev \
		debhelper libssl-dev ssl-cert libxcb-present-dev libcairo2-dev libpango1.0-dev
	cd mahimahi && ./autogen.sh && ./configure
	cd mahimahi && make -j && sudo make install

udping/target/debug/udping_server udping/target/debug/udping_client: ~/.cargo/bin/cargo $(shell find udping/src -name "*.rs")
	cd udping && ~/.cargo/bin/cargo build

ccp_copa/target/debug/copa: ~/.cargo/bin/cargo $(shell find ccp_copa/src -name "*.rs")
	cd ccp_copa && ~/.cargo/bin/cargo build
