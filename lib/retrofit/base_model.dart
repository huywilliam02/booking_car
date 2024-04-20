import 'package:citgroupvn_carwash/retrofit/server_error.dart';

class BaseModel<T> {
  late ServerError error;
  T? data;

  setException(ServerError error) {
    this.error = error;
  }

  setData(T data) {
    this.data = data;
  }
}
