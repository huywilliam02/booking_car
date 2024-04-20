import 'package:citgroupvn_carwash/Const/prefConstatnt.dart';
import 'package:citgroupvn_carwash/Const/preference.dart';
import 'package:dio/dio.dart';

class RetroApi {
  Dio dioData() {
    final dio = Dio();
    dio.options.headers["Accept"] =
        "application/json"; // config your dio headers globally

    dio.options.headers["Authorization"] =
        "Bearer ${SharedPreferenceHelper.getString(Preferences.auth_token)}";

    dio.options.followRedirects = false;
    dio.options.connectTimeout = Duration(seconds: 75000); //5ss
    dio.options.receiveTimeout = Duration(seconds: 3000);
    return dio;
  }
}
