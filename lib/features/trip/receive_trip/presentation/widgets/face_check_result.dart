import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/painting.dart';

enum FaceCheckResult {
  ok,
  noFace,
  multipleFaces,
  tooSmall,
  notFrontal,
  eyesClosed,
  failed,
}

class FaceValidator {
  FaceValidator()
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.accurate,
            enableClassification: true, // عشان eye open probability
            minFaceSize: 0.15,
          ),
        );

  final FaceDetector _detector;

  Future<FaceCheckResult> validate(String path) async {
    try {
      final faces =
          await _detector.processImage(InputImage.fromFilePath(path));

      if (faces.isEmpty) return FaceCheckResult.noFace;
      if (faces.length > 1) return FaceCheckResult.multipleFaces;

      final face = faces.first;

      // 1) حجم الوجه نسبةً للصورة (المساحة مش بتتأثر بتدوير الصورة)
      final bytes = await File(path).readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      final imageArea = decoded.width * decoded.height;
      decoded.dispose();

      final box = face.boundingBox;
      final faceRatio = (box.width * box.height) / imageArea;
      if (faceRatio < 0.08) return FaceCheckResult.tooSmall;

      // 2) الوجه لازم يكون مواجه الكاميرا
      final yaw = face.headEulerAngleY ?? 0;
      final pitch = face.headEulerAngleX ?? 0;
      final roll = face.headEulerAngleZ ?? 0;
      if (yaw.abs() > 25 || pitch.abs() > 25 || roll.abs() > 30) {
        return FaceCheckResult.notFrontal;
      }

      // 3) العينين مش مقفولين
      final left = face.leftEyeOpenProbability;
      final right = face.rightEyeOpenProbability;
      if (left != null && right != null && left < 0.3 && right < 0.3) {
        return FaceCheckResult.eyesClosed;
      }

      return FaceCheckResult.ok;
    } catch (e) {
      debugPrint('Face validation failed: $e');
      return FaceCheckResult.failed;
    }
  }

  Future<void> dispose() => _detector.close();
}