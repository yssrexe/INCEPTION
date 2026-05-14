COMPOSE = docker compose
COMPOSE_FILE = srcs/docker-compose.yml


all: build up

build: setup
	$(COMPOSE) -f $(COMPOSE_FILE) build

up:
	$(COMPOSE) -f $(COMPOSE_FILE) up -d

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

restart: down up

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs

clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down -v

fclean: clean
	docker system prune -af

fcleanall : fclean
	sudo rm -rf /home/yael-yas/data/wordpress/* /home/yael-yas/data/mariadb/*

re: fcleanall all

setup:
	@mkdir -p /home/yael-yas/data/wordpress
	@mkdir -p /home/yael-yas/data/mariadb

.PHONY: all build up down restart logs clean fclean fcleanall re setup
