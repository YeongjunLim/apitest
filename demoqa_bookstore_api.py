import requests

class BookStoreLib:
    def __init__(self):
        self.base_url = "https://demoqa.com/BookStore/v1"

    # 공통 요청 메서드 (메서드를 인자로 받아 테스트 유연성 확보)
    def send_book_request(self, method, endpoint, token=None, params=None, json=None):
        url = f"{self.base_url}/{endpoint}"
        headers = {}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        
        response = requests.request(method, url, headers=headers, params=params, json=json)
        return response
        
    # 1. GET /Books - 전체 도서 조회
    def get_all_books(self):
        response = requests.get(f"{self.base_url}/Books")
        return response.json()

    # 2. POST /Books - 도서 추가 (내 서재에 담기)
    def add_books_to_collection(self, user_id, token, isbns):
        headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
        # isbns는 리스트 형태로 받음 [{'isbn': '123'}, ...]
        payload = {
            "userId": user_id,
            "collectionOfIsbns": [{"isbn": i} for i in isbns]
        }
        response = requests.post(f"{self.base_url}/Books", json=payload, headers=headers)
        return response.status_code, response.json()

    # 3. DELETE /Books - 특정 사용자의 전체 도서 삭제
    def delete_all_books(self, user_id, token):
        headers = {"Authorization": f"Bearer {token}"}
        params = {"UserId": user_id}
        response = requests.delete(f"{self.base_url}/Books", params=params, headers=headers)
        return response.status_code

    # 4. GET /Book - 특정 도서 상세 조회
    def get_book_detail(self, isbn):
        params = {"ISBN": isbn}
        response = requests.get(f"{self.base_url}/Book", params=params)
        return response.json()

    # 5. DELETE /Book - 특정 도서 1권 삭제
    def delete_one_book(self, user_id, token, isbn):
        headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
        payload = {"isbn": isbn, "userId": user_id}
        response = requests.delete(f"{self.base_url}/Book", json=payload, headers=headers)
        return response.status_code

    # 6. PUT /Books/{ISBN} - 도서 정보 업데이트 (교체)
    def update_book_in_collection(self, user_id, token, old_isbn, new_isbn):
        headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
        payload = {"userId": user_id, "isbn": new_isbn}
        response = requests.put(f"{self.base_url}/Books/{old_isbn}", json=payload, headers=headers)
        return response.status_code, response.json()