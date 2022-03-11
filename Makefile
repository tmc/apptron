ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SRC_FILES := $(shell find lib/hostbridge/src -name "*.rs") 

debug-ffi: lib/libhostbridge.a cmd/debug/main_ffi.go bridge/**/*.go
	CGO_LDFLAGS="./lib/libhostbridge.a -ldl -framework Carbon -framework Cocoa -framework CoreFoundation -framework CoreVideo -framework IOKit -framework WebKit" \
	go build -tags ffi -a -o ./debug-ffi ./cmd/debug

debug-rpc: lib/libhostbridge.a cmd/debug/main_rpc.go bridge/**/*.go client/*.go
	CGO_LDFLAGS="./lib/libhostbridge.a -ldl -framework Carbon -framework Cocoa -framework CoreFoundation -framework CoreVideo -framework IOKit -framework WebKit" \
	go build -tags rpc -a -o ./debug-rpc ./cmd/debug

debug-cmd: hostbridge cmd/debug/main_cmd.go bridge/**/*.go client/*.go
	go build -tags cmd -o ./debug-cmd ./cmd/debug

hostbridge: lib/libhostbridge.a
	CGO_LDFLAGS="./lib/libhostbridge.a -ldl -framework Carbon -framework Cocoa -framework CoreFoundation -framework CoreVideo -framework IOKit -framework WebKit" \
	go build -a -o ./hostbridge ./cmd/hostbridge/main.go

lib/libhostbridge.a: $(SRC_FILES) lib/hostbridge/Cargo.toml
	cd lib/hostbridge && rustup run nightly cargo build --release
	cp lib/hostbridge/target/release/libhostbridge.a lib/

.PHONY: clean
clean:
	rm -rf ./debug-ffi ./debug-rpc ./debug-cmd ./hostbridge ./lib/libhostbridge.a ./lib/hostbridge/target
