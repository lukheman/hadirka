import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_exception.dart';


class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: ApiConstants.timeoutDuration,
        receiveTimeout: ApiConstants.timeoutDuration,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.baseUrl = ApiConstants.baseUrl;
        
        
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.keyAuthToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        return handler.next(options);
      },
    ));

    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[API] $obj'),
      ));
    }
  }

  
  dynamic _handleResponse(Response response) {
    if (response.data is Map && response.data['success'] != null) {
      if (response.data['success'] == true) {
        return response.data['data'] ?? response.data;
      } else {
        throw ApiException(response.data['message'] ?? 'Terjadi kesalahan dari server');
      }
    }
    return response.data;
  }

  
  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      ApiConstants.resetCustomUrl();
      final host = e.requestOptions.uri.host;
      return NetworkException(
        'Koneksi ke $host timeout/gagal. Server IP otomatis di-reset ke IP default (${ApiConstants.baseUrl}). Silakan coba lagi.',
      );
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      String message = 'Terjadi kesalahan pada server';
      
      if (data is Map && data['message'] != null) {
        message = data['message'];
      }

      if (statusCode == 401 || statusCode == 403) {
        return UnauthorizedException(message);
      }
      if (statusCode != null && statusCode >= 500) {
        return ServerException(message);
      }
      return ApiException(message, statusCode: statusCode);
    }
    
    return ApiException('Terjadi kesalahan yang tidak terduga: ${e.message}');
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
