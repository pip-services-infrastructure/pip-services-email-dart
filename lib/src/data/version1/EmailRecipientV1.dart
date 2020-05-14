class EmailRecipientV1 {
  String id;
  String name;
  String email;
  String language;

  EmailRecipientV1();

  EmailRecipientV1.from(this.id, this.name, this.email, this.language);

	void fromJson(Map<String, dynamic> json)
	{
		id = json['id'];
		name = json['name'];
		email = json['email'];
		language = json['language'];
	}

	Map<String, dynamic> toJson()
	{
		return <String, dynamic>
		{
			'id': id,
      'name' : name,
			'email': email,
      'email' : email
		};
	}
}
