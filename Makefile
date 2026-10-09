FPC ?= fpc
FPCFLAGS ?=
UNITFLAGS = -Fu./src -Fi./src -Fi./tests -FU./build -FE./build -Sew -vewnhibq
TESTFLAGS = -gl -gh -Cr -Co -Ci -Sa

.PHONY: check generated test integration examples live clean

check: generated test integration examples

generated:
	python3 scripts/generate.py --check
	python3 scripts/check_contract.py

build:
	mkdir -p build

build/sdk_tests: src/*.pas src/*.inc tests/sdk_tests.pas tests/operations.inc | build
	$(FPC) $(FPCFLAGS) $(UNITFLAGS) $(TESTFLAGS) tests/sdk_tests.pas

test: build/sdk_tests
	./build/sdk_tests

build/http_tests: src/*.pas src/*.inc tests/http_tests.pas | build
	$(FPC) $(FPCFLAGS) $(UNITFLAGS) $(TESTFLAGS) tests/http_tests.pas

integration: build/http_tests
	python3 tests/http_server.py ./build/http_tests

examples: | build
	$(FPC) $(FPCFLAGS) $(UNITFLAGS) -O2 examples/workflow.pas
	$(FPC) $(FPCFLAGS) $(UNITFLAGS) -O2 examples/oauth_connect.pas

build/live_tests: src/*.pas src/*.inc tests/live_tests.pas | build
	$(FPC) $(FPCFLAGS) $(UNITFLAGS) $(TESTFLAGS) tests/live_tests.pas

live: build/live_tests
	./build/live_tests

clean:
	rm -rf build
