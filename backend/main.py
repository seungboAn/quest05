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
inference_result = {
    "result": None,
    "type": None,
    "probabilities": None
}

# Endpoint to get inference result
@app.get("/inference_result")
async def get_inference_result():
    return {"result": "Sample classification", "type": inference_result["result"]}

# Endpoint to get inference probability
@app.get("/inference_probability")
async def get_inference_probability():
    return {
       'probabilities': inference_result["probabilities"]
    }

# Endpoint to upload image
@app.post("/image_upload")
async def upload_image(file: UploadFile = File(...)):
    # Create uploads directory if it doesn't exist
    os.makedirs("uploads", exist_ok=True)
    filename = file.filename
    file_path = os.path.join("uploads", filename)
    contents = await file.read()
    with open(file_path, "wb") as f:
        f.write(contents)


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

    # Get the class with the highest confidence
    top_prediction = max(predictions_decoded, key=lambda x: x[2])

    inference_result["result"] = top_prediction[1]
    inference_result["type"] = top_prediction[0]
    inference_result["probabilities"] = float(top_prediction[2])   

    return {
        "filename": file.filename,
        "filepath": file_path,
        "status": "uploaded successfully",
        "inference_result": {
            "result": top_prediction[1],
            "type": top_prediction[0],
            "probabilities": float(top_prediction[2])
        }
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)