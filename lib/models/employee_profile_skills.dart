class Skill {
  String? name;

  Skill({this.name});
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['service_name'].toString(),
    );
  }
}
