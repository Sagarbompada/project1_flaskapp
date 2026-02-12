from app import app
client = app.test_client()
response = client.get("/health")
print("STATUS:", response.status_code)
print("DATA:", response.data)
assert response.status_code == 200
assert response.data.strip() == b"OK"
print("Health endpoint test passed")
