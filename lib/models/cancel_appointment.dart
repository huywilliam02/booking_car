class CancelAppointment {
  String? date, time, amount;
  int? id;
  CancelAppointment({
    this.date,
    this.time,
    this.amount,
    this.id,
  });
  factory CancelAppointment.fromJson(Map<String, dynamic> json) {
    return CancelAppointment(
      date: json['date'],
      time: json['start_time'],
      amount: json['amount'],
      id: json['id'],
    );
  }
}

class CancelAppointmentCoworker {
  String? name, image;
  CancelAppointmentCoworker({
    this.name,
    this.image,
  });
  factory CancelAppointmentCoworker.fromJson(Map<String, dynamic> json) {
    return CancelAppointmentCoworker(
      name: json['name'],
      image: json['completeImage'],
    );
  }
}

class CancelAppointmentService {
  String? serviceName;
  CancelAppointmentService({this.serviceName});
  factory CancelAppointmentService.fromJson(Map<String, dynamic> json) {
    return CancelAppointmentService(
      serviceName: json['service_name'],
    );
  }
}
