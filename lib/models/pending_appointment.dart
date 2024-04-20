class PendingAppointment {
  String? date, time, amount;
  int? id;
  PendingAppointment({
    this.date,
    this.time,
    this.amount,
    this.id,
  });
  factory PendingAppointment.fromJson(Map<String, dynamic> json) {
    return PendingAppointment(
      date: json['date'],
      time: json['start_time'],
      amount: json['amount'],
      id: json['id'],
    );
  }
}

class PendingAppointmentCoworker {
  String? name, image;
  PendingAppointmentCoworker({
    this.name,
    this.image,
  });
  factory PendingAppointmentCoworker.fromJson(Map<String, dynamic> json) {
    return PendingAppointmentCoworker(
      name: json['name'],
      image: json['completeImage'],
    );
  }
}

class PendingAppointmentService {
  String? serviceName;
  PendingAppointmentService({this.serviceName});
  factory PendingAppointmentService.fromJson(Map<String, dynamic> json) {
    return PendingAppointmentService(
      serviceName: json['service_name'],
    );
  }
}
