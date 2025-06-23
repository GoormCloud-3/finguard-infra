# FinGuard-Infra

## CI/CD 파이프라인
본 프로젝트는 **커밋 전에 코드 린팅을 자동으로 수행**하도록 `pre-commit` 훅을 사용합니다.  
개발자는 로컬에 pre-commit 환경을 반드시 구성해야 하며, 미구성 시 커밋이 차단될 수 있습니다.

## 개발 환경
 - Terraform 1.11.4
 - Python 3.12.3

## (필독) 개발 환경 세팅

1. python 가상 환경 설정

```bash
$ python -m venv .venv
```

파이썬 가상환경을 설정합니다. 이는 패키지를 전역으로 설치하지 않기 위함입니다.

2. 가상 환경 진입

```bash
$ source .venv/bin/activate
```

가상환경에 진입합니다.

3. pre-commit 설치

```bash
$ make install
```

pre-commit을 설치합니다. 동작 방식은 Makefile에 작성되어 있습니다.

## 사용법

```bash
$ make 명령어
```

사용 방법은 make와 사용할 명령어의 조합입니다.

1. 코드 린팅

```bash
$ make lint
```

루트 디렉터리부터 시작해서 모든 코드를 린팅합니다.

2. 문법 검사

```bash
$ make validate
```
3. Github Action 로컬 테스트

``` bash
$ make action_test
```