import pytest
import requests

BASE_URL = "https://restful-booker.herokuapp.com"

@pytest.fixture(scope="session")
def auth_token():
    """로그인을 통해 인증 토큰을 받아옵니다."""
    payload = {
        "username": "admin",
        "password": "password123"
    }
    response = requests.post(f"{BASE_URL}/auth", json=payload)
    return response.json()["token"]

@pytest.fixture
def base_url():
    return BASE_URL