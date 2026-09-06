# HindiLens (Flutter Client)

HindiLens is an assistive mobile OCR and neural machine translation client designed to capture Hindi text from physical environments (signboards, notices, documents) and translate it into English.

## Pipeline Architecture
1. **Capture/Pick**: Capture image via device camera or select from local gallery.
2. **Manual ROI Crop**: User isolates the target Devanagari text region.
3. **Backend Inference**: The cropped image is transmitted via `multipart/form-data` to the FastAPI backend endpoint (`POST /translate`, field `file`).
4. **OCR & Translation**: Backend processes Tesseract Devanagari OCR and IndicTrans2 Hindi → English translation.
5. **Verification & Presentation**: Extracted Hindi text and English output are displayed in the verification modal.

## Backend Configuration
The API endpoint is managed in `lib/services/api_service.dart`:
* **Android Emulator**: `http://10.0.2.2:8000`
* **Physical Device / Cloud**: Replace `baseUrl` with Person B's VM IP or public domain.

## Running the Project
```bash
flutter pub get
flutter run