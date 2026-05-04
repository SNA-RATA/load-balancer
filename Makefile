COMPOSE := docker compose

.PHONY: build up down restart ps logs logs-nginx logs-app curl-test

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) down
	$(COMPOSE) up --build -d

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=100

logs-nginx:
	$(COMPOSE) logs -f --tail=100 nginx

logs-app:
	$(COMPOSE) logs -f --tail=100 web1 web2 web3 web4 web5

curl-test:
	@$(COMPOSE) exec -T nginx sh -c 'for i in $$(seq 1 12); do wget -qO- http://127.0.0.1/; echo; done'
