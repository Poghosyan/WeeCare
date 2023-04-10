##@ [Application: QA]

.PHONY: test
test: ## Run the test suite
	$(EXECUTE_IN_WORKER_CONTAINER) vendor/bin/phpunit -c phpunit.xml


PHPSTAN_CMD=php vendor/bin/phpstan analyse
PHPSTAN_ARGS=--level=9
PHPSTAN_FILES=$(APP_FILES) $(TEST_FILES)

.PHONY: phpstan
phpstan:  ## Run static analyzer on all application and test files
	$(EXECUTE_IN_APPLICATION_CONTAINER) $(PHPSTAN_CMD) $(PHPSTAN_ARGS) $(PHPSTAN_FILES)





# Use for smaller log outputs from QA commands
# For Example:
# .PHONY: phpstan
# phpstan: ## Run static analyzer on all application and test files
#    @$(call execute,$(PHPSTAN_CMD),$(PHPSTAN_ARGS),$(PHPSTAN_FILES),$(ARGS))

# call with NO_PROGRESS=true to hide tool progress (makes sense when invoking multiple tools together)
NO_PROGRESS?=false
ifeq ($(NO_PROGRESS),true)
    PHPSTAN_ARGS+= --no-progress
endif


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
            printf " %-6s" "done"; \
            END=$$(date +%s); \
            RUNTIME=$$((END-START)) ;\
            printf " took $${RUNTIME}s\n"; \
        else \
            printf " %-6s" "fail"; \
            END=$$(date +%s); \
            RUNTIME=$$((END-START)) ;\
            printf " took $${RUNTIME}s\n"; \
            echo "$$OUTPUT"; \
            printf "\n"; \
            exit 1; \
        fi; \
    fi
endef