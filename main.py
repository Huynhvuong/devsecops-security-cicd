import os, json
from datetime import datetime

from flask import Flask, request, Response

app = Flask(__name__)

@app.route("/healthcheck", methods=["GET"])
def healthcheck():
    return Response(
        status=200,
        mimetype="text/plain",
        response=json.dumps({
            "status": "ok",
            "app_env": os.getenv("APP_ENV"),
            "timestamp": datetime.now().isoformat()
        }) + "\n\nDesigned by HieuMai & VuongHuynh.\n"
    )

if __name__ == "__main__":
    app.run(port=3000, debug=True, host="0.0.0.0")