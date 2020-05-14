class EmailMessageV1 {
  String from;
  String cc;
  String bcc;
  String to;
  String reply_to;
  dynamic subject;
  dynamic text;
  dynamic html;

  EmailMessageV1();

  EmailMessageV1.from(this.from, this.cc, this.bcc, this.to, this.reply_to, this.subject, this.text, this.html);

	void fromJson(Map<String, dynamic> json)
	{
		from = json['from'];
		cc = json['cc'];
		bcc = json['bcc'];
		to = json['to'];
		reply_to = json['reply_to'];
		subject = json['subject'];
		text = json['text'];
		html = json['html'];
	}

	Map<String, dynamic> toJson()
	{
		return <String, dynamic>
		{
			'from': from,
      'cc' : cc,
			'bcc': bcc,
      'to' : to,
      'reply_to' : reply_to,
      'subject' : subject,
      'text' : text,
      'html' : html
		};
	}
}
