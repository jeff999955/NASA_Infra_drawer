from flask import Flask, jsonify, request
import json
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

def getJSON():
    return {"edge": [{"from": "core", "to": "edge"}, {"from": "edge", "to": "A03"}]}


@app.route("/json", methods=["GET"])
def ReturnJSON():
    if request.method == "GET":
        with open("data.json") as json_file:
            data = json.load(json_file)

        return jsonify(data)

@app.route("/name", methods=["GET"])
def ReturnName():
    if request.method == "GET":
        with open("name_mapping.json") as json_file:
            data = json.load(json_file)

        return jsonify(data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port = 5920, debug = True)
