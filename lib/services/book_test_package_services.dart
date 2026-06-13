import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/test_package_booking.dart';
import 'api_url.dart';

class BookTestPackageService {
  final Dio _dio = Dio();

  BookTestPackageService() {
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
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

  Future<BookingResponse> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _dio.post(
        ApiUrl.createTestPackageBooking,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return BookingResponse.fromJson(data);
      }
      throw 'Invalid booking response';
    } on DioException catch (e) {
      final detail = e.response?.data;
      if (detail is Map && detail['detail'] != null) {
        throw detail['detail'].toString();
      }
      throw e.response?.data?['message'] ??
          e.message ??
          'Failed to create booking';
    }
  }
}
