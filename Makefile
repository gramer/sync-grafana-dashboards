TAG="\n\n\033[0;32m\#\#\# "
END=" \#\#\# \033[0m\n"

DEV_GRAFANA_URL = http://dev-grafana.com
PROD_GRAFANA_URL = http://grafana.com
GRAFANA_TAG ?= sync

.PHONY: prerequisites
prerequisites:
	@brew install jq
	@npm install -g wizzy

define config_wizzy
	@wizzy set grafana envs $(1) url $(2)
	@read -p "[$(1): $(2)] Enter username in Grafana: " username; \
    	wizzy set grafana envs $(1) username $$username
	@read -sp "[$(1): $(2)] Enter password in Grafana: " password; \
    	wizzy set grafana envs $(1) password $$password
endef

define import_dashboards
	@wizzy set context grafana $(1)
	@curl -s '$(2)/api/search?tag=$(3)' \
		| jq -c '.[] | .uri' \
		| grep db \
		| sed 's/db\///g' \
		| xargs -I {} wizzy import dashboard {}

endef

define confirm_in_prod
	@read -p "${PROD_GRAFANA_URL}:에 대시보드가 업로드 됩니다. 진행하시겠습니까?? (y/n): " anwser; \
		if [[ $$anwser =~ ("y"|"Y") ]]; then echo ${TAG}"작업을 진행합니다."${END}; \
		else echo ${TAG}작업을 종료합니다.${END}; exit 1 ; fi
endef

.PHONY: init-wizzy
init-wizzy: ## init-wizzy
	@echo ${TAG}starting $@${END}
	@wizzy init
	$(call config_wizzy,qa,${DEV_GRAFANA_URL})
	$(call config_wizzy,prod,${PROD_GRAFANA_URL})

	@echo ${TAG}completed${END}

.PHONY: clean-dashboards
clean-dashboards: ## clean dashboards
	@echo ${TAG}starting $@${END}
	@rm -rf dashboards/*
	@echo ${TAG}completed${END}

.PHONY: import-from-qa
import-from-qa: clean-dashboards ## download dashboards from qa
	@echo ${TAG}starting $@${END}
	$(call import_dashboards,qa,${DEV_GRAFANA_URL},${GRAFANA_TAG})
	@echo ${TAG}completed${END}

.PHONY: export-to-qa
export-to-qa:  ## export-to-qa
	@echo ${TAG}starting $@${END}
	@wizzy set context grafana qa
	@wizzy export dashboards
	@echo ${TAG}completed${END}

.PHONY: transform-notification
transform-notification: ## transform-notification by sed
	@echo ${TAG}starting $@${END}
	@find ./dashboards -name "*.json" | xargs -I {} sed -i '' -e  's/R14B9aO7k/VfR-SwPWk/g' {}
	@find ./dashboards -name "*.json" | xargs -I {} sed -i '' -e  's/PRMWx1hnz/9eiA-X27z/g' {}
	@echo ${TAG}completed${END}

.PHONY: import-from-prod
import-from-prod: clean-dashboards ## Download dashboards from prod
	@echo ${TAG}starting $@${END}
	$(call import_dashboards,prod,${PROD_GRAFANA_URL},${GRAFANA_TAG})
	@echo ${TAG}completed${END}

.PHONY: export-to-prod
export-to-prod:  ## export-to-prod
	$(call confirm_in_prod)
	@echo ${TAG}starting $@${END}
	@wizzy set context grafana prod
	@wizzy export dashboards
	@echo ${TAG}completed${END}

.PHONY: sync
sync: import-from-qa transform-notification export-to-prod ## sync
	@echo ${TAG}starting $@${END}
	@echo ${TAG}completed${END}

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.DEFAULT_GOAL = help
