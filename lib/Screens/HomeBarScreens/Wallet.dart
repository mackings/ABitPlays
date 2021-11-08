import 'dart:convert';
import 'dart:io';

import 'package:abitplay/network_utils/api.dart';
import 'package:abitplay/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  Future<dynamic> futur;
  List<dynamic> lists = [];
  var formattedDat = new DateFormat('EEE, MMM d, ' 'yyyy, kk:mm a');
  // String email = Provider.of(context, listen: false).data['email'].toString();

  @override
  void initState() {
    futur = sendCountriesDataRequest3(1);
    // TODO: implement initState
    super.initState();
    print(Provider.of<AppProvider>(context, listen: false)
        .data['email']
        .toString());
    // futur = sendCountriesDataRequest3(1);
  }

  _setAuthHeaders() => {
        'content-type': 'application/json',
        'accept': 'application/json',
      };
  Future sendCountriesDataRequest3(int page) async {
    print("starting");
    String url = Uri.encodeFull(
        '${Constant.BALANCE_URL}/balance/${Provider.of<AppProvider>(context, listen: false).data['email'].toString()}?baseCurrencyNGN');
    http.Response response =
        await http.get(Uri.parse(url), headers: _setAuthHeaders());
    var body = json.decode(response.body);
    // var body = response.body;
    print(body);
    print(body["TAT"]);
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/bg.jpg',
//             width: 220.0,
//             height: 120,
            ),
//            colorFilter: ColorFilter.mode(
//                Colors.black.withOpacity(0.8), BlendMode.srcOver),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Activities Overview",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          ),
                          Text(
                            "Hello ${Provider.of<AppProvider>(context).data['name'].toString()},",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Image(image: AssetImage("assets/images/tatcoin.png",),
                    //       height: MediaQuery.of(context).size.height/4,
                    //       fit: BoxFit.cover,
                    //       // width: MediaQuery.of(context).size.width,
                    //       )
                    //   ],
                    // ),
                    Card(
                      margin: EdgeInsets.all(0.0),
                      color: Theme.of(context).accentColor.withOpacity(0.1),
                      // color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 1,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "Activity points",
                                  style: TextStyle(color: Colors.white),
                                )),
                            // Text("500 TAT", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800),),
                            FutureBuilder(
                              future: futur,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                  case ConnectionState.waiting:
                                  case ConnectionState.active:
                                    return Text(
                                      "...",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    );
                                  case ConnectionState.done:
                                    if (snapshot.hasError) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                                'Please check your internet connection',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                futur =
                                                    sendCountriesDataRequest3(
                                                        1);
                                              });
                                              // paginatorGlobalKey.currentState.changeState(
                                              //     pageLoadFuture: sendCountriesDataRequest, resetState: true);
                                            },
                                            child: Text('Retry',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          )
                                        ],
                                      );
                                    }
//            Future.microtask(() {
//              setState(() {});
//            });
                                    return Column(
                                      children: [
                                        Text(snapshot.data["TAT"].toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w800)),
                                        // Text(snapshot.data["NGN"].toString()+ " NGN", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                      ],
                                    );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  sendCountriesDataRequest3(1);
                },
                title: Text(
                  "Activity History",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                // subtitle: Text('In App Activity history'),
                trailing: Text("See all",
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
              _pageNator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageNator() {
    return Paginator.listView(
      key: paginatorGlobalKey,
      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4:3),
      shrinkWrap: true,
      pageLoadFuture: sendCountriesDataRequest,
      pageItemsGetter: listItemsGetter,
      listItemBuilder: listItemBuilder,
      loadingWidgetBuilder: loadingWidgetMaker,
      errorWidgetBuilder: errorWidgetMaker,
      emptyListWidgetBuilder: emptyListWidgetMaker,
      totalItemsGetter: totalPagesGetter,
      pageErrorChecker: pageErrorChecker,
      scrollPhysics: BouncingScrollPhysics(),
    );
  }

  Future<CountriesData> sendCountriesDataRequest(int page) async {
    try {
      // await _getToken();
      String url = Uri.encodeFull(
          // ${Provider.of<AppProvider>(context, listen: false).data['id'].toString()}
          'https://api.abitplay.io/api/v1/payment/history/${Provider.of<AppProvider>(context, listen: false).data['id'].toString()}?page=$page');
      http.Response response =
          await http.get(Uri.parse(url), headers: _setAuthHeaders());
      return CountriesData.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        return CountriesData.withError(
            'Please check your internet connection.');
      } else {
        print(e.toString());
        return CountriesData.withError('Something went wrong.');
      }
    }
  }

  List<dynamic> listItemsGetter(CountriesData countriesData) {
    List<dynamic> list = [];
    List<dynamic> currency = [];
    countriesData.countries.forEach((value) {
      list.add(value);
      lists.add(value);
      // if(value['award_price'].toLowerCase().contains('€')){
      //   currency.add(value);
      //   print(currency.length);
      // }
    });
    return list;
    // .where((note) => note['award_price'].toLowerCase().contains('€')).toList();
  }

  int totalPagesGetter(CountriesData countriesData) {
    return countriesData.total;
  }

  Widget listItemBuilder(value, int index) {
    return ListTile(
      leading: CircleAvatar(child: Icon(Icons.attach_money)),
      title: Text(
        value["purpose"],
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      trailing: Text(
        value["amount"].toString().split(".")[0] + " TAT",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        formattedDat.format(DateTime.parse(value["updated_at"])),
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      // subtitle:  Text(value["updated_at"]),
    );
  }

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidgetMaker(CountriesData countriesData, retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(countriesData.errorMessage,
              style: TextStyle(color: Colors.white)),
        ),
        FlatButton(
          onPressed: retryListener,
          child: Text('Retry', style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(CountriesData countriesData) {
    return Center(
      child: Text(
        "No Activities yet",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  bool pageErrorChecker(CountriesData countriesData) {
    return countriesData.statusCode != 200;
  }
}

class CountriesData {
  List<dynamic> countries;
  int statusCode;
  String errorMessage;
  int total;
  int nItems;

  CountriesData.fromResponse(http.Response response) {
    print('printing response');
    print(response.body);
    this.statusCode = response.statusCode;
    var jsonData = json.decode(response.body);
    final mapOfList = jsonData['history'];
    var pgn = jsonData['pagination'];
    // int tota = pgn['total'];
    // int tota = pgn['total'];
//    final mapOfList = jsonData['data'];
    print('printing data');
//    print(jsonData);
    countries = mapOfList;
    total = countries.length;
    nItems = countries.length;
    print('length is $nItems');
    print('total is $total');
  }

  CountriesData.withError(String errorMessage) {
    this.errorMessage = errorMessage;
  }
}
