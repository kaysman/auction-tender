import 'dart:async';
import 'package:maliye_app/config/constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestUtil {
  static RequestUtil _instance = RequestUtil._internal();
  factory RequestUtil() => _instance;

  Dio dio;

  RequestUtil._internal() {
    /// BaseOptions、Options、RequestOptions
    /// All parameters can be configured, the priority
    /// level increases sequentially, and the parameters
    /// can be overridden according to the priority level
    BaseOptions options = new BaseOptions(
      // Request base address, can include subpath
      // baseUrl: SERVER_API_URL,
      //The timeout period for connecting to the server, in milliseconds.
      connectTimeout: 20000,

      // The interval between two received data on the
      // response stream, in milliseconds.
      receiveTimeout: 5000,

      // Http request header.
      headers: {},

      /// The requested Content-Type, the default value is
      /// "application/json; charset=utf-8".
      /// If you want to encode request data in
      /// "application/x-www-form-urlencoded" format,
      /// You can set this option to `Headers.formUrlEncodedContentType`,
      /// so that [Dio] will automatically encode the request body.
      contentType: 'application/json; charset=utf-8',

      /// [responseType] Indicates that the format (method)
      /// is expected to receive the response data.
      /// Currently [ResponseType] Three types accepted `JSON`, `STREAM`, `PLAIN`.
      ///
      /// The default value is `JSON`, When the content-type in the
      /// response header is "application/json", dio will
      /// automatically convert the response content into a json object.
      /// If you want to receive the response data in binary mode,
      /// such as downloading a binary file, you can use `STREAM`.
      ///
      /// If you want to receive the response data in text
      /// (string) format, please use `PLAIN`.
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    // Add interceptor
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      // Do something before the request is sent
      return options.data; //continue
    }, onResponse: (Response response) {
      // Do some preprocessing before returning the response data
      return response.data; // continue
    }, onError: (DioError e) {
      // Do some preprocessing when the request fails
      print(createErrorEntity(e));
    }));
  }

  /*
   * Get token
   */
  getAuthorizationHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('token');
  }

  /// get operating
  Future get(
    String path, {
    dynamic params,
    Options options,
  }) async {
    try {
      Options requestOptions = options ?? Options();

      /// The following three lines of code are the
      /// operation of obtaining the token and then merging it into the header
      // Map<String, dynamic> _authorization = {"token": getAuthorizationHeader()};
      // if (_authorization != null) {
      //   requestOptions = requestOptions.merge(headers: _authorization);
      // }
      var response = await dio.get(
        path,
        queryParameters: params,
        options: requestOptions,
      );

      return response.data;
    } on DioError catch (e) {
      throw e;
    }
  }

  ///  post operating
  Future post(String path, {dynamic params, Options options}) async {
    try {
      Options requestOptions = options ?? Options();

      /// The following three lines of code are the
      /// operation of obtaining the token and then merging it into the header
      // Map<String, dynamic> _authorization = getAuthorizationHeader();
      // if (_authorization != null) {
      //   requestOptions = requestOptions.merge(headers: _authorization);
      // }
      var response = await dio.post(
        path,
        data: params,
        options: requestOptions,
      );
      return response.data;
    } on DioError catch (e) {
      throw e;
    }
  }

  ///  put operating
  Future put(String path, {dynamic params, Options options}) async {
    Options requestOptions = options ?? Options();
    // TODO: add try catch
    /// The following three lines of code are the
    /// operation of obtaining the token and then merging it into the header
    // Map<String, dynamic> _authorization = getAuthorizationHeader();
    // if (_authorization != null) {
    //   requestOptions = requestOptions.merge(headers: _authorization);
    // }
    var response = await dio?.put(path, data: params, options: requestOptions);
    return response?.data;
  }

  ///  patch operating
  Future patch(String path, {dynamic params, Options options}) async {
    Options requestOptions = options ?? Options();

    /// The following three lines of code are the
    /// operation of obtaining the token and then merging it into the header
    // Map<String, dynamic> _authorization = getAuthorizationHeader();
    // if (_authorization != null) {
    //   requestOptions = requestOptions.merge(headers: _authorization);
    // }
    var response =
        await dio?.patch(path, data: params, options: requestOptions);
    return response?.data;
  }

  /// delete operating
  Future delete(String path, {dynamic params, Options options}) async {
    Options requestOptions = options ?? Options();

    /// The following three lines of code are the
    /// operation of obtaining the token and then merging it into the header
    // Map<String, dynamic> _authorization = getAuthorizationHeader();
    // if (_authorization != null) {
    //   requestOptions = requestOptions.merge(headers: _authorization);
    // }
    var response =
        await dio?.delete(path, data: params, options: requestOptions);
    return response?.data;
  }

  ///  post form Form submission operation
  Future postForm(String path, {dynamic params, Options options}) async {
    Options requestOptions = options ?? Options();
    // TODO: add try catch
    /// The following three lines of code are the
    /// operation of obtaining the token and then merging it into the header
    // Map<String, dynamic> _authorization = getAuthorizationHeader();
    // if (_authorization != null) {
    //   requestOptions = requestOptions.merge(headers: _authorization);
    // }
    var response = await dio?.post(path,
        data: FormData.fromMap(params), options: requestOptions);
    return response?.data;
  }
}

