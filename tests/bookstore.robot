*** Settings ***
Suite Setup       API Suite Setup
Library           ../demoqa_api.py
Library           Collections
Variables         ../config.py

*** Variables ***
${VALID_ISBN}     9781449325862
${NEW_ISBN}       9781449331818
${INVALID_ISBN}    INVALID12345

*** Test Cases ***
TC-01
    [Documentation]    전체 도서 목록을 조회합니다. (Public API)
    ${res}=    Book Store Api    method=GET    endpoint=Books
    Should Be Equal As Integers    ${res.status_code}    200

TC-02
    [Documentation]    특정 ISBN의 도서 상세 정보를 조회합니다.
    ${params}=    Create Dictionary    ISBN=${VALID_ISBN}
    ${res}=    Book Store Api    method=GET    endpoint=Book    body=${params}
    Should Be Equal As Integers    ${res.status_code}    200

TC-03
    [Documentation]    토큰 없이 도서 추가 시도 시 401 에러를 확인합니다.
    ${item}=    Create Dictionary    isbn=${VALID_ISBN}
    ${list}=    Create List    ${item}
    ${body}=    Create Dictionary    userId=${userId}    collectionOfIsbns=${list}
    ${res}=    Book Store Api    method=POST    endpoint=Books    body=${body}    token=${None}
    Should Be Equal As Integers    ${res.status_code}    401

TC-04
    [Documentation]    잘못된 ISBN으로 도서 추가 시도 시 400 에러를 확인합니다.
    ${item}=    Create Dictionary    isbn=INVALID_123
    ${list}=    Create List    ${item}
    ${body}=    Create Dictionary    userId=${userId}    collectionOfIsbns=${list}
    ${res}=    Book Store Api    method=POST    endpoint=Books    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    400

TC-05
    [Documentation]    정상적인 토큰과 ISBN으로 도서를 추가합니다.
    ${item}=    Create Dictionary    isbn=${VALID_ISBN}
    ${list}=    Create List    ${item}
    ${body}=    Create Dictionary    userId=${userId}    collectionOfIsbns=${list}
    ${res}=    Book Store Api    method=POST    endpoint=Books    body=${body}    token=${token}
    # 이미 추가된 경우 400이 날 수 있으므로 201 또는 400 허용
    Should Be True    ${res.status_code} == 201 or ${res.status_code} == 400

TC-06
    [Documentation]    토큰 없이 도서 교체 시도 시 401 에러를 확인합니다.
    ${body}=    Create Dictionary    userId=${userId}    isbn=${NEW_ISBN}
    ${res}=    Book Store Api    method=PUT    endpoint=Books/${VALID_ISBN}    body=${body}    token=${None}
    Should Be Equal As Integers    ${res.status_code}    401

TC-07
    [Documentation]    존재하지 않는 ISBN을 교체 대상으로 지정 시 400 에러를 확인합니다.
    ${body}=    Create Dictionary    userId=${userId}    isbn=${NEW_ISBN}
    ${res}=    Book Store Api    method=PUT    endpoint=Books/${INVALID_ISBN}    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    400

TC-08
    [Documentation]    정상적으로 도서를 교체합니다.
    ${body}=    Create Dictionary    userId=${userId}    isbn=${NEW_ISBN}
    ${res}=    Book Store Api    method=PUT    endpoint=Books/${VALID_ISBN}    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    200

TC-09
    [Documentation]    토큰 없이 도서 삭제 시도 시 401 에러를 확인합니다.
    ${body}=    Create Dictionary    isbn=${NEW_ISBN}    userId=${userId}
    ${res}=    Book Store Api    method=DELETE    endpoint=Book    body=${body}    token=${None}
    Should Be Equal As Integers    ${res.status_code}    401

TC-10
    [Documentation]    필수 정보(ISBN) 누락 시 400 에러를 확인합니다.
    ${body}=    Create Dictionary    isbn=${INVALID_ISBN}    userId=${userId}
    ${res}=    Book Store Api    method=DELETE    endpoint=Book    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    400

TC-11
    [Documentation]    정상적으로 도서 1권을 삭제합니다.
    ${body}=    Create Dictionary    isbn=${NEW_ISBN}    userId=${userId}
    ${res}=    Book Store Api    method=DELETE    endpoint=Book    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    204

TC-12
    [Documentation]    토큰 없이 전체 삭제 시도 시 401 에러를 확인합니다.
    ${params}=    Create Dictionary    UserId=${userId}
    ${res}=    Book Store Api    method=DELETE    endpoint=Books    body=${params}    token=${None}
    Should Be Equal As Integers    ${res.status_code}    401

TC-13
    [Documentation]    내 서재의 모든 도서를 삭제합니다.
    # 데이터를 body가 아닌 endpoint URL에 직접 포함시킵니다.
    ${res}=    Book Store Api    method=DELETE    endpoint=Books?UserId=${userId}    token=${token}
    Log To Console    \n[TC-13 DEBUG] Status: ${res.status_code}
    Log To Console    [TC-13 DEBUG] Response: ${res.text}
    Should Be Equal As Integers    ${res.status_code}    204

*** Keywords ***
API Suite Setup
    [Documentation]    로그인하여 Token 발급 및 Authorized 상태를 확인합니다.
    # 1. 토큰 발급 및 UserId 획득
    ${res}=    Login User    ${userName}    ${password}
    Should Be Equal As Integers    ${res.status_code}    200
    ${data}=    Set Variable    ${res.json()}
    Set Global Variable    ${token}    ${data['token']}
    Set Global Variable    ${userId}    ${data['userId']}
    # 2. 권한 유효성(Authorized) 최종 확인
    ${auth_res}=    Check Authorized    ${userName}    ${password}
    Should Be Equal As Strings    ${auth_res.text}    true
