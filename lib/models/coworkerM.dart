class CoworkerModel {
  int? id;
  String? name,
      image,
      email,
      phone,
      startTime,
      endTime,
      experience,
      description,
      updatedAt,
      createdAt;
  int? status;
  double? rating;
  CoworkerModel({
    this.id,
    this.name,
    this.image,
    this.email,
    this.phone,
    this.startTime,
    this.endTime,
    this.experience,
    this.description,
    this.createdAt,
    this.status,
    this.updatedAt,
    this.rating,
  });

  factory CoworkerModel.fromJson(Map<String, dynamic> json) {
    return CoworkerModel(
      id: json['id'],
      name: json['name'].toString(),
      image: json['completeImage'].toString(),
      email: json['email'].toString(),
      phone: json['phone'].toString(),
      startTime: json['start_time'].toString(),
      endTime: json['end_time'].toString(),
      experience: json['experience'].toString(),
      description: json['description'].toString(),
      createdAt: json['created_at'].toString(),
      status: json['status'],
      updatedAt: json['updated_at'].toString(),
      rating: json['rate'] != null ? double.parse(json['rate'].toString()) : 0.0,
    );
  }
}
