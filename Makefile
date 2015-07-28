APP_FILES=$(shell find . -type f -name '*.lua')

statsd: lit luvit $(APP_FILES)
	./lit make

test: luvit $(APP_FILES)
	./lit install
	./luvit tests/main.lua

clean:
	rm -rf statsd lit lit-* luvi deps

luvit: lit
	./lit make luvit/luvit

lit:
	curl -L https://github.com/luvit/lit/raw/2.1.8/get-lit.sh | sh

install: statsd lit
	install statsd /usr/local/bin

uninstall:
	rm -f /usr/local/bin/statsd

lint:
	find . -name "*.lua" | xargs luacheck

.PHONY: uninstall install lint
