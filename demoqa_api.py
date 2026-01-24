import requests

# 기본 베이스 URL 설정
BASE_URL = "https://demoqa.com"

# --- [Account API] 인증 관련 함수 ---

def generate_token(username, password):
    """사용자 토큰 생성 (POST /Account/v1/GenerateToken)"""
    url = f"{BASE_URL}/Account/v1/GenerateToken"
    payload = {"userName": username, "password": password}
    response = requests.post(url, json=payload)
    return response

def check_authorized(username, password):
    """현재 계정의 권한 유효성 확인 (POST /Account/v1/Authorized)"""
    url = f"{BASE_URL}/Account/v1/Authorized"
    payload = {"userName": username, "password": password}
    response = requests.post(url, json=payload)
    return response

def login_user(username, password):
    """로그인 수행 및 UserId/Token 획득 (POST /Account/v1/Login)"""
    url = f"{BASE_URL}/Account/v1/Login"
    payload = {"userName": username, "password": password}
    response = requests.post(url, json=payload)
    return response

# --- [BookStore API] 도서 관리 함수 ---

def book_store_api(method, endpoint, body=None, token=None):
    """도서 관련 모든 API 처리 (Books, Book)"""
    url = f"{BASE_URL}/BookStore/v1/{endpoint}"
    headers = {'Content-Type': 'application/json'}
    
    if token:
        headers['Authorization'] = f'Bearer {token}'

    else:
        print(f"⚠️ WARNING: No token provided for {method} {endpoint}")

    method = method.upper()
    if method == "GET":
        return requests.get(url, params=body, headers=headers)
    else:
        return requests.request(method, url, json=body, headers=headers)