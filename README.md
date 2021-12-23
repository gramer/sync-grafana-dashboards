# Sync Dashboards

이 프로젝트는 QA Zone 에 있는 대시보드를 Production 에 쉽게 적용하기 위한 기능을 제공합니다.

- QA,Prod 에 있는 대시보드를 태그로 필터하여 로컬에 다운 받을 수 있습니다.
- Notification 를 Production 기준으로 변환할 수 있습니다.
- 로컬에 있는 대시보드를 QA, Prod 에 저장합니다.

## Getting Started

### Prerequisites

로컬 환경에 wizzy, jq 가 없다면 아래의 명령어를 실행하세요

```shell
make prerequisites
```

### wizzy 초기 설정

wizzy 는 Grafana 의 인증 기반으로 실행합니다. 따라서 아래의 명령어를 통해서 설정 정보를 초기화 할 수 있습니다. 관련 정보는 기밀 정보이므로, Git 을 통해서 관리하지 않도록 합니다.

```shell
❯ make init-wizzy


### starting init-wizzy ###

✔ conf directory already exists.
✔ conf file already exists.
✔ wizzy successfully initialized.
✔ grafana:envs:qa:url updated successfully.
✔ conf file saved.
[qa: http://qa-grafana.kakaopayinvest.com] Enter username in Grafana: zeno.kim
✔ grafana:envs:qa:username updated successfully.
✔ conf file saved.
[qa: http://qa-grafana.kakaopayinvest.com] Enter password in Grafana: ✔ grafana:envs:qa:password updated successfully.
✔ conf file saved.
✔ grafana:envs:prod:url updated successfully.
✔ conf file saved.
[prod: http://grafana.kakaopayinvest.com] Enter username in Grafana: zeno.kim
✔ grafana:envs:prod:username updated successfully.
✔ conf file saved.
[prod: http://grafana.kakaopayinvest.com] Enter password in Grafana: ✔ grafana:envs:prod:password updated successfully.
✔ conf file saved.


### completed ###
```

### 동기화 실행

sync 명령어를 통해서 QA 그라파나의 sync 태그가 달려 있는 대시보드를 Production 에 반영합니다.

```shell 
make sync
```

### 수동 작업

- 대시보드를 다운 받아 수동으로 작업을 한 후에 일괄 업데이트를 할 수 있습니다.

```shell
# QA 대시보드를 다운 받은 후에 수정 후 다시 QA 대시보드를 업로드 한다.
make import-from-qa
... 일괄작업 후

make export-to-qa
```

## Acknowledgments

* grafana 인증을 한 사용자는 export 시에 grafana version history 에 기록됩니다.
* 동기화 대상이 되는 대시보드에 누군가 작업을 하게 되면 동기화 작업은 실패합니다.

## Issues

* jenkins 등을 통해 linux 환경에서 실행 시에는 sed option 을 변경해줘야 한다.

## References

- [wizzy github](https://github.com/grafana-wizzy/wizzy)
- [wizzy doc](https://grafana-wizzy.com/home/)
