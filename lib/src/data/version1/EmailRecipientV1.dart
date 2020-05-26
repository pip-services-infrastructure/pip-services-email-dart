class EmailRecipientV1 {
  String id;
  String name;
  String email;
  String language;

  EmailRecipientV1({String id, String name, String email, String language})
      : id = id,
        name = name,
        email = email,
        language = language;

  void fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    language = json['language'];
  }

  factory EmailRecipientV1.fromJson(Map<String, dynamic> json) {
    return EmailRecipientV1(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        language: json['language']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'language': language
    };
  }
}
