import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class AuthService {
  final Dio _dio = Dio();

  AuthService() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  Future<Response> checkPhone(String phoneNumber) async {
    try {
      return await _dio.post(
        ApiUrl.checkPhone,
        data: {'phone_number': phoneNumber},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendOtp(String phoneNumber) async {
    try {
      return await _dio.post(
        ApiUrl.sendOtp,
        data: {'phone_number': phoneNumber},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> verifyOtp({
    required String token,
    required String phoneNumber,
    String? fullName,
    String? email,
    String? alternativePhoneNo,
    List<dynamic>? savedAddresses,
    File? profilePhoto,
  }) async {
    try {
      // Backend expects Form data (multipart/form-data) for all fields
      final formDataMap = <String, dynamic>{
        'token': token,
        'phone_number': phoneNumber,
      };

      if (fullName != null) formDataMap['full_name'] = fullName;
      if (email != null) formDataMap['email'] = email;
      if (alternativePhoneNo != null) {
        formDataMap['alternative_phone_no'] = alternativePhoneNo;
      }
      if (savedAddresses != null) {
        formDataMap['saved_addresses'] = savedAddresses;
      }

      if (profilePhoto != null) {
        formDataMap['profile_photo'] = await MultipartFile.fromFile(
          profilePhoto.path,
          filename: profilePhoto.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);
      return await _dio.post(ApiUrl.verifyOtp, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfile(String customerId) async {
    try {
      return await _dio.get(ApiUrl.getProfile(customerId));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile({
    required String customerId,
    String? fullName,
    String? email,
    String? alternativePhoneNo,
    File? profilePhoto,
  }) async {
    try {
      final formDataMap = <String, dynamic>{};
      if (fullName != null) formDataMap['full_name'] = fullName;
      if (email != null) formDataMap['email'] = email;
      if (alternativePhoneNo != null) {
        formDataMap['alternative_phone_no'] = alternativePhoneNo;
      }
      if (profilePhoto != null) {
        formDataMap['profile_photo'] = await MultipartFile.fromFile(
          profilePhoto.path,
          filename: profilePhoto.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);
      return await _dio.put(ApiUrl.updateProfile(customerId), data: formData);
    } catch (e) {
      rethrow;
    }
  }
}
