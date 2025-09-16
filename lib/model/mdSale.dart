class Sale {
  String? userid;
  String? code;
  String? name;

  Sale({this.userid, this.code, this.name});

  Sale.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
  static List<Sale>? fromJsonList(List list) => list.map((item) => Sale.fromJson(item)).toList();
}
