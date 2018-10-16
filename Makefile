.PHONY: build test

build:
	luarocks make

test: build
	eval "$$(luarocks path)" && lua test/test.lua

