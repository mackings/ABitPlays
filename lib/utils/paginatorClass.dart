import 'dart:convert';

import 'package:http/http.dart' as http;

// class CountriesData2 {
//   List<dynamic> countries;
//   int statusCode;
//   String errorMessage;
//   int total;
//   int nItems;
//
//   CountriesData2.fromResponse(http.Response response) {
//     print('printing response');
//     // print(response.body);
//     this.statusCode = response.statusCode;
//     var jsonData = json.decode(response.body);
//     print(jsonData);
//     final mapOfList = jsonData['games'];
//     // var pgn = jsonData['pagination'];
//     // int tota = pgn['total'];
//     int tota = mapOfList.length < 4? mapOfList.length : 4;
//     //todo: unfreez this for slider pagiator
// //    final mapOfList = jsonData['data'];
//     print('printing data');
// //    print(jsonData);
//     countries = mapOfList;
//     total = tota>6? 6:tota;
//     nItems = countries.length;
//     print('length is $nItems');
//     print('total is $total');
//   }
//
//   CountriesData2.withError(String errorMessage) {
//     this.errorMessage = errorMessage;
//   }
// }


//todo countries data for search paginator
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
    final mapOfList = jsonData['games'];
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
