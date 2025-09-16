class AdvCredit {
  String? id;
  String? rsvn;
  String? agentcode;
  String? agentname;
  String? paytype;
  String? amount;
  String? accode;
  String? bookdate;
  String? edit;

  AdvCredit(
      {this.id,
      this.rsvn,
      this.agentcode,
      this.agentname,
      this.paytype,
      this.amount,
      this.accode,
      this.bookdate,
      this.edit});

  AdvCredit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rsvn = json['rsvn'];
    agentcode = json['agentcode'];
    agentname = json['agentname'];
    paytype = json['paytype'];
    amount = json['amount'];
    accode = json['accode'];
    bookdate = json['bookdate'];
    // edit = '1';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rsvn'] = rsvn;
    data['agentcode'] = agentcode;
    data['agentname'] = agentname;
    data['paytype'] = paytype;
    data['amount'] = amount;
    data['accode'] = accode;
    data['bookdate'] = bookdate;
    return data;
  }
  static List<AdvCredit>? fromJsonList(List list) =>list.map((item) => AdvCredit.fromJson(item)).toList();
}