*** Settings ***
Library           Collections
Variables         ../demoqa_api.py

*** Variables ***
${VALID_ISBN}     9781449325862
${INVALID_ISBN}    1234567890

*** Test Cases ***
TC-API-01: GET Books - Success
    [Documentation]    전체 도서 목록을 정상적으로 조회합니다.
    ${res}=    Book Store Api    GET    Books
    Should Be Equal As Integers    ${res.status_code}    200
    ${data}=    Set Variable    ${res.json()}
    Dictionary Should Contain Key    ${data}    books

TC-API-02: GET Books - Method Not Allowed
    [Documentation]    POST 메서드로 목록 조회를 시도하여 405 에러를 확인합니다.
    ${res}=    Book Store Api    POST    Books
    Should Be Equal As Integers    ${res.status_code}    405

TC-API-03: GET Book Detail - Success
    [Documentation]    특정 ISBN으로 도서 정보를 정상 조회합니다.
    ${params}=    Create Dictionary    ISBN=${VALID_ISBN}
    ${res}=    Book Store Api    GET    Book    body=${params}
    Should Be Equal As Integers    ${res.status_code}    200
    ${data}=    Set Variable    ${res.json()}
    Should Be Equal    ${data['title']}    Git Pocket Guide

TC-API-04: GET Book Detail - Invalid ISBN
    [Documentation]    잘못된 ISBN으로 상세 조회를 시도하여 400 에러를 확인합니다.
    ${params}=    Create Dictionary    ISBN=${INVALID_ISBN}
    ${res}=    Book Store Api    GET    Book    body=${params}
    Should Be Equal As Integers    ${res.status_code}    400
    Should Be Equal    ${res.json()['message']}    ISBN supplied is not available in Books Collection!

TC-API-05: POST Books - Success
    [Documentation]    인증 토큰을 사용하여 내 서재에 책을 추가합니다. (201 또는 이미 있으면 400)
    ${body}=    Create Dictionary    userId=${userId}    collectionOfIsbns=${[{'isbn': '${VALID_ISBN}'}]}
    ${res}=    Book Store Api    POST    Books    body=${body}    token=${token}
    Should Contain Any    ${res.status_code}    201    400

TC-API-06: POST Books - Unauthorized
    [Documentation]    토큰 없이 책 추가를 시도하여 401 에러를 확인합니다.
    ${body}=    Create Dictionary    userId=${userId}    collectionOfIsbns=${[{'isbn': '${VALID_ISBN}'}]}
    ${res}=    Book Store Api    POST    Books    body=${body}
    Should Be Equal As Integers    ${res.status_code}    401

TC-API-07: PUT Book - Success
    [Documentation]    기존 책을 새로운 책으로 교체합니다.
    ${body}=    Create Dictionary    userId=${userId}    isbn=${NEW_ISBN}
    # 엔드포인트에 {ISBN} 경로 포함
    ${res}=    Book Store Api    PUT    Books/${VALID_ISBN}    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    200

TC-API-08: PUT Book - Bad Request (Wrong Path)
    [Documentation]    잘못된 경로의 ISBN으로 수정을 시도합니다.
    ${body}=    Create Dictionary    userId=${userId}    isbn=${NEW_ISBN}
    ${res}=    Book Store Api    PUT    Books/INVALID_PATH    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    400

TC-API-09: DELETE Book - Success
    [Documentation]    내 서재에서 특정 도서 1권을 삭제합니다.
    ${body}=    Create Dictionary    userId=${userId}    isbn=${NEW_ISBN}
    ${res}=    Book Store Api    DELETE    Book    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    204

TC-API-10: DELETE Book - Missing ISBN
    [Documentation]    ISBN 정보 없이 삭제를 시도합니다.
    ${body}=    Create Dictionary    userId=${userId}
    ${res}=    Book Store Api    DELETE    Book    body=${body}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    400

TC-API-11: DELETE All Books - Success
    [Documentation]    해당 사용자의 모든 도서를 삭제합니다.
    ${params}=    Create Dictionary    UserId=${userId}
    ${res}=    Book Store Api    DELETE    Books    body=${params}    token=${token}
    Should Be Equal As Integers    ${res.status_code}    204

TC-API-12: DELETE All Books - Invalid Token
    [Documentation]    잘못된 토큰으로 전체 삭제를 시도합니다.
    ${params}=    Create Dictionary    UserId=${userId}
    ${res}=    Book Store Api    DELETE    Books    body=${params}    token=WRONG_TOKEN
    Should Be Equal As Integers    ${res.status_code}    401

TC-API-13: DELETE All Books - Missing UserId
    [Documentation]    UserId 파라미터 없이 전체 삭제를 시도합니다.
    ${res}=    Book Store Api    DELETE    Books    token=${token}
    Should Be Equal As Integers    ${res.status_code}    400
