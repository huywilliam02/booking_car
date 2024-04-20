class BookingAppointmentService {
  var serviceId;
  var serviceName;
  var servicePrice;
  var serviceDuration;
  var serviceRate;
  var serviceDiscription;
  BookingAppointmentService(
      {this.serviceId,
      this.serviceName,
      this.servicePrice,
      this.serviceDuration,
      this.serviceRate,
      this.serviceDiscription});
  factory BookingAppointmentService.fromJson(Map<String, dynamic> json) {
    return BookingAppointmentService(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      servicePrice: json['service_price'],
      serviceDuration: json['service_duration'],
      serviceRate: json['service_rate'],
      serviceDiscription: json['service_description'],
    );
  }
}
