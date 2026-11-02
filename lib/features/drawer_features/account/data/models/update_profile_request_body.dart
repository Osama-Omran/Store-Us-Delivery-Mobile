
import 'dart:io';

import 'package:dio/dio.dart';

class UpdateProfileRequestBody {
  const UpdateProfileRequestBody({
    this.firstName,
    this.lastName,
    this.phone,
    this.photo,
  });

  final String? firstName;
  final String? lastName;
  final String? phone;
  final File? photo;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) {
      data['first_name'] = firstName;
    }

    if (lastName != null) {
      data['last_name'] = lastName;
    }

    if (phone != null) {
      data['phone'] = phone;
    }

    return data;
  }

  Future<FormData> toFormData() async {
    final formData = FormData.fromMap(toJson());

    if (photo != null) {
      formData.files.add(
        MapEntry(
          'photo',
          await MultipartFile.fromFile(
            photo!.path,
          ),
        ),
      );
    }

    return formData;
  }
}
