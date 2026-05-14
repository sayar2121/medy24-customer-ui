import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class MedicineService {
  final Dio _dio = Dio();

  MedicineService() {
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

  Future<Response> getAllMedicines({int page = 1, int limit = 20}) async {
    try {
      return await _dio.get(
        ApiUrl.getMedicineAll,
        queryParameters: {'page': page, 'limit': limit},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMedicineById(String id) async {
    try {
      return await _dio.get(ApiUrl.getMedicineById(id));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> searchMedicines(String query, {int page = 1, int limit = 20}) async {
    try {
      return await _dio.get(
        ApiUrl.searchMedicines,
        queryParameters: {'query': query, 'page': page, 'limit': limit},
      );
    } catch (e) {
      rethrow;
    }
  }
}
