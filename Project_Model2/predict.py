from ultralytics import YOLO
from PIL import Image
import io

# 모델 경로
model_path = "runs/classify/train184/weights/best.pt"
model = YOLO(model_path)

# 벌레 종류
BENEFICIAL = {"dragonfly", "honey_bee", "ladybug", "mantis", "Pieris_rapae"}

def predict_image(img_bytes):
    """바이트 데이터를 받아 예측 결과 반환"""
    img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    results = model.predict(img, verbose=False)
    probs = results[0].probs

    class_idx = probs.top1
    class_name = model.names[class_idx]
    confidence = float(probs.top1conf)
    insect_type = "익충" if class_name in BENEFICIAL else "해충"

    return {
        "class": class_name,
        "type": insect_type,
        "confidence": confidence
    }
