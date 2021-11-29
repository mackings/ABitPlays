import 'dart:convert';
import 'dart:io';
import 'package:abitplay/Screens/HomeBarScreens/Library.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abitplay/providers/app_provider.dart';

class Constant extends ChangeNotifier{
  static String appName = "ABiTPlay";
    static String baseUrl = "https://api.abitplay.io/api/v1";
    static String regUrl = "https://abitnetwork.com/auth/register";

    ///from authDoxcs
    static String  BASE_URL = "https://api.abitnetwork.com";
    static String AUTH_URL = "https://auth.abitnetwork.com/api/v1/auth";
    static String BALANCE_URL = "https://balance.abitnetwork.com";

}

class Network {
  final String _url = Constant.baseUrl;
  String token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if(localStorage.containsKey("user")){
      var user = localStorage.getString("user");
      var details = json.decode(user);
      token = details["token"];
    }
    // token = jsonDecode(localStorage.getString('token'));
    // token = localStorage.getString("token");
    print('token is Bearer $token');
  }

  authData(data, apiUrl) async {
    // await _getToken();
    var fullUrl = apiUrl;
    return await http.post(
        Uri.parse(fullUrl),
        body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  putData(data, apiUrl) async {
    await _getToken();
    var fullUrl = apiUrl;
    return await http.put(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders2(),
    );
  }

  getOTP(data, apiUrl) async {
    var fullUrl = apiUrl;
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getToken();
    return await http.post(
        Uri.parse(fullUrl),
        body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  getPayStack(String trxRef) async {
    var fullUrl = 'https://api.paystack.co/transaction/verify/${trxRef}';
    return await http.get(
        Uri.parse(fullUrl),
      headers: _setHeaders(),
    );
  }


  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getToken();
    return await http.get(
        Uri.parse(fullUrl),
      headers: _setHeaders(),
    );
  }



  _setHeaders() => {
    'content-type' : 'application/json',
    'accept' : 'application/json',
  };

  _setHeaders2() => {
    'content-type' : 'application/json',
    'accept' : 'application/json',
    "Authorization" : "Bearer $token",
  };



  Future<CountriesData> sendCountriesDataRequest(int page, context) async {
    try {
      // await _getToken();
      String url = Uri.encodeFull(
          'https://api.abitplay.io/api/v1/favourites/${Provider.of<AppProvider>(context, listen: false).data['id'].toString()}?page=$page');
      http.Response response = await http.get(Uri.parse(url), headers: _setHeaders());
      return CountriesData.fromResponse(response, context);

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

}