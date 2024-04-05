##################
# Variables
##################

  DOCKER_COMPOSE = docker compose -f ./docker-compose.yml
  DOCKER_COMPOSE_PHP_FPM_EXEC = ${DOCKER_COMPOSE} exec -u www-data php-fpm

  SYMFONY       = $(DOCKER_COMPOSE_PHP_FPM_EXEC) bin/console

  PHPUNIT       = ./vendor/bin/phpunit
  PHPSTAN       = ./vendor/bin/phpstan
  PHP_CS_FIXER  = ./vendor/bin/php-cs-fixer
  PHPMETRICS    = ./vendor/bin/phpmetrics

##################
# Docker compose
##################

dc_build:
  ${DOCKER_COMPOSE} build

dc_start:
  ${DOCKER_COMPOSE} start

dc_stop:
  ${DOCKER_COMPOSE} stop

dc_up:
  ${DOCKER_COMPOSE} up -d --remove-orphans

dc_down:
  ${DOCKER_COMPOSE} down -v --rmi=all --remove-orphans

dc_ps:
  ${DOCKER_COMPOSE} ps

dc_logs:
  ${DOCKER_COMPOSE} logs -f

restart: dc_stop dc_start
rebuild: dc_down dc_build dc_up


app_bash:
  ${DOCKER_COMPOSE_PHP_FPM_EXEC} bash
php: app_bash

app_composer_install:
  ${DOCKER_COMPOSE_PHP_FPM_EXEC} composer install --no-progress --prefer-dist --optimize-autoloader

app_composer_update:
  ${DOCKER_COMPOSE_PHP_FPM_EXEC} composer update


app_build: dc_build dc_up app_composer_install diff migrate
app_down: db_drop  dc_down

##################
# Database
##################

db_migrate:
  ${SYMFONY} doctrine:migrations:migrate --no-interaction
migrate: db_migrate

db_diff:
  ${SYMFONY} doctrine:migrations:diff --no-interaction
diff: db_diff

db_schema_validate:
  ${SYMFONY} doctrine:schema:validate

db_migration_down:
  ${SYMFONY} doctrine:migrations:execute "App\Shared\Infrastructure\Database\Migrations\Version********" --down --dry-run

db_drop:
  ${SYMFONY} doctrine:schema:drop --force


##################
# Cache
##################

cache_clear:
  ${SYMFONY} cache:clear
  ${SYMFONY} cache:clear --env=test

cache_warmup:
  ${SYMFONY} cache:warmup

cache_fix_perm:
  @chmod -R 777 var/*

cache_purge:
  @rm -rf var/cache/* var/logs/*

