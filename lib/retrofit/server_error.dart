import 'package:dio/dio.dart' hide Headers;
import 'package:fluttertoast/fluttertoast.dart';

class ServerError implements Exception {
  int? _errorCode;
  String _errorMessage = "";

  ServerError.withError({error}) {
    _handleError(error);
  }

  int? getErrorCode() {
    return _errorCode;
  }

  String getErrorMessage() {
    return _errorMessage;
  }

  void _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
        _errorMessage = "Connection timeout";
        Fluttertoast.showToast(
            msg: 'Connection timeout',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        break;
      case DioErrorType.sendTimeout:
        _errorMessage = "Receive timeout in send request";
        Fluttertoast.showToast(
            msg: 'Receive timeout in send request',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        break;
      case DioErrorType.receiveTimeout:
        _errorMessage = "Receive timeout in connection";
        Fluttertoast.showToast(
            msg: 'Receive timeout in connection',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        break;
      case DioErrorType.badResponse:
        _errorMessage = "Received invalid status code: ${error.response!.data}";
        try {
          if (error.response!.data['errors'] != null) {
            if (error.response!.data['errors']['name'] != null) {
              Fluttertoast.showToast(
                  msg: '${error.response!.data['errors']['name'][0]}',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
              return;
            } else if (error.response!.data['errors']['phone'] != null) {
              Fluttertoast.showToast(
                  msg: '${error.response!.data['errors']['phone'][0]}',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
              return;
            } else if (error.response!.data['errors']['email_id'] != null) {
              Fluttertoast.showToast(
                  msg: '${error.response!.data['errors']['email_id'][0]}',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
              return;
            } else if (error.response!.data != null) {
              Fluttertoast.showToast(
                  msg: '${error.response!.data}',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
              return;
            } else {
              Fluttertoast.showToast(
                  msg: '${error.response!.data['message'].toString()}',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
              return;
            }
          }
        } catch (error1, stacktrace) {
          Fluttertoast.showToast(
              msg: 'Exception occurred',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM);
          print(
              "Exception occurred: $error stackTrace: $stacktrace apiError: ${error.response!.data}");
        }
        break;
      case DioErrorType.cancel:
        _errorMessage = "Request was cancelled";
        Fluttertoast.showToast(
            msg: 'Request was cancelled',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        break;
      // case DioErrorType.other:
      //   _errorMessage = "Connection failed. Please check internet connection";
      //   Fluttertoast.showToast(
      //       msg: 'Connection failed. Please check internet connection',
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.BOTTOM);
      //   break;
      // Handle DioExceptionType.badCertificate
      case DioErrorType.badCertificate:
        _errorMessage = "Bad certificate. Please check SSL configuration";
        Fluttertoast.showToast(
            msg: 'Bad certificate. Please check SSL configuration',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        break;
      default:
        _errorMessage = "An unexpected error occurred";
        Fluttertoast.showToast(
            msg: 'An unexpected error occurred',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        break;
    }
  }
}