// Error message
ErrorEntity createErrorEntity(DioError error) {
  switch (error?.type) {
    case DioErrorType.CANCEL:
      {
        return ErrorEntity(code: -1, message: "Request cancellation");
      }
      break;
    case DioErrorType.CONNECT_TIMEOUT:
      {
        return ErrorEntity(code: -1, message: "Connection timed out");
      }
      break;
    case DioErrorType.SEND_TIMEOUT:
      {
        return ErrorEntity(code: -1, message: "Request timed out");
      }
      break;
    case DioErrorType.RECEIVE_TIMEOUT:
      {
        return ErrorEntity(code: -1, message: "Response timeout");
      }
      break;
    case DioErrorType.RESPONSE:
      {
        try {
          int errCode = error.response.statusCode;
          // String errMsg = error.response.statusMessage;
          // return ErrorEntity(code: errCode, message: errMsg);
          switch (errCode) {
            case 400:
              {
                return ErrorEntity(
                    code: errCode, message: "Request syntax error");
              }
              break;
            case 401:
              {
                return ErrorEntity(code: errCode, message: "Permission denied");
              }
              break;
            case 403:
              {
                return ErrorEntity(
                    code: errCode, message: "Server refused to execute");
              }
              break;
            case 404:
              {
                return ErrorEntity(
                    code: errCode, message: "can not connect to the server");
              }
              break;
            case 405:
              {
                return ErrorEntity(
                    code: errCode, message: "Request method is forbidden");
              }
              break;
            case 500:
              {
                return ErrorEntity(
                    code: errCode, message: "Server internal error");
              }
              break;
            case 502:
              {
                return ErrorEntity(code: errCode, message: "Invalid request");
              }
              break;
            case 503:
              {
                return ErrorEntity(code: errCode, message: "Server is down");
              }
              break;
            case 505:
              {
                return ErrorEntity(
                    code: errCode,
                    message: "Does not support HTTP protocol request");
              }
              break;
            default:
              {
                // return ErrorEntity(code: errCode!, message: "unknown mistake");
                return ErrorEntity(
                    code: errCode, message: error.response.statusMessage);
              }
          }
        } on Exception catch (_) {
          return ErrorEntity(code: -1, message: "unknown mistake");
        }
      }
      break;
    default:
      {
        return ErrorEntity(code: -1, message: error.message);
      }
  }
}

// Exception handling
class ErrorEntity implements Exception {
  int code;
  String message;
  ErrorEntity({this.code, this.message});

  String toString() {
    if (message == null) return "Exception";
    return "Exception: code $code, $message";
  }
}
