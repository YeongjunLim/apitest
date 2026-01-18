*** Settings ***
Library           ../libraries/BookStoreLib.py
Library           Collections
Variables         ../config.py

*** Variables ***
${ISBN_1}         9781449325862    # Git Pocket Guide
${ISBN_2}         9781449331818    # Learning JavaScript Design Patterns

*** Test Cases ***
TC-API-FULL-FLOW: Test All 6 BookStore APIs
    [Documentation]    BookStore의 6개 API를 순차적으로 테스트합니다.
    # 1. 전체 조회 (GET /Books)
    ${all_books}=    Get All Books
    Should Not Be Empty    ${all_books['books']}
    # 2. 상세 조회 (GET /Book)
    ${book}=    Get Book Detail    ${ISBN_1}
    Should Be Equal    ${book['title']}    Git Pocket Guide
    # --- 여기서부터는 인증(Token) 필요 (이미 생성되었다고 가정) ---
    # 3. 책 추가 (POST /Books)
    ${isbns}=    Create List    ${ISBN_1}
    ${status}    ${res}=    Add Books To Collection    ${userId}    ${token}    ${isbns}
    Should Be Equal As Integers    ${status}    201
    # 4. 책 수정/교체 (PUT /Books/{ISBN})
    # ISBN_1을 ISBN_2로 교체
    ${status}    ${res}=    Update Book In Collection    ${userId}    ${token}    ${ISBN_1}    ${ISBN_2}
    Should Be Equal As Integers    ${status}    200
    # 5. 특정 책 삭제 (DELETE /Book)
    ${status}=    Delete One Book    ${userId}    ${token}    ${ISBN_2}
    Should Be Equal As Integers    ${status}    204
    # 6. 전체 삭제 (DELETE /Books)
    ${status}=    Delete All Books    ${userId}    ${token}
    Should Be Equal As Integers    ${status}    204
