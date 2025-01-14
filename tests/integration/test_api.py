import requests

BASE_URL = "https://latam-api-317569714660.us-central1.run.app"

def test_health_endpoint():
    response = requests.get(f"{BASE_URL}/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_datos_endpoint():
    response = requests.get(f"{BASE_URL}/datos")
    assert response.status_code == 200
    assert "datos" in response.json()
