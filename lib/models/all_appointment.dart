class AllAppointmentData {
  String? date, time, amount;
  int? id;
  AllAppointmentData({
    this.date,
    this.time,
    this.amount,
    this.id,
  });
  factory AllAppointmentData.fromJson(Map<String, dynamic> json) {
    return AllAppointmentData(
      date: json['date'],
      time: json['start_time'],
      amount: json['amount'],
      id: json['id'],
    );
  }
}

class AllAppointmentDataCoworker {
  String? name, image;
  AllAppointmentDataCoworker({
    this.name,
    this.image,
  });
  factory AllAppointmentDataCoworker.fromJson(Map<String, dynamic> json) {
    return AllAppointmentDataCoworker(
      name: json['name'],
      image: json['completeImage'],
    );
  }
}

class AllAppointmentDataService {
  String? serviceName;
  AllAppointmentDataService({this.serviceName});
  factory AllAppointmentDataService.fromJson(Map<String, dynamic> json) {
    return AllAppointmentDataService(
      serviceName: json['service_name'],
    );
  }
}
