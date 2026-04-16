from ultralytics import YOLO

def main():
    model = YOLO("yolov8m-cls.pt")
    model.train(
        data="dataset",
        epochs=100,
        imgsz=160,
        batch=16,
        name="train18",
        val=True
    )

if __name__ == "__main__":
    import multiprocessing
    multiprocessing.freeze_support()  # Windows에서 필요
    main()
