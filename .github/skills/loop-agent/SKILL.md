---
name: loop-agent
description: 테스트, 린트, 문서 검토처럼 반복적인 계획, 실행, 관찰, 평가, 재계획이 필요한 작업을 제한된 루프로 개선합니다.
user-invocable: true
disable-model-invocation: false
context: inline
---

# Loop Agent Pattern

## 목적

작업을 한 번에 끝내려고 하지 않고, 관찰 가능한 결과를 기준으로 반복 개선합니다.

Loop Agent는 Claude Code의 공식 기능명이 아니라 반복 개선을 위한 Agent Design Pattern입니다.

## 사용 시기

- 테스트 실패를 수정하고 재실행해야 할 때
- 린트 또는 포맷 검사를 반복해서 통과시켜야 할 때
- 코드 리뷰 결과를 반영하고 다시 검토해야 할 때
- 문서 초안을 검토한 뒤 여러 차례 다듬어야 할 때

## 반복 단계

1. Plan: 현재 목표와 종료 조건을 정의합니다.
2. Tool Execute: 테스트, 린트, 분석 스크립트 등 관찰 가능한 도구를 실행합니다.
3. Observe: exit code, stdout, stderr, 변경 파일을 확인합니다.
4. Evaluate: 성공 조건을 만족했는지 판단합니다.
5. Replan: 실패 원인 또는 개선 지점을 반영해 다음 계획을 만듭니다.
6. Repeat: 최대 반복 횟수 안에서만 반복합니다.

## 제한 사항

- 무한 루프를 만들지 않습니다.
- 기본 최대 반복 횟수는 3~5회로 제한합니다.
- 같은 오류가 반복되면 중단하고 원인을 보고합니다.
- 종료 조건 없이 수정만 반복하지 않습니다.
- 위험한 명령, 광범위한 삭제, 배포 작업은 사용자 승인 없이 수행하지 않습니다.

## 권장 종료 조건

| 조건 | 예시 |
|------|------|
| 성공 | 테스트 통과, 린트 통과, 리뷰 이슈 0개 |
| 중단 | 같은 오류 2회 이상 반복 |
| 실패 | 의존성 누락, 권한 부족, 환경 오류 |
| 제한 | 최대 반복 횟수 또는 timeout 도달 |

## 스크립트 사용 예

```bash
LOOP_AGENT_MAX_ITERATIONS=5 \
LOOP_AGENT_COMMAND="npm test" \
bash ./scripts/loop-agent.sh
```

`LOOP_AGENT_COMMAND`는 신뢰할 수 있는 명령만 넣습니다.
운영 환경에서는 allowlist 방식으로 제한하는 것이 좋습니다.
