from flask import Flask, render_template, request
import requests

app = Flask(__name__)

BACKEND_URL = "http://backend:5500"

@app.route('/')
def home():
    try:
        response = requests.get(f"{BACKEND_URL}/data")
        data = response.json()
    except Exception as e:
        data = {"error": str(e)}
    return render_template("index.html", data=data)

@app.route('/add', methods=['POST'])
def add_data():
    name = request.form['name']
    value = request.form['value']
    try:
        response = requests.post(f"{BACKEND_URL}/data", json={"name": name, "value": value})
        if response.status_code == 201:
            message = "Data added successfully!"
        else:
            message = "Failed to add data."
    except Exception as e:
        message = str(e)
    return render_template("index.html", message=message)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)