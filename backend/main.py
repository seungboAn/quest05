from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import os
import numpy as np
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.resnet50 import preprocess_input, decode_predictions

app = FastAPI()

# Add CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Inference result model
class InferenceResult(BaseModel):
    result: str
    confidence: float

# Endpoint to get inference result
@app.get("/inference_result")
async def get_inference_result():
    return {"result": "Sample classification", "type": 'something_type'}

# Endpoint to get inference probability
@app.get("/inference_probability")
async def get_inference_probability():
    return {
        "probabilities": {
            "class1": 0.75,
            "class2": 0.20,
            "class3": 0.05
        }
    }

# Endpoint to upload image
@app.post("/image_upload")
async def upload_image(file: UploadFile = File(...)):
    # Create uploads directory if it doesn't exist
    os.makedirs("uploads", exist_ok=True)

    # Save the uploaded file
    file_path = os.path.join("uploads", file.filename)
    with open(file_path, "wb") as buffer:
        buffer.write(await file.read())

    # Load the ResNet50 model
    model = ResNet50(weights='imagenet')

    # Load the uploaded image
    img = image.load_img(file_path, target_size=(224, 224))
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)

    # Make prediction
    predictions = model.predict(x)

    # Decode the predictions
    predictions_decoded = decode_predictions(predictions, top=3)[0]

    return {
        "filename": file.filename,
        "filepath": file_path,
        "status": "uploaded successfully",
        "predictions": [
            {"class": prediction[1], "confidence": float(prediction[2])}
            for prediction in predictions_decoded
        ]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)