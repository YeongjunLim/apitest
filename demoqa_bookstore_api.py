import requests

class BookStoreLib:
    def __init__(self):
        self.base_url = "https://demoqa.com/BookStore/v1"
        self.headers = {'Content-Type': 'application/json'}

    def book_store_api(self, method, endpoint, body=None, token=None):
        url = f"{self.base_url}/{endpoint}"
        
        # 헤더 설정
        req_headers = self.headers.copy()
        if token:
            req_headers['Authorization'] = f'Bearer {token}'

        # API 요청 (GET은 params로, 나머지는 json으로 처리하는 것이 안전함)
        method = method.upper()
        if method == "GET":
            response = requests.get(url, params=body, headers=req_headers)
        else:
            response = requests.request(method, url, json=body, headers=req_headers)

        return response