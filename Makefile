include .env.test
DOCKER_COMPOSE = docker compose --env-file .env.test

help:
	@grep "^[a-zA-Z][a-zA-Z0-9\-\/\_]*:" -o Makefile | grep -v "grep" | sed -e 's/^/make /' | sed -e 's/://'
build:
	$(DOCKER_COMPOSE) build
up:
	$(DOCKER_COMPOSE) up -d
down:
	$(DOCKER_COMPOSE) stop
restart:
	$(MAKE) down
	$(MAKE) up
ps:
	$(DOCKER_COMPOSE) ps
convert:
	$(DOCKER_COMPOSE) convert
setup: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bin/setup'
	$(MAKE) mysql/drop_db
	$(MAKE) mysql/create_db
	$(DOCKER_COMPOSE) exec ruby bash -c './scripts/migrate.sh'
mysql/create_db:
	@$(DOCKER_COMPOSE) exec -e MYSQL_PWD=${DB_PASSWORD} mysql mysql -u ${DB_USER} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql/drop_db:
	@$(DOCKER_COMPOSE) exec -e MYSQL_PWD=${DB_PASSWORD} mysql mysql -u ${DB_USER} -e "DROP DATABASE IF EXISTS ${DB_NAME}"
bundle/install: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bundle install'
ruby/bash: up
	$(DOCKER_COMPOSE) exec ruby bash
ruby/rspec: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bundle exec rspec'
ruby/appraisal/generate: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bundle exec appraisal generate'
gem/release:
	@read -p "Enter OTP code: " otp_code; \
	gh workflow run release.yml -f rubygems-otp-code="$$otp_code"
console: up
	$(DOCKER_COMPOSE) exec ruby bash -c './bin/console'
sig/typeprof: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bundle exec typeprof lib/**/*.rb spec/**/*_spec.rb -o sig_generated/master_data_tool.rbs'
sig/subtract: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bundle exec rbs subtract sig_generated/master_data_tool.rbs sig/master_data_tool.rbs > sig_generated/master_data_tool_diff.rbs'
