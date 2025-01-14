import requests
import json

url = "https://advana-challenge-check-api-cr-k4hdbggvoq-uc.a.run.app/devops"

# ⚠️ Campos corregidos: name, mail, github_url
data = {
    "name": "Fernando Nachbauer R",
    "mail": "fernachbauer@gmail.com",
    "github_url": "https://github.com/fernachbauer/latam-challenge"
}

headers = {
    "Content-Type": "application/json"
}

response = requests.post(url, data=json.dumps(data), headers=headers)

print("Status Code:", response.status_code)
print("Response:", response.text)
