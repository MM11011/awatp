def dummy_response(text, status_code=200, headers=None):
    class DummyResponse:
        def __init__(self):
            self.text = text
            self.status_code = status_code
            self.headers = headers or {}
    return DummyResponse()
