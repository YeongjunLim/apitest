*** Settings ***
Suite Setup       Setup2
Library           Collections
Library           ../demoqa_api.py
Variables         ../config.py

*** Variables ***
${VALID_ISBN}     9781449325862
${INVALID_ISBN}    1234567890

*** Test Cases ***
API Suite Setup
    # 1. 토큰 생성 및 데이터 추출
    ${token_res}=    Generate Token    ${userName}    ${password}
    Should Be Equal As Integers    ${token_res.status_code}    200
    ${token_data}=    Set Variable    ${token_res.json()}
    # 2. 로그인하여 UserId 가져오기
    ${login_res}=    Login User    ${userName}    ${password}
    ${login_data}=    Set Variable    ${login_res.json()}
    # [핵심] 토큰은 Generate Token에서, UserId는 Login에서 가져와 설정
    Set Global Variable    ${token}    ${token_data['token']}
    Set Global Variable    ${userId}    ${login_data['userId']}
    Log To Console    \nGenerated Token: ${token}

TC-01
    [Documentation]    현재 로그인된 사용자의 권한이 유효한지(Authorized) 확인합니다.
    ...    결과값으로 문자열 'true'가 반환되어야 합니다.
    ${res}=    Check Authorized    ${userName}    ${password}
    Should Be Equal As Integers    ${res.status_code}    200
    Should Be Equal As Strings    ${res.text}    true

TC-02
    [Documentation]    GenerateToken 엔드포인트를 호출하여 인증 토큰이 정상적으로 생성되는지 확인합니다.
    ${res}=    Generate Token    ${userName}    ${password}
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    token

TC-03
    [Documentation]    BookStore에 등록된 모든 도서 목록을 조회하고 성공 응답(200)을 확인합니다.
    ${res}=    Book Store Api    GET    Books
    Should Be Equal As Integers    ${res.status_code}    200

TC-04
    [Documentation]    인증 토큰을 사용하여 특정 ISBN의 도서를 내 컬렉션에 추가합니다.
    ...    이미 추가된 경우(400)도 정상 시나리오로 간주합니다.
    ${body}=    Create Dictionary    userId=${userId}    collectionOfIsbns={[{'isbn': '${VALID_ISBN}'}]}
    ${res}=    Book Store Api    POST    Books    body=${body}    token=${token}
    Should Be True    ${res.status_code} == 201 or ${res.status_code}

TC-05
    [Documentation]    특정 ISBN을 쿼리 파라미터로 전달하여 도서의 상세 정보를 정상적으로 가져오는지 확인합니다.T
    ${params}=    Create Dictionary    ISBN=${VALID_ISBN}
    ${res}=    Book Store Api    GET    Book    body=${params}
    Should Be Equal As Integers    ${res.status_code}    200

TC-06
    [Documentation]    기존에 내 서재에 있던 도서를 새로운 ISBN의 도서로 교체(업데이트)합니다.
    ${NEW_ISBN}=    Set Variable    9781449331818
    ${body}=    Create Dictionary    userId=${userId}    isbn=${NEW_ISBN}
    ${res}=    Book Store Api    PUT    Books/${VALID_ISBN}    body=${body}    token=${token}
    Log To Console    \nTC-06 Response: ${res.text}
    Should Be Equal As Integers    ${res.status_code}    200

TC-07
    [Documentation]    내 서재(Collection)에서 특정 도서 한 권만 지정하여 삭제하고 204(No Content) 응답을 확인합니다.
    ${body}=    Create Dictionary    isbn=${NEW_ISBN}    userId=${userId}
    ${res}=    Book Store Api    DELETE    Book    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    204

TC-08
    [Documentation]    인증 토큰(Bearer Token)을 누락하고 도서 추가를 시도하여 401 Unauthorized 에러가 발생하는지 검증합니다.
    ${body}=    Create Dictionary    userId=${userId}    collectionOfIsbns=${[{'isbn': '${VALID_ISBN}'}]}
    ${res}=    Book Store Api    POST    Books    body=${body}
    Should Be Equal As Integers    ${res.status_code}    401

TC-09
    [Documentation]    존재하지 않는 잘못된 ISBN 번호를 조회했을 때 서버가 400 Bad Request 에러를 반환하는지 확인합니다.
    ${params}=    Create Dictionary    ISBN=INVALID123
    ${res}=    Book Store Api    GET    Book    body=${params}
    Should Be Equal As Integers    ${res.status_code}    400

TC-10
    [Documentation]    테스트가 끝난 후 다음 테스트 실행 환경을 위해 사용자의 컬렉션을 완전히 비웁니다.
    ${params}=    Create Dictionary    UserId=${userId}
    ${res}=    Book Store Api    DELETE    Books    body=${params}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    204

*** Keywords ***
Setup
    # 1. 토큰 생성 확인
    ${token_res}=    Generate Token    ${userName}    ${password}
    Should Be Equal As Integers    ${token_res.status_code}    200
    # 2. 로그인하여 실제 필요한 데이터 가져오기
    ${login_res}=    Login User    ${userName}    ${password}
    ${data}=    Set Variable    ${login_res.json()}
    Set Global Variable    ${token}    ${data['token']}
    Set Global Variable    ${userId}    ${data['userId']}

Setup2
    # 1. 로그인하여 데이터 가져오기
    ${login_res}=    Login User    ${userName}    ${password}
    Should Be Equal As Integers    ${login_res.status_code}    200
    ${data}=    Set Variable    ${login_res.json()}
    # 2. 전역 변수 설정
    Set Global Variable    ${token}    ${data['token']}
    Set Global Variable    ${userId}    ${data['userId']}
    # 3. [중요] 이 토큰이 실제로 유효한지 서버에 한 번 더 확인 (이 과정을 거쳐야 활성화되는 경우가 있음)
    ${auth_res}=    Check Authorized    ${userName}    ${password}
    Log To Console    \n[SETUP] Is User Authorized? : ${auth_res.text}
