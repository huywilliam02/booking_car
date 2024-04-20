class ViewAppointmentService {
  var serviceId;
  var serviceName;
  var servicePrice;
  var serviceDuration;
  var serviceRate;
  var serviceDiscription;
  ViewAppointmentService(
      {this.serviceId,
      this.serviceName,
      this.servicePrice,
      this.serviceDuration,
      this.serviceRate,
      this.serviceDiscription});
  factory ViewAppointmentService.fromJson(Map<String, dynamic> json) {
    return ViewAppointmentService(
      serviceId: json['id'],
      serviceName: json['service_name'],
      servicePrice: json['price'],
      serviceDuration: json['duration'],
      serviceRate: json['rate'],
      serviceDiscription: json['description'],
    );
  }
}
