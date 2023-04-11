##@ [Application: QA]

.PHONY: test
test: ## Run the test suite
	$(EXECUTE_IN_WORKER_CONTAINER) vendor/bin/phpunit -c phpunit.xml

# vendor/bin/phpstan analyse app tests --level=9
PHPSTAN_CMD=php vendor/bin/phpstan analyse
PHPSTAN_ARGS=--level=9
PHPSTAN_FILES=$(APP_FILES) $(TEST_FILES)

.PHONY: phpstan
#phpstan:  ## Run static analyzer on all application and test files
#	$(EXECUTE_IN_APPLICATION_CONTAINER) $(PHPSTAN_CMD) $(PHPSTAN_ARGS) $(PHPSTAN_FILES)
phpstan: ## Run static analyzer on all application and test files
	@$(call execute,$(PHPSTAN_CMD),$(PHPSTAN_ARGS),$(PHPSTAN_FILES),$(ARGS))

PHPUNIT_CMD=php vendor/bin/phpunit
PHPUNIT_ARGS= -c phpunit.xml
PHPUNIT_FILES=

PHPCS_CMD=php vendor/bin/phpcs
PHPCS_ARGS=--parallel=$(CORES) --standard=psr12
PHPCS_FILES=$(APP_FILES)

PHPCBF_CMD=php vendor/bin/phpcbf
PHPCBF_ARGS=$(PHPCS_ARGS)
PHPCBF_FILES=$(PHPCS_FILES)

# vendor/bin/parallel-lint -j 4 --exclude .git --exclude vendor ./
PARALLEL_LINT_CMD=php vendor/bin/parallel-lint
PARALLEL_LINT_ARGS=-j 4 --exclude vendor/ --exclude .docker --exclude .git
PARALLEL_LINT_FILES=$(ALL_FILES)

# vendor/bin/composer-require-checker check
COMPOSER_REQUIRE_CHECKER_CMD=php vendor/bin/composer-require-checker
COMPOSER_REQUIRE_CHECKER_ARGS=--ignore-parse-errors

# Used to run all components
# variables
CORES?=$(shell (nproc  || sysctl -n hw.ncpu) 2> /dev/null)

.PHONY: qa
qa: ## Run code quality tools on all files
	@"$(MAKE)" -j $(CORES) -k --no-print-directory --output-sync=target qa-exec NO_PROGRESS=true

.PHONY: qa-exec
qa-exec: phpstan \
    phplint \
    composer-require-checker \
    phpcs

# Use for smaller log outputs from QA commands
# For Example:
# .PHONY: phpstan
# phpstan: ## Run static analyzer on all application and test files
#    $(call execute,$(PHPSTAN_CMD),$(PHPSTAN_ARGS),$(PHPSTAN_FILES),$(ARGS))

# call with NO_PROGRESS=true to hide tool progress (makes sense when invoking multiple tools together)
# e.g make phpstan NO_PROGRESS=true
NO_PROGRESS?=false
ifeq ($(NO_PROGRESS),true)
    PHPSTAN_ARGS+= --no-progress
endif

## bash colors
RED:=\033[0;31m
GREEN:=\033[0;32m
YELLOW:=\033[0;33m
NO_COLOR:=\033[0m

# ...

# Use NO_PROGRESS=false when running individual tools.
# On  NO_PROGRESS=true  the corresponding tool has no output on success
#                       apart from its runtime but it will still print
#                       any errors that occured.
define execute
    if [ "$(NO_PROGRESS)" = "false" ]; then \
        eval "$(EXECUTE_IN_APPLICATION_CONTAINER) $(1) $(2) $(3) $(4)"; \
    else \
        START=$$(date +%s); \
        printf "%-35s" "$@"; \
        if OUTPUT=$$(eval "$(EXECUTE_IN_APPLICATION_CONTAINER) $(1) $(2) $(3) $(4)" 2>&1); then \
            printf " $(GREEN)%-6s$(NO_COLOR)" "done"; \
            END=$$(date +%s); \
            RUNTIME=$$((END-START)) ;\
            printf " took $(YELLOW)$${RUNTIME}s$(NO_COLOR)\n"; \
        else \
            printf " $(RED)%-6s$(NO_COLOR)" "fail"; \
            END=$$(date +%s); \
            RUNTIME=$$((END-START)) ;\
            printf " took $(YELLOW)$${RUNTIME}s$(NO_COLOR)\n"; \
            echo "$$OUTPUT"; \
            printf "\n"; \
            exit 1; \
        fi; \
    fi
endef