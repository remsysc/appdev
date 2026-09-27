FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
# Pre-train the model so joblib file is ready for inference
RUN python train_classifier.py
EXPOSE 8001
CMD ["uvicorn", "predict_service:app", "--host", "0.0.0.0", "--port", "8001"]
