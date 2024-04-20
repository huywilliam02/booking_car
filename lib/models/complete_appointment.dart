class CompleteAppointment {
  String? date, time, amount;
  int? id;
  CompleteAppointment({
    this.date,
    this.time,
    this.amount,
    this.id,
  });
  factory CompleteAppointment.fromJson(Map<String, dynamic> json) {
    return CompleteAppointment(
      date: json['date'],
      time: json['start_time'],
      amount: json['amount'],
      id: json['id'],
    );
  }
}

class CompleteAppointmentCoworker {
  String? name, image;
  CompleteAppointmentCoworker({
    this.name,
    this.image,
  });
  factory CompleteAppointmentCoworker.fromJson(Map<String, dynamic> json) {
    return CompleteAppointmentCoworker(
      name: json['name'],
      image: json['completeImage'],
    );
  }
}

class CompleteAppointmentService {
  String? serviceName;
  CompleteAppointmentService({this.serviceName});
  factory CompleteAppointmentService.fromJson(Map<String, dynamic> json) {
    return CompleteAppointmentService(
      serviceName: json['service_name'],
    );
  }
}
