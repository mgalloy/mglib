IDL=idl

.PHONY: all clean

all:
	cd introspection; make IDL=$(IDL)
	cd analysis; make IDL=$(IDL)

clean:
	cd introspection; make clean
	cd analysis; make clean
	cd strings; make clean
