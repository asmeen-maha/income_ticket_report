import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:income_report/model/mdSale.dart';
import 'package:income_report/model/mdSearchCreditPayAdvance.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:printing/printing.dart';
import '../api/dbConnect.dart';
import '../font/appColor.dart';
import '../font/appFonts.dart';
import '../model/mdPayType.dart';
import '../model/mdTransaction.dart';
import '../model/mdTransactionSumAll.dart';
import '../report/dailyIncomeStatement.dart';
import '../report/incomeReportA4LandscapeOnly.dart';
import '../util/dateformat.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> coins = ['1000.00', '500.00', '100.00', '50.00', '20.00', '10.00', '5.00', '2.00', '1.00', '0.50', '0.25'];

  final TextEditingController _dateController = TextEditingController(text: dateformat(date: DateTime.now(), type: "dsn"));
  final TextEditingController _creditController = TextEditingController(text: '0.00');
  final TextEditingController _eshopController = TextEditingController(text: '0.00');
  late List<TextEditingController> quantityCoinsControllers;
  late List<bool> _checkList = [];
  late Sale _seller;

  List<Sale> _saleList = [];
  List<PayType> _payTypeData = [];
  List<AdvCredit> _creditDataOnly = [];
  List<AdvCredit> _advDataOnly = [];

  //coins
  List<Map<String, dynamic>> coinsDataNew = [];

  //eshop
  // List<Map<String, dynamic>> eshopDataNew = [];
  Map<String, dynamic> eshopDataNew = {};

  //TransactionOnly
  List<Transaction> _transactionOnly = [];

  //TransactionSumAll
  List<TransactionSumAll> _transactionSumAll = [];

  // List<CashAdvance> _creditDataReport = [];
  // List<CashAdvance> _advDataReport = [];
  
  DateTime? selectedDate;
  bool _reportload = false;
  bool _saleload = false;
  bool _transactionLoad = false;
  Uint8List? _report;

  String _saleCode = '';
  String _title = '';

  //coin
  List<Notesandcoins> coinsData = [];
  double sumAmtNotes = 0.0;
  double previousSumAmtNotes = 0.0;
  double sumAmtAll = 0.0;

  //credit
  double previousCreditAmount = 0.0;
  double creditTotal = 0.0;

  //eshop
  double sumAmtEshop = 0.0;
  double previousEshopAmount = 0.0;
  double payEshopTotal = 0.0;

  final Map<String, Map<String, double>> notesMap = {};

  @override
  void initState() {
    super.initState();
    
    selectedDate = DateTime.now();
    quantityCoinsControllers = List.generate(coins.length, (_) => TextEditingController());
    _checkList = List.generate(coins.length, (_) => false);
    _dBPayType();
    _dBSale();
  }
  
  Future<void> _dBSale() async {
    await Dbconnect().getSaleReport(showdate: dateformat(date: selectedDate!, type: "db")).then((onValue) {
      if(onValue != null){
        setState(() {
          _saleList = onValue;
          _saleList.sort((a, b) => a.code!.compareTo(b.code!));

          _saleload = true;
        });
      }
    });
  }

  Future<void> _dBPayType() async {
    await Dbconnect().payTypeList().then((value) {
      if (value != null) {
        _payTypeData = value;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      barrierDismissible: false,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.pinkcm,
              onPrimary: Colors.white, 
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkPink,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = dateformat(date: picked, type: "dsn");
      });
      _saleCode = '';

      await _dBSale();
    }
  }

  /* Future<void> _dBTransactionAll() async {
    await Dbconnect().dataTransactionAll(date: dateformat(date: selectedDate!, type: "db")).then((value) {
      if(value != null) {
        _transactionAll = value;
        
        for (var data in _transactionAll) {
          // creditcard
          for (var c in data.creditcard as List) {
            creditTotal += double.tryParse(c.amount) ?? 0;
          }

          // notesandcoins
          for (var n in data.notesandcoins as List) {
            final ntype = n.ntype;
            final qty = double.tryParse(n.qty) ?? 0;
            final amount = double.tryParse(n.amount) ?? 0;

            notesMap.putIfAbsent(ntype, () => {"qty": 0.0, "amount": 0.0});
            notesMap[ntype]!["qty"] = (notesMap[ntype]!["qty"] ?? 0) + qty;
            notesMap[ntype]!["amount"] = (notesMap[ntype]!["amount"] ?? 0) + amount;
          }

          // payeshop
          for (var p in data.payeshop as List) {
            payEshopTotal += double.tryParse(p.amount) ?? 0;
          }
        }

        final jsonResponse = [
          {
            "creditcard": [
              {"amount": creditTotal.toStringAsFixed(2)}
            ],
            "notesandcoins": notesMap.entries.map((e) => {
                "ntype": e.key,
                "qty": e.value["qty"]!.toStringAsFixed(0),
                "amount": e.value["amount"]!.toStringAsFixed(2)
              }).toList(),
            "payeshop": [
              {"amount": payEshopTotal.toStringAsFixed(2)}
            ]
          }
        ];

        setState(() {
          _transactionSumAll = TransactionSumAll.fromJsonList(jsonResponse)!.toList();
          _transactionLoad = true;
        });

        /* print('Credit > ${_transactionSumAll[0].creditcard![0].amount}');
        print('pay Eshop > ${_transactionSumAll[0].payeshop![0].amount}');
        print('Coins > ${_transactionSumAll[0].notesandcoins![0].qty}');
        print('Coins > ${_transactionSumAll[0].notesandcoins![0].ntype}');
        print('Coins > ${_transactionSumAll[0].notesandcoins![0].amount}'); */

      } else {
        setState(() {
          _transactionLoad = false;
        });
      }
    });
  }*/
 
  Future<void> _dBTransactionOnly() async {
    await Dbconnect().dataTransaction(date: dateformat(date: selectedDate!, type: 'db'), userid: _seller.userid!).then((onValue) {
      if(onValue != null){
        _transactionOnly = onValue;

        //notesandcoins
        coinsData = onValue[0].notesandcoins!;
        if(coinsData.isNotEmpty){
          Map<String, String> qtyFromDb = {};
          // sumAmtNotes = coinsData.fold(0.0, (sum, item) => sum + (double.tryParse(item.amount ?? '0.0') ?? 0.0));
          for (var item in coinsData) {
            qtyFromDb[item.ntype!] = item.qty!;
          }
          for (int i = 0; i < coins.length; i++) {
            final noteValue = double.parse(coins[i]).toStringAsFixed(0);
            if (qtyFromDb.containsKey(noteValue)) {
              quantityCoinsControllers[i].text = qtyFromDb[noteValue] ?? '';
            } else {
              quantityCoinsControllers[i].text = '';
            }
          }
          // sumAmtAll += sumAmtNotes;
        } else {
          // sumAmtAll = 0.0;
          for (int i = 0; i < coins.length; i++) {
            quantityCoinsControllers[i].text = '';
          }
        }

        //credit Card
        double dbCredit = onValue[0].creditcard!.isNotEmpty ? double.parse(onValue[0].creditcard![0].amount ?? '0.0') : 0.0;
        _creditController.text = dbCredit.toStringAsFixed(2);
        previousCreditAmount = dbCredit;

        //eshop
        double sumAmteShop = onValue[0].payeshop!.isNotEmpty ? onValue[0].payeshop!.fold(0.0, (sum, item) => sum + (double.parse(item.amount ?? '0.0'))) : 0.0;
        _eshopController.text = sumAmteShop.toStringAsFixed(2);
        previousEshopAmount = sumAmteShop;
      }
    });
  }

  /* Future<void> _dBCredit() async {
    await Dbconnect().payAdvance(showdate: dateformat(date: selectedDate!, type: 'db')).then((onValue) {
      if(onValue != null){
        _advDataReport = onValue.where((item) => item.paytype == '4' && (double.tryParse(item.amount ?? '0.00') ?? 0.0) > 0.0).toList();
        _creditDataReport = onValue.where((item) => item.paytype == '2' && (double.tryParse(item.amount ?? '0.00') ?? 0.0) > 0.0).toList();

        // print('adv > $_advDataReport');
        // print('credit > $_creditDataReport');
      }
    }).onError((error, stackTrace) {
      print('Error occurred: $error');
      /* setState(() {
        _dataLoad = false;
      }); */
    });
  } */

  Future<void> _dBAdvCredit() async {
    await Dbconnect().dataAdvCreditOnly(userId: _seller.userid!, bookDate: dateformat(date: selectedDate!, type: "db")).then((value) {
      if (value != null) {
        setState(() {
          _creditDataOnly = value.where((item) => item.paytype == '2' && (double.tryParse(item.amount ?? '0.0') ?? 0.0) > 0).toList();
          _advDataOnly = value.where((item) => item.paytype == '4' && (double.tryParse(item.amount ?? '0.0') ?? 0.0) > 0).toList();
        });
      }
      /* for(var datas in _payAdvanceData) {
        print('payAdvanceData ok! ${datas.amount}');
      } */
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.pinkcm,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Income report', style: TextStyle(fontFamily: AppFonts.traJanPro, color: AppColors.white, fontSize: width * .011)),
            Text('V0.0.4', style: TextStyle(fontFamily: AppFonts.traJanPro, color: AppColors.white, fontSize: width * .008)),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container( //select date
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: height * .02, left: width * .01),
                child: SizedBox(
                  width: width * .15,
                  height: height * .05,
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        fontFamily: AppFonts.pgVim,
                        fontSize: width * .012,
                        color: Colors.black,
                      ),
                      labelText: "เลือกวันที่",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today_rounded, color: AppColors.darkPink),
                        onPressed: () => _selectDate(context),
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkPink, width: 2.0),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
              ),
              SizedBox(width: width * .27),
              /* _buildButton('อัพเดทยอดเงิน', width, height, coinsDataNew.isNotEmpty ? () async {
                // if(coinsDataNew.isNotEmpty || eshopDataNew.isNotEmpty) await Dbconnect().savepayment(notes: coinsDataNew, salecode: _seller.userid!, saledate: dateformat(date: DateTime.now(), type: 'db'), payeshop: eshopDataNew, creditcard: _creditController.text);
                _creditController.clear();
                coinsDataNew.clear();
                eshopDataNew.clear();

                _dBTransactionOnly();
                // _dBTransactionAll();

              } : null, AppColors.darkPink, width * .09),
              SizedBox(width: width * .01), */
              _buildButton('ใบสรุปส่งเงินรายได้', width, height, () async {
                setState(() {
                  _reportload = false;
                });
                _title = 'ใบสรุปส่งเงินรายได้';
                _report = await DailyIncome().genPDFDailyIncome(date: selectedDate!, title: _title);
                setState(() {
                  _reportload = true;
                });
              }, AppColors.darkPink, width * .11),
              /* Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /* _buildButton('ใบนำส่งรายได้ฝ่ายบัตรแยกตามคน', width, height, (_transaction.isNotEmpty && _transactionLoad) ? () async {
                    setState(() {
                      _reportload = false;
                    });
                    _title = 'ใบนำส่งรายได้ฝ่ายบัตรแยกตามคน';
                    _report = await IncomReportAllA4Landscape().genPDFTransactionAllA4Landscape(dataAll: _transaction, date: selectedDate!, title: '', dataAdv: _advDataReport, dataCredit: _creditDataReport, payType: _payTypeData);
                    setState(() {
                      _reportload = true;
                    });
                  } : null, AppColors.darkPink, width * .16),
                  SizedBox(width: width * .005),
                  _buildButton('รวมใบนำส่งรายได้ฝ่ายบัตร', width, height, (_transactionSumAll.isNotEmpty && _transactionLoad) ? () async {
                    setState(() {
                      _reportload = false;
                    });
                    _title = 'รวมใบนำส่งรายได้ฝ่ายบัตร';
                    _report = await IncomReportSumAllA5().genPDFTransactionSumAllA5(date: selectedDate!, title: _title, sumAll: _transactionSumAll);
                    setState(() {
                      _reportload = true;
                    });
                  } : null, AppColors.darkPink, width * .14),
                  SizedBox(width: width * .005), */
                  _buildButton('ใบสรุปส่งเงินรายได้', width, height, () async {
                    setState(() {
                      _reportload = false;
                    });
                    _title = 'ใบสรุปส่งเงินรายได้';
                    _report = await DailyIncome().genPDFDailyIncome(date: selectedDate!, title: _title);
                    setState(() {
                      _reportload = true;
                    });
                  }, AppColors.darkPink, width * .14),
                ],
              ), */
            ],
          ),
          SizedBox(height: height * .01),
          Row(
            children: [
                _saleList.isNotEmpty ? _buildSalelist(width, height) : Container(
                width: width * .15, //290
                height: height * .85,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: width * .01, right: width * .03),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(5),
                  // borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                ),
                child: _saleload ? Center(child: Text('ไม่พบข้อมูล', style: TextStyle(fontSize: width *.01, fontFamily: AppFonts.pgVim))) : LoadingAnimationWidget.horizontalRotatingDots(color: AppColors.darkPink, size: 100)
              ),
              Container(
                width: width * .2125,
                height: height * .85,
                margin: EdgeInsets.only(left: width * .01),
                /* decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ), */
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        rowHeader('Type', width * .07, width * .0085, radius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))), //ชื่อผู้จำหน่ายบัตร
                        rowHeader('Quantity', width * .07, width * .0085),
                        rowHeader('Amount', width * .07, width * .0085, radius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8))),
                      ],
                    ),
                    ...List.generate(coins.length, (index) {
                      final data = coins[index];
                      final qtyControll = quantityCoinsControllers[index];
                      double amt = double.parse(data);
                      double qty = double.parse(qtyControll.text.isNotEmpty ? qtyControll.text : '0.00');

                      return Row(
                        children: [
                          buildnotes(data, width * .07, width),
                          SizedBox(width: width * .009), //45
                          buildTextInput(qtyControll, amt, width * .05, width),
                          buildnotes(qtyControll.text.isNotEmpty ? formatter.format(amt * qty) : '0.00', width * .07, width, alignment: Alignment.centerRight),
                        ],
                      );
                    }),
                    SizedBox(height: height * .015),
                    Divider(color: Colors.grey, indent: width * .01, endIndent: width * .01),
                    SizedBox(height: height * .015),
                    Row(
                      children: [
                        rowHeader('Credit Card', width * .07, width * .0085, radius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                        SizedBox(width: width * .02),
                        Container(
                          width: width * .07, //130
                          margin: EdgeInsets.only(right: width * .03), //60
                          child: TextField(
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              double credit = double.tryParse(value) ?? 0.0;

                              setState(() {
                                sumAmtAll -= previousCreditAmount; // ลบค่าก่อนหน้า
                                sumAmtAll += credit;              // บวกค่าปัจจุบัน
                                previousCreditAmount = credit;    // อัปเดตค่าก่อนหน้า
                              });
                            },
                            controller: _creditController,
                            style: TextStyle(fontSize: width * .009, fontFamily: AppFonts.pgVim), //18
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pinkcm, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        rowHeader('E-Shop', width * .07, width * .0085, radius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
                        SizedBox(width: width * .02),
                        Container(
                          width: width * .07, //130
                          margin: EdgeInsets.only(right: width * .03), //60
                          child: TextField(
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              double eshop = double.tryParse(value) ?? 0.0;

                              setState(() {
                                sumAmtEshop -= previousEshopAmount; // ลบค่าก่อนหน้า
                                sumAmtEshop += eshop;              // บวกค่าปัจจุบัน
                                previousEshopAmount = eshop;    // อัปเดตค่าก่อนหน้า
                              });

                              if (value.isNotEmpty && double.tryParse(value) != 0) {
                                eshopDataNew = {
                                  "refno": '',
                                  "amount": eshop,
                                  "docdate": dateformat(date: selectedDate!, type: 'dh')
                                };
                              }
                              print('coinsDataNew $eshopDataNew');
                              print('coinsDataNew >> ${eshopDataNew.length}');
                            },
                            controller: _eshopController,
                            style: TextStyle(fontSize: width * .009, fontFamily: AppFonts.pgVim), //18
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pinkcm, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pdfPreview(width, height),
            ],
          ) //pdf previwe
        ],
      ),
    );
  }

  Widget _buildSalelist (double width, double height) {
    return Container(
      width: width * .185,
      height: height * .85,
      margin: EdgeInsets.only(left: width * .01),
      /* decoration: BoxDecoration(
        border: Border.all()
      ), */
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              rowHeader('ชื่อผู้จำหน่ายบัตร', width * .135, width * .0085, radius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
              rowHeader('Check', width * .04, width * .0085, radius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8))),
            ],
          ),
          ...List.generate(
            _saleList.length, (index) {
              final sale = _saleList[index];
              final check = _checkList[index];

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.all(5),
                    elevation: _saleCode == sale.code ? 0 : 5,
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          _saleCode = sale.code!;
                          _reportload = false;
                        });
                        _seller = sale;

                        await _dBAdvCredit();
                        await _dBTransactionOnly();
                        _report = await IncomeReportA4Landscape().genPDFTransactionA4Landscape(data: _transactionOnly, date: selectedDate!, seller: _seller, title: '', payAdvance: _advDataOnly, credit: _creditDataOnly, payType: _payTypeData);
                        setState(() {
                          _reportload = true;
                        });

                      },
                      child: Row(
                        children: [
                          Container(
                            width: width * .14, //280
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: _saleCode == sale.code ? Colors.pink : check ? Colors.green.shade200 : Colors.pink[200],
                            ),
                            child: Text("${sale.code} ${sale.name}",
                              style: TextStyle(fontSize: width * .009, color: _saleCode == sale.code ? AppColors.white : AppColors.black, fontFamily: AppFonts.pgVim),
                            )
                          ),
                        ],
                      ),      
                    ),
                  ),
                  Checkbox(
                    value: check,
                    activeColor: AppColors.darkPink,
                    onChanged: (/* _saleCode.isNotEmpty &&  */_saleCode == sale.code) ?  (bool? value) async {
                      setState(() {
                        _checkList[index] = value!;
                      });
                    } : null,
                  ),
                  if(_saleCode == sale.code) Icon(Icons.arrow_circle_right_outlined, color: AppColors.darkPink, size: width * .02)
                ],
              );
            } 
          ),
        ]
      ),
    );

  }

  Widget pdfPreview(double width, double height) {
    return Container(
      width: width * .565, //.6
      height: height * .85, //.85
      margin: EdgeInsets.only(left: width * .01),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade300
      ),
      child: _reportload ? PdfPreview(
        pdfFileName: '$_title ${dateformat(date: selectedDate!, type: 'dn')}',
        allowPrinting: true, 
        allowSharing: true,
        canDebug: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        actionBarTheme: PdfActionBarTheme(
          backgroundColor: AppColors.darkPink,
        ),
        dynamicLayout: true,
        loadingWidget: LoadingAnimationWidget.hexagonDots(color: AppColors.pinkcm, size: width * .045),
        build: (format) => _report!,
        onError: (context, error) {
          return Center(child: Text("เกิดข้อผิดพลาด", style: TextStyle(fontSize: width * .015, fontFamily: AppFonts.pgVim)));
        },
      ) : Center(child: Text("ไม่พบข้อมูล", style: TextStyle(fontSize: width * .02, fontFamily: AppFonts.pgVim)))
    );
  }

  Widget _buildButton(String label, double width, double height, VoidCallback? onPressed, Color color, double widthButton, {BorderRadius radius = BorderRadius.zero}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(widthButton, height * 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: color, width: 2.5),
          // borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        // backgroundColor: color,
        // elevation: 5,
      ),
      child: Text(label, style: TextStyle(color: AppColors.darkPink, fontFamily: AppFonts.pgVim, fontSize: width * .0095)),
    );
  }

  Widget rowHeader(String title, double width, double size, {BorderRadius radius = BorderRadius.zero}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: AppColors.darkPinkRed,
      ),
      child: Text(title, style: TextStyle(fontSize: size, fontFamily: AppFonts.pgVim, color: Colors.white)),
    );
  }

  Widget buildnotes(String data, double width, double size, {Alignment alignment = Alignment.center}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      alignment: alignment,
      child: Text(data, style: TextStyle(fontSize: size * .009, fontFamily: AppFonts.pgVim, color: Colors.black)), //18
    );
  }

  Widget buildTextInput(TextEditingController controller, double amt, double width, double size) {
    double calculateTotalAmount() {
      double total = 0;
      for (int i = 0; i < coins.length; i++) {
        final amt = double.parse(coins[i]);
        final qtyText = quantityCoinsControllers[i].text.replaceAll(',', '');
        final qty = double.tryParse(qtyText) ?? 0.0;
        total += amt * qty;
      }
      return total;
    }

    return SizedBox(
      width: width,
      child: TextField(
        textAlign: TextAlign.center,
        onChanged: (value) {
          setState(() {
            sumAmtAll -= previousSumAmtNotes; // หักค่าก่อนหน้าออกก่อน
            sumAmtNotes = calculateTotalAmount(); // คำนวณใหม่
            sumAmtAll += sumAmtNotes; // บวกค่าปัจจุบัน
            previousSumAmtNotes = sumAmtNotes; // จำค่าครั้งล่าสุดไว้ใช้รอบถัดไป
          }); 

          coinsDataNew.removeWhere((note) => note["ctype"] == amt);
          if (value.isNotEmpty && double.tryParse(value) != 0) {
            coinsDataNew.add({
              "ctype": amt,
              "quantity": double.parse(value),
              "amount": amt * double.parse(value)
            });
          }

          print('coinsDataNew $coinsDataNew');
          print('coinsDataNew >> ${coinsDataNew.length}');
        },
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        style: TextStyle(fontSize: size * .009, fontFamily: AppFonts.pgVim, color: Colors.black), //18
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.pinkcm, width: 2),
          ),
        ),
      ),
    );
  }
}