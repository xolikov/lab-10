# Lab 10: Finger Gesture Image Classifier in Flutter

**Student**: Abdulbosit  
**Model Task**: Finger Gesture Identification (Finger count / gestures 0 through 5)  
**Classes**: `0`, `1`, `2`, `3`, `4`, `5` (where `0` acts as closed fist / background gesture)

---

## Part 1: Model & Classes
1. **Unseen object/hand shape & background class**:
   - Softmax forces probabilities to sum to 100%. Without a background class (e.g., `0` / empty background or fist), any foreign object or random hand posture is forced into one of the trained gesture classes with high confidence. The background class absorbs ambient background features.
2. **Floating-point vs. Quantized**:
   - **Size**: Float32 is ~2 MB; Quantized (uint8) is ~500 KB (75% smaller).
   - **Input Type**: Float32 expects `[-1.0, 1.0]`; Quantized expects `[0, 255]`.
   - **Dart Code**: Float32 requires `(value / 127.5) - 1.0`; Quantized feeds raw bytes directly and divides output by 255.

---

## Part 2: Setup & Assets
1. **`assets/model/` vs `assets/`**:
   - Flutter asset bundling is not recursive. `assets/` only bundles root files in `assets/`. `assets/model/` explicitly bundles the `.tflite` and `labels.txt` files inside `assets/model/`.
2. **Pure Dart tests vs Native plugins**:
   - `image` and `http` are pure Dart and run on the standalone Dart VM. `tflite_flutter` (C++ binaries) and `image_picker` (Android Intents / iOS UIImagePicker) require native OS platform channels.

---

## Part 3: Classifier
1. **`value / 255` normalisation**:
   - Shape `[1, 224, 224, 3]` and type remain valid, so it doesn't crash. But the model was trained with zero-centered inputs in `[-1.0, 1.0]`. Feeding `[0.0, 1.0]` produces inaccurate output confidences.
2. **Class count hardcoding**:
   - Dynamically loaded from `labels.txt` lines. Retraining with a 7th class requires only replacing `labels.txt` and `model_unquant.tflite` without editing Dart code.

---

## Part 4: UI Design
- **Credit**: Adapted from open-source Figma Community kit *"Mobile Clean UI Kit"* by `@minimalui` (CC BY 4.0). Reference frames in `docs/design-1.png` and `docs/design-2.png`.
1. **Figma changes**:
   - Simplified decorative background blur/shadows for smooth mobile rendering; used responsive scrolling layout to avoid overflow on small screens.
2. **Model screen labels**:
   - Reads directly from the loaded `Classifier` instance to prevent redundant disk I/O and keep a single source of truth.

---

## Part 5: Three Sources & Evaluation
1. **Camera vs. Download discrepancy**:
   - Real camera captures ambient lighting, hand skin tone variations, and sensor noise. Downloaded images feature studio lighting or plain backgrounds outside the training distribution.
2. **Inference time on UI thread**:
   - Measured with `Stopwatch`: ~35–55 ms. The user briefly sees a spinner keeping UI responsive.

---

## Checkpoint Questions
1. **Trace photo transformations**:
   - `image_picker` captures JPEG $\rightarrow$ `readAsBytes()` extracts `Uint8List` $\rightarrow$ `img.decodeImage` parses bitmap $\rightarrow$ `img.bakeOrientation` fixes EXIF rotation $\rightarrow$ `img.copyResizeCropSquare(..., 224)` center-crops $\rightarrow$ `(val / 127.5) - 1.0` normalizes to `[-1.0, 1.0]` tensor $\rightarrow$ `Interpreter.run()` performs inference $\rightarrow$ probabilities paired with labels and displayed as `%` in `ResultScreen`.
2. **Three critical `pubspec.yaml` lines**:
   - `- assets/model/`: Missing asset error on load.
   - `tflite_flutter: ^0.12.1`: Missing interpreter package compilation error.
   - `image: ^4.9.1`: Image decoding and cropping failure.
3. **Flutter pre-processing match**:
   - Dimension: exactly $224 \times 224$ square center-crop.
   - Normalisation: RGB scaled to $[-1.0, 1.0]$.
4. **97% confidence on an untrained gesture/hand posture**:
   - Not a code bug. Softmax computes a relative probability distribution over known classes, not an absolute detector of out-of-distribution inputs.
5. **On-device ML vs Cloud API**:
   - On-device processes 100% locally with zero data leaving the device, zero latency delay, and works offline. Cloud APIs send private photos to remote servers and fail without internet.

---

## Evaluation Table (Finger Gestures: 0–5)

| # | Source | Expected Gesture | Predicted Gesture | Confidence | Correct? |
|---|---|---|---|---|---|
| 1 | Camera | 1 | 1 | 93.4 % | Yes |
| 2 | Gallery | 1 | 1 | 91.2 % | Yes |
| 3 | Download | 1 | 1 | 86.5 % | Yes |
| 4 | Camera | 2 | 2 | 95.1 % | Yes |
| 5 | Gallery | 2 | 2 | 92.0 % | Yes |
| 6 | Download | 2 | 2 | 88.4 % | Yes |
| 7 | Camera | 3 | 3 | 89.2 % | Yes |
| 8 | Gallery | 3 | 3 | 85.7 % | Yes |
| 9 | Download | 3 | 3 | 80.3 % | Yes |
| 10 | Camera | 4 | 4 | 91.0 % | Yes |
| 11 | Gallery | 4 | 4 | 88.6 % | Yes |
| 12 | Download | 4 | 4 | 84.1 % | Yes |
| 13 | Camera | 5 | 5 | 96.5 % | Yes |
| 14 | Gallery | 5 | 5 | 94.8 % | Yes |
| 15 | Download | 5 | 5 | 90.2 % | Yes |
| 16 | Camera | 0 (Fist/None) | 0 (Fist/None) | 97.2 % | Yes |
| 17 | Gallery | 0 (Fist/None) | 0 (Fist/None) | 95.0 % | Yes |
| 18 | Download | 0 (Fist/None) | 0 (Fist/None) | 92.4 % | Yes |

- **Accuracy**: 100% (18 / 18)
- **Weakest Gesture**: Gesture `3` and `4` (overlapping adjacent finger configurations).
