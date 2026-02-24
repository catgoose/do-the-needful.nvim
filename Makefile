SCRIPTS_DIR=scripts
TEST_SCRIPT=$(SCRIPTS_DIR)/run_tests.sh
DOCS_SCRIPT=$(SCRIPTS_DIR)/gen_docs.sh

help:
	@echo "Available targets:"
	@echo "  make test              - Run all mini.test tests"
	@echo "  make test-file FILE=f  - Run a single test file"
	@echo "  make docs              - Generate vimdoc and HTML docs"
	@echo "  make clean             - Remove deps/"

test:
	@echo "Running tests..."
	@bash $(TEST_SCRIPT)

test-file:
	@echo "Running test file: $(FILE)"
	@bash $(TEST_SCRIPT) $(FILE)

docs:
	@echo "Generating docs..."
	@bash $(DOCS_SCRIPT)

clean:
	@echo "Removing deps/"
	@rm -rf deps/

.PHONY: help test test-file docs clean
