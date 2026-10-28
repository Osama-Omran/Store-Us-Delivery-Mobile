import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

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

  // Top-level so it can run in an isolate via compute()
  String? _normalizeImageJob(List<String> paths) {
    final decoded = imglib.decodeImage(File(paths[0]).readAsBytesSync());
    if (decoded == null) return null;

    final baked = imglib.bakeOrientation(decoded);
    File(paths[1]).writeAsBytesSync(imglib.encodeJpg(baked, quality: 90));
    return paths[1];
  }

  Future<FaceCheckResult> validate(String path) async {
    String? tempPath;
    try {
      var workingPath = path;

      if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        final out =
            '${dir.path}/face_${DateTime.now().millisecondsSinceEpoch}.jpg';
        tempPath = await compute(_normalizeImageJob, [path, out]);
        if (tempPath == null) return FaceCheckResult.failed;
        workingPath = tempPath;
      }

      final bytes = await File(workingPath).readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      final imageArea = decoded.width * decoded.height;
      debugPrint(
        'Face check input: ${decoded.width}x${decoded.height}, ${(bytes.length / 1e6).toStringAsFixed(2)} MB',
      );
      decoded.dispose();

      final faces = await _detector.processImage(
        InputImage.fromFilePath(workingPath),
      );
      debugPrint('Faces found: ${faces.length}');

      if (faces.isEmpty) return FaceCheckResult.noFace;
      if (faces.length > 1) return FaceCheckResult.multipleFaces;

      final face = faces.first;

      // 1) Face size relative to the image
      final box = face.boundingBox;
      final faceRatio = (box.width * box.height) / imageArea;
      if (faceRatio < 0.08) return FaceCheckResult.tooSmall;

      // 2) Face must be facing the camera
      final yaw = face.headEulerAngleY ?? 0;
      final pitch = face.headEulerAngleX ?? 0;
      final roll = face.headEulerAngleZ ?? 0;
      if (yaw.abs() > 25 || pitch.abs() > 25 || roll.abs() > 30) {
        return FaceCheckResult.notFrontal;
      }

      // 3) Eyes not closed
      final left = face.leftEyeOpenProbability;
      final right = face.rightEyeOpenProbability;
      if (left != null && right != null && left < 0.3 && right < 0.3) {
        return FaceCheckResult.eyesClosed;
      }

      return FaceCheckResult.ok;
    } finally {
      // Clean up the temporary normalized copy
      if (tempPath != null) {
        try {
          await File(tempPath).delete();
        } catch (_) {}
      }
    }
  }

  Future<void> dispose() => _detector.close();
}
