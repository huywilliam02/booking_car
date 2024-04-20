class Faq {
  var question;
  var answer;
  Faq({this.question, this.answer});
  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
        question: json['question'].toString(),
        answer: json['answer'].toString());
  }
}
