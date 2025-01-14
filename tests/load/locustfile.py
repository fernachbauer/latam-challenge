from locust import HttpUser, task, between

class APILoadTest(HttpUser):
    wait_time = between(1, 3)  # Tiempo de espera entre solicitudes (1-3 segundos)

    @task(2)
    def health_check(self):
        self.client.get("/health")

    @task(5)
    def get_datos(self):
        self.client.get("/datos")

    @task(1)
    def post_datos(self):
        self.client.post("/datos", json={
            "id": "locust-test",
            "contenido": "Prueba de carga",
            "timestamp": "2024-01-14T15:00:00Z"
        })