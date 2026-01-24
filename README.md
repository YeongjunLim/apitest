## 📊 [테스트 실행 결과 리포트 보기(클릭)](https://yeongjunlim.github.io/apitest/) 
Note: 위 링크를 통해 실제 수행된 13개 테스트 케이스의 상세 로그와 Pass/Fail 통계를 실시간으로 확인할 수 있습니다.

## 📚 DemoQA BookStore API Automation Project
- 이 프로젝트는 Robot Framework와 Python을 활용하여 DemoQA BookStore의 주요 API 기능을 자동화하고, 다양한 HTTP 상태 코드(200, 201, 204, 400, 401)를 검증하는 포트폴리오 프로젝트입니다.

## 🚀 주요 특징
- API 기능별 세분화: 조회, 추가, 수정, 삭제의 성공 및 예외 케이스를 모두 포함.
- 인증(Authentication) 관리: Suite Setup을 통해 토큰 발급 및 유효성 검증을 자동화.
- 커스텀 라이브러리: Python requests 모듈을 사용한 범용 API 호출 라이브러리 개발.
- 데이터 주도 테스트: 변수를 활용하여 유효한 ISBN과 잘못된 ISBN을 관리.

## 🛠️ 기술 스택
| 구분 | 기술 | 
| ---- | ---- |
| Framework | Robot Framework |
| Language | Python 3.9.13 | 
| Library | Requests, Collections |
| Target API | [DemoQA BookStore API](https://demoqa.com/swagger/#/) |
 

## 📂 파일 구조
- tests/bookstore.robot: 13개의 시나리오가 포함된 메인 테스트 스크립트.
- demoqa_api.py: HTTP 요청을 처리하는 Python 커스텀 라이브러리.
- config.py: 사용자 계정 정보 및 API 베이스 URL 설정 파일.

## 📑 테스트 케이스 리스트 (13 Cases)
- 본 테스트는 각 기능에 대해 [인증 실패 -> 데이터 오류 -> 성공] 순서로 검증을 수행합니다.
### 1. 도서 조회 기능
- TC-01: 도서 전체 조회 - Success (200)
- TC-02: 도서 상세 조회 - Success (200)

### 2. 도서 추가 기능 (POST)
- TC-03: 도서 추가 - Fail (401 Unauthorized)
- TC-04: 도서 추가 - Fail (400 Bad Request / Invalid ISBN)
- TC-05: 도서 추가 - Success (201 Created)

### 3. 도서 교체/수정 기능 (PUT)
- TC-06: 도서 교체 - Fail (401 Unauthorized)
- TC-07: 도서 교체 - Fail (400 Bad Request / Path Error)
- TC-08: 도서 교체 - Success (200 OK)

### 4. 도서 개별 삭제 기능 (DELETE)
- TC-09: 도서 삭제 - Fail (401 Unauthorized)
- TC-10: 도서 삭제 - Fail (400 Bad Request / Missing ISBN)
- TC-11: 도서 삭제 - Success (204 No Content)

### 5. 도서 전체 삭제 기능 (DELETE)
- TC-12: 도서 전체삭제 - Fail (401 Unauthorized)
- TC-13: 도서 전체삭제 - Success (204 No Content)

## ⚙️ 실행 방법
### Prerequisites
```Bash
pip install robotframework robotframework-requests
```

### Configuration
- config.py 파일에 DemoQA에서 가입한 계정 정보를 입력합니다.
```python
userName = "your_id"
password = "your_password123!"
```

- Run Tests
```bash
robot tests/bookstore.robot
```

## 💡 학습 및 해결 포인트
- 401 Unauthorized: 토큰 누락 및 DemoQA의 Authorized 상태 활성화를 Suite Setup에서 해결.
- 400 Bad Request: 서버가 요구하는 JSON 데이터 구조와 URL 쿼리 파라미터 방식의 차이점을 이해하고 반영.
- 코드 재사용성: 하나의 파이썬 함수로 모든 HTTP 메서드를 소화할 수 있도록 라이브러리 설계 최적화.