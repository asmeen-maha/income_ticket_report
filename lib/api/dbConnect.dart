import 'dart:convert';
import 'package:dio/dio.dart';
import '../model/mdPayType.dart';
import '../model/mdSale.dart';
import '../model/mdSearchCreditPayAdvance.dart';
import '../model/mdTransaction.dart';

class Dbconnect {
  String domain = "http://172.2.100.101/cmfrontapp/ticketing/ticketapi/datamodule/mainlib.php";
  String domain1 = 'http://172.2.100.14/clientele_cm/marketing.php';
  String domain2 = 'http://172.2.200.200/cmfrontapp/ticketing/ticketapi/datamodule/selfticketing.php';

  Future<List<Transaction>?> dataTransactionAll({required String date}) async {
    FormData formData = FormData.fromMap({
      "param": "reportpaymentall",
      "showdate": date, //2025-02-10
    });
    try {
      var response = await Dio().post(domain2, data: formData);
      if (response.statusCode == 200) {
        var dataTransactionAll = Transaction.fromJsonList(response.data);
        // print('dataTransactionAll ${response.data}');
        return dataTransactionAll;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<List<PayType>?> payTypeList() async {
    FormData formData = FormData.fromMap({
      "param": "listtypepay",
    });
    try {
      var response = await Dio().post(domain1, data: formData);
      if (response.statusCode == 200) {
        var paytype = PayType.fromJsonList(response.data);
        // print('rsvnData ok! ${response.data}');
        return paytype;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<List<Sale>?> getSaleReport({required String showdate}) async {
    FormData formData = FormData.fromMap({
      "param": "listuser",
      "showdate": showdate
    });
    try {
      Response response = await Dio().post(domain2, data: formData);
      if(response.statusCode == 200) {
        var sale = Sale.fromJsonList(response.data);
        // print(response.data);
        print('saleList ok!');
        return sale;
      }  
    } catch (e) {
      print(e); 
    }
    return null;
  }

  Future<List<Transaction>?> dataTransaction({required String date, required String userid}) async {
    FormData formData = FormData.fromMap({
      "param": "reportpayment",
      "showdate": date, //2025-02-10
      "userid": userid //11960
    });
    try {
      var response = await Dio().post(domain2, data: formData);
      if (response.statusCode == 200) {
        var incomReport = Transaction.fromJsonList(response.data);
        // print('incomReport ok! ${response.data}');
        return incomReport;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<List<AdvCredit>?> dataAdvCreditOnly({required String userId, required String bookDate}) async {
    FormData formData = FormData.fromMap({
      "param": "listcus",
      "userid": userId,
      "bookdate": bookDate
    });
    try {
      var response = await Dio().post(domain1, data: formData);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.data);
        var advCreditData = AdvCredit.fromJsonList(decodedData);
        // print('advCreditData ok! ${response.data}');
        return advCreditData;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<dynamic> savepayment({required dynamic notes, required String salecode, required String saledate, required dynamic payeshop, required String creditcard}) async {
    FormData formData = FormData.fromMap({
      "param": "savepayment",
      "token": '',
      "notedata": jsonEncode(notes),
      "eshop": jsonEncode(payeshop),
      "salecode": salecode,
      "saledate": saledate,
      "creditcard": creditcard,
    });
    Response response = await Dio().post(domain, data: formData);
    // print(response.data);
    return "Y";
  }

  Future<dynamic> saveCurrency({required dynamic data}) async {
    FormData formData = FormData.fromMap({
      "param": "savecurrency",
      "data": jsonEncode(data)
    });
    print('saveCredit: ${formData.fields}');
    Response response = await Dio().post(domain1, data: formData);
    // print(response.data);
    return "Y";
  }
}