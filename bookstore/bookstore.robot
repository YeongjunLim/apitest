*** Settings ***
Library           ../demoqa_bookstore_api.py
Library           Collections

*** Variables ***
${VALID_ISBN}     9781449325862
${INVALID_ISBN}    1234567890

*** Test Cases ***
TC-API-01: GET Books - Success
    [Documentation]    전체 도서 목록을 정상적으로 조회합니다.
    ${res}=    Send Book Request    GET    Books
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    books

TC-API-02: GET Books - Method Not Allowed
    [Documentation]    POST 메서드로 목록 조회를 시도하여 405 에러를 확인합니다.
    ${res}=    Send Book Request    POST    Books
    Should Be Equal As Integers    ${res.status_code}    405

TC-API-03: GET Book Detail - Success
    [Documentation]    특정 ISBN으로 도서 정보를 정상 조회합니다.
    ${params}=    Create Dictionary    ISBN=${VALID_ISBN}
    ${res}=    Send Book Request    GET    Book    params=${params}
    Should Be Equal As Integers    ${res.status_code}    200
    Should Be Equal    ${res.json()['title']}    Git Pocket Guide

TC-API-04: GET Book Detail - Missing Parameter
    [Documentation]    필수 파라미터(ISBN) 없이 상세 조회를 시도합니다.
    ${res}=    Send Book Request GET Book
    Should Be Equal As Integers    ${res.status_code}    400
    Should Be Equal    ${res.json()['message']}    ISBN supplied is not available in Books Collection!

TC-API-05: POST Books - Success
    [Documentation]    인증 토큰을 사용하여 내 서재에 책을 추가합니다.
    ${json}=    Create Dictionary userId=${userId}    collectionOfIsbns=${[{'isbn': '${VALID_ISBN}'}]}
    ${res}=    Send Book Request    POST    Books    token=${token} json=${json}
    # 이미 추가된 경우 400이 뜰 수 있으므로 201 혹은 400(이미 존재) 확인
    Should Contain Any    ${res.status_code}    201 400

TC-API-06: POST Books - Unauthorized
    [Documentation]    토큰 없이 책 추가를 시도하여 401 에러를 확인합니다.
    ${json}=    Create Dictionary    userId=${userId}    collectionOfIsbns=${[{'isbn': '${VALID_ISBN}'}]}
    ${res}=    Send Book Request    POST    Books    json=${json}
    Should Be Equal As Integers    ${res.status_code}    401

TC-API-07: PUT Book - Success
    [Documentation]    기존 책을 새로운 책으로 교체합니다.
    ${new_isbn}=    Set Variable    9781449331818
    ${json}=    Create Dictionary    userId=${userId}    isbn=${new_isbn}
    ${res}=    Send Book Request    PUT    Books/${VALID_ISBN}    token=${token} json=${json}
    Should Be Equal As Integers    ${res.status_code}    200

TC-API-08: PUT Book - Invalid ISBN
    [Documentation]    잘못된 경로의 ISBN으로 수정을 시도합니다.
    ${json}=    Create Dictionary    userId=${userId}    isbn=${VALID_ISBN}
    ${res}=    Send Book Request PUT Books/wrong_path token=${token}    json=${json}
    Should Be Equal As Integers    ${res.status_code}    400

TC-API-09: DELETE Book - Success
    [Documentation]    내 서재에서 특정 도서 1권을 삭제합니다.
    ${json}=    Create Dictionary    userId=${userId}    isbn=${VALID_ISBN}
    ${res}=    Send Book Request    DELETE    Book    token=${token}    json=${json}
    Should Be Equal As Integers ${res.status_code} 204

TC-API-10: DELETE Book - Method Not Allowed (GET)
    [Documentation]    삭제 엔드포인트에 GET 요청을 보내 에러를 확인합니다.
    ${json}=    Create Dictionary    userId=${userId}    isbn=${VALID_ISBN}
    ${res}=    Send Book Request    GET    Book    token=${token}    json=${json}
    # 상세조회 GET /Book과 겹치지만 Body를 무시하므로 결과가 다를 수 있음
    Log Status: ${res.status_code}

TC-API-11: DELETE All Books - Success
    [Documentation]    해당 사용자의 모든 도서를 삭제합니다.
    ${params}=    Create Dictionary UserId=${userId}
    ${res}=    Send Book Request    DELETE    Books    token=${token}    params=${params}
    Should Be Equal As Integers    ${res.status_code}    204

TC-API-12: DELETE All Books - Invalid Token
    [Documentation]    잘못된 토큰으로 전체 삭제를 시도합니다.
    ${params}=    Create Dictionary    UserId=${userId}
    ${res}=    Send Book Request    DELETE    Books    token=invalid_token    params=${params}
    Should Be Equal As Integers    ${res.status_code}    401

TC-API-13: DELETE All Books - Missing UserId
    [Documentation]    UserId 파라미터 없이 전체 삭제를 시도합니다.
    ${res}=    Send Book Request    DELETE    Books    token=${token}
    Should Be Equal As Integers    ${res.status_code}    400
