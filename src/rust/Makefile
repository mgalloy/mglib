.PHONY: all header clean

OPTIONS=-A dead_code -A non_camel_case_types -A non_snake_case --crate-type dylib

all: mg_rust_example.so

mg_rust_example.so: mg_rust_example.rs
	rustc $(OPTIONS) -L /Applications/exelis/idl/bin/bin.darwin.x86_64/ mg_rust_example.rs -o mg_rust_example.so

header:
	make_rust_header.sh

clean:
	rm -f mg_rust_example.so
