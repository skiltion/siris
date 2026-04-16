# app.py
from flask import Flask, request, jsonify
from ultralytics import YOLO
from PIL import Image
import io

app = Flask(__name__)

# YOLOv8 classification 모델 경로
MODEL_PATH = "Project_Model2/runs/classify/train184/weights/best.pt"
model = YOLO(MODEL_PATH)

# 벌레 분류: 익충/해충
BENEFICIAL = {"dragonfly", "honey_bee", "ladybug", "mantis", "Pieris_rapae"}

def predict_image(img_bytes):
    """바이트 데이터를 받아 예측 결과 반환"""
    img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    results = model.predict(img, verbose=False)
    probs = results[0].probs  # Probs 객체

    class_idx = probs.top1
    class_name = model.names[class_idx]
    confidence = float(probs.top1conf)
    insect_type = "익충" if class_name in BENEFICIAL else "해충"

    return {
        "class": class_name,
        "type": insect_type,
        "confidence": confidence
    }

@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "No selected file"}), 400

    try:
        img_bytes = file.read()
        result = predict_image(img_bytes)
        return jsonify(result)
    except Exception as e:
        # 오류 발생 시, 에러 메시지를 그대로 반환
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    # 모든 IP에서 접속 가능, 디버그 모드 켜기
    app.run(host="0.0.0.0", port=5000, debug=True)
