import requests

def test_create_booking(base_url):
    payload = {
        "firstname": "Yeongjun",
        "lastname": "Lim",
        "totalprice": 111,
        "depositpaid": True,
        "bookingdates": {
            "checkin": "2024-01-01",
            "checkout": "2024-01-02"
        },
        "additionalneeds": "Breakfast"
    }
    response = requests.post(f"{base_url}/booking", json=payload)
    assert response.status_code == 200
    assert response.json()["booking"]["firstname"] == "Yeongjun"
    return response.json()["bookingid"]

def test_update_booking(base_url, auth_token):
    # 실제로는 create에서 생성된 ID를 받아와야 하지만, 예시로 1번 사용
    booking_id = 1 
    headers = {"Cookie": f"token={auth_token}"}
    payload = {"firstname": "UpdatedName", "lastname": "Lim"}
    
    # PATCH를 이용한 부분 수정
    response = requests.patch(
        f"{base_url}/booking/{booking_id}", 
        json=payload, 
        headers=headers
    )
    assert response.status_code == 200