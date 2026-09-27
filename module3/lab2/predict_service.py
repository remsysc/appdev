from fastapi import FastAPI
from pydantic import BaseModel
import joblib

app = FastAPI()
model = joblib.load('ticket_classifier.joblib')

class PredictRequest(BaseModel):
    text: str

@app.post('/predict')
def predict(payload: PredictRequest):
    category = model.predict([payload.text])[0]
    return {'category': category}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
