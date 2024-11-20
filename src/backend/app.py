from flask import Flask, jsonify, request
import mysql.connector
import os
import logging

app = Flask(__name__)
app.debug = True

# MySQL connection configuration
# db_config = {
#     "host": "mysql-db",  # Docker service name for MySQL
#     "user": "root",
#     "password": "password",
#     "database": "demo_db"
# }
db_config = {
    "host": os.getenv("DB_HOST"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_NAME")
}
    
# Configure logging
logging.basicConfig(level=logging.INFO)
logging.info("DB_CONFIG: %s", db_config)

@app.route('/data', methods=['GET'])
def get_data():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, value FROM demo_table;")
        rows = cursor.fetchall()
        data = [{"id": row[0], "name": row[1], "value": row[2]} for row in rows]
        conn.close()
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/data', methods=['POST'])
def insert_data():
    data = request.json
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO demo_table (name, value) VALUES (%s, %s);",
            (data['name'], data['value'])
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Data inserted successfully!"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5500)
