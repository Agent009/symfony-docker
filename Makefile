# @$(eval c ?=)
# @: Suppresses the command from being echoed in the output when it's executed.
# $(eval ...): GNU Make function that evaluates the expression inside it and assigns its result to the defined variable.
# 	?= 		Conditional variable assignment operator. "Assign the value if the variable is not already set".
#		? 	Built-in variable in Make that represents the first word of the command line. In this context, c is assigned
# 			the value of the first word of the command line if it's not already set.
#			This allows you to pass additional parameters to the composer target.
# @$(COMPOSER) $(c): Executes the Composer command. $(c) is the value assigned to c in the previous line, which could be
#	additional parameters or flags passed to Composer.

# Executables (local)
DOCKER_COMP = docker compose

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP) bin/console

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build up start down logs sh composer vendor sf cc test

## —— 🎵 🐳 The Symfony Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: create_env_file do-up ## Start the docker hub in detached mode (no logs)

do-up:
	@$(eval env ?= prod)
	@if [ "$(env)" = "prod" ]; \
	then \
    	$(DOCKER_COMP) -f compose.prod.yaml --env-file ./.env --env-file ./.env.$(env) --env-file ./.env.$(env).local --env-file ./.env.local up --detach; \
    else \
    	$(DOCKER_COMP) --env-file ./.env --env-file ./.env.$(env) --env-file ./.env.$(env).local --env-file ./.env.local up --detach; \
    fi

create_env_file:
	@$(eval env ?= prod)
	@if [ ! -f ./.env ]; then \
		@touch ./.env; \
		echo "Created .env"; \
	fi;
	@if [ ! -f ./.env.local ]; then \
		@touch ./.env.local; \
		echo "Created .env.local"; \
	fi;
	@if [ ! -f ./.env.$(env) ]; then \
		@touch ./.env.$(env); \
		echo "Created .env.$(env)"; \
	fi;
	@if [ ! -f ./.env.$(env).local ]; then \
		@touch ./.env.$(env); \
		echo "Created .env.$(env).local"; \
	fi;

start: build up ## Build and start the containers

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

sh: ## Connect to the FrankenPHP container
	@$(PHP_CONT) sh

bash: ## Connect to the FrankenPHP container via bash so up and down arrows go to previous commands
	@$(PHP_CONT) bash

test: ## Start tests with phpunit, pass the parameter "c=" to add options to phpunit, example: make test c="--group e2e --stop-on-failure"
	@$(eval c ?=)
	@$(DOCKER_COMP) exec -e APP_ENV=test php bin/phpunit $(c)


## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(SYMFONY) $(c)

cc: c=c:c ## Clear the cache
cc: sf
