class TransactionSumAll {
  List<Creditcard>? creditcard;
  List<Notesandcoinss>? notesandcoins;
  List<Payeshop>? payeshop;

  TransactionSumAll({this.creditcard, this.notesandcoins, this.payeshop});

  TransactionSumAll.fromJson(Map<String, dynamic> json) {
    if (json['creditcard'] != null) {
      creditcard = <Creditcard>[];
      json['creditcard'].forEach((v) {
        creditcard!.add(Creditcard.fromJson(v));
      });
    }
    if (json['notesandcoins'] != null) {
      notesandcoins = <Notesandcoinss>[];
      json['notesandcoins'].forEach((v) {
        notesandcoins!.add(Notesandcoinss.fromJson(v));
      });
    }
    if (json['payeshop'] != null) {
      payeshop = <Payeshop>[];
      json['payeshop'].forEach((v) {
        payeshop!.add(Payeshop.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (creditcard != null) {
      data['creditcard'] = creditcard!.map((v) => v.toJson()).toList();
    }
    if (notesandcoins != null) {
      data['notesandcoins'] =
          notesandcoins!.map((v) => v.toJson()).toList();
    }
    if (payeshop != null) {
      data['payeshop'] = payeshop!.map((v) => v.toJson()).toList();
    }
    return data;
  }
  static List<TransactionSumAll>? fromJsonList(List list) => list.map((item) => TransactionSumAll.fromJson(item)).toList();

}

class Creditcard {
  String? amount;

  Creditcard({this.amount});

  Creditcard.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    return data;
  }
}

class Notesandcoinss {
  String? ntype;
  String? amount;
  String? qty;

  Notesandcoinss({this.ntype, this.amount});

  Notesandcoinss.fromJson(Map<String, dynamic> json) {
    ntype = json['ntype'];
    amount = json['amount'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ntype'] = ntype;
    data['amount'] = amount;
    data['qty'] = qty;
    return data;
  }
}

class Payeshop {
  String? amount;

  Payeshop({this.amount});

  Payeshop.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    return data;
  }
}
