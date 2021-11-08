import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:abitplay/ViewScreen/GamesView.dart';
import 'package:abitplay/network_utils/api.dart';
import 'package:abitplay/providers/app_provider.dart';
import 'package:abitplay/services/firebase_analytics.dart';
import 'package:abitplay/utils/CustomWidgets.dart';
import 'package:abitplay/utils/smooth_star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  Future<dynamic> futur;
  List<dynamic> lists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: SearchBox(
                  isLoading: false,
                  focusNode: null,
                  hintText: 'Search Games',
                  textEditingController: null,
                  function: () {
                    search();
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              _pageNator(),
              // Text(Provider.of<AppProvider>(context).fav.length.toString()),
              Provider.of<AppProvider>(context).fav.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      primary: false,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 4 : 3),
                      itemCount:
                          Provider.of<AppProvider>(context).fav.length == null
                              ? 0
                              : Provider.of<AppProvider>(context).fav.length,
                      itemBuilder: (BuildContext context, int index) {
                        print("printing list item builder");
                        print(
                            Provider.of<AppProvider>(context).fav.runtimeType);
                        List newLi = Provider.of<AppProvider>(context).fav;
                        var newList = Provider.of<AppProvider>(context)
                            .fav[newLi.length - 1];
                        var value = newList['game'];
                        var favID = newList['id'].toString();
                        // print(valu.runtimeType);
                        // var value = valu['game'];
                        return GestureDetector(
                          onTap: () {
                            print(value);
                            print("**************");
                            print(favID);
                            pushNewScreen(
                              context,
                              screen: GamesView(
                                  game: value, isFav: true, favID: favID),
                              withNavBar:
                                  false, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: value['image'].toString(),
                                      placeholder: (context, url) =>
                                          Image.asset(
                                        'assets/images/loading.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/loading.gif',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.black.withOpacity(0.01),
                                  margin: EdgeInsets.all(0.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Container(),
                                ),
                                Card(
                                  margin: EdgeInsets.all(0.0),
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.1),
                                  // color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 1,
                                  child: Stack(
                                    children: <Widget>[
                                      // Positioned(
                                      //     top: 30,
                                      //     right: 10,
                                      //
                                      //     child: Icon(MyFlutterApp.award, size: 35,color: Colors.white.withOpacity(0.5),)),

                                      Container(
//                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.2, ),
                                        height: 180,
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            // visualDensity: VisualDensity(horizontal: -4, vertical: 0),
//                        trailing: Text('${lists[i]['award_price'].toString()}'),
                                            title: Text(
                                              value['title']
                                                  .toString()
                                                  .toUpperCase(),
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 8),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: SmoothStarRating(
                                              starCount: 5,
                                              color: Colors.orange,
                                              allowHalfRating: true,
                                              rating: 5.0,
                                              size: 8.0,
                                            ),
                                            // trailing:SmoothStarRating(
                                            //   starCount: 5,
                                            //   color: Colors.orange,
                                            //   allowHalfRating: true,
                                            //   rating: 5.0,
                                            //   size: 8.0,
                                            // ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "No items yet",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
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
      Network().sendCountriesDataRequest(page, context);
      // await _getToken();
      String url = Uri.encodeFull(
          'https://api.abitplay.io/api/v1/favourites/${Provider.of<AppProvider>(context, listen: false).data['id'].toString()}?page=$page');
      http.Response response =
          await http.get(Uri.parse(url), headers: _setAuthHeaders());
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

  ///featured games
  _setAuthHeaders() => {
        'content-type': 'application/json',
        'accept': 'application/json',
      };

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

//   Widget listItemBuilder(valu, int index) {
//     print("printing list item builder");
//     // print(Provider.of<AppProvider>(context).fav.runtimeType);
//     // List newLi = Provider.of<AppProvider>(context).fav;
//     // var newList = Provider.of<AppProvider>(context).fav[newLi.length - 1];
//     // var value = newList['game'];
//     // print(valu.runtimeType);
//     var value = valu['game'];
//     return GestureDetector(
//       onTap: ()
//       {
//         print("***************");
//         print(valu["id"]);
//         pushNewScreen(
//           context,
//           screen: GamesView(game: value, isFav: true, favID: value["id"].toString(),),
//           withNavBar: false, // OPTIONAL VALUE. True by default.
//           pageTransitionAnimation: PageTransitionAnimation.cupertino,
//         );
//       },
//       child: Card(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Stack(
//
//           children: [
//
//             ClipRRect(
//               borderRadius: BorderRadius.circular(18),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(18.0),
//                 ),
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 child: CachedNetworkImage(
//                   fit: BoxFit.cover,
//                   imageUrl: value['image'].toString(),
//                   placeholder: (context, url) => Image.asset(
//                     'assets/images/loading.gif',
//                     fit: BoxFit.cover,
//                   ),
//                   errorWidget: (context, url, error) => Image.asset(
//                     'assets/images/loading.gif',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             Card(
//               color: Colors.black.withOpacity(0.01),
//               margin: EdgeInsets.all(0.0),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Container(),
//             ),
//
//             Card(
//               margin: EdgeInsets.all(0.0),
//               color: Theme.of(context).accentColor.withOpacity(0.1),
//               // color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.3),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               elevation: 1,
//               child: Stack(
//                 children: <Widget>[
//                   // Positioned(
//                   //     top: 30,
//                   //     right: 10,
//                   //
//                   //     child: Icon(MyFlutterApp.award, size: 35,color: Colors.white.withOpacity(0.5),)),
//
//                   Container(
// //                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.2, ),
//                     height: 180,
//                     width: MediaQuery.of(context).size.width,
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ListTile(
//                         // visualDensity: VisualDensity(horizontal: -4, vertical: 0),
// //                        trailing: Text('${lists[i]['award_price'].toString()}'),
//                         title: Text(value['title'].toString().toUpperCase(),
//                           maxLines: 2,
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 8
//                           ),
//                           overflow: TextOverflow.ellipsis,),
//                         subtitle: SmoothStarRating(
//                           starCount: 5,
//                           color: Colors.orange,
//                           allowHalfRating: true,
//                           rating: 5.0,
//                           size: 8.0,
//                         ),
//                         // trailing:SmoothStarRating(
//                         //   starCount: 5,
//                         //   color: Colors.orange,
//                         //   allowHalfRating: true,
//                         //   rating: 5.0,
//                         //   size: 8.0,
//                         // ),
//
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }

  Widget listItemBuilder(valu, int index) {
    return SizedBox();
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
          child: Text(countriesData.errorMessage),
        ),
        FlatButton(
          onPressed: retryListener,
          child: Text('Retry'),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(CountriesData countriesData) {
    return SizedBox();
  }

  bool pageErrorChecker(CountriesData countriesData) {
    return countriesData.statusCode != 200;
  }

  void search() {
    // var im = person['image'];
    // var img = (im!=null)?baseurl+im:images[randomNumber];
    int max = 10;
    int randomNumber = Random().nextInt(max);
    print('random number is $randomNumber');
    // int max = 10;
    // int randomNumber = Random().nextInt(max);
    // print('random number is $randomNumber');
    analytics.logEvent(name: 'SearchGames', parameters: {
      'Screen': 'ABiTGamesSearch',
    });
    showSearch(
      context: context,
      delegate: SearchPage(
        barTheme: Theme.of(context).copyWith(
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
                headline6: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
          appBarTheme:
              Theme.of(context).appBarTheme.copyWith(color: Color(0xff031D39)),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            border: InputBorder.none,
          ),
        ),
        items: lists,
        searchLabel: 'Search Games',
        suggestion: Container(
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
          child: Center(
            child: Text(
              'Filter Games',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        failure: Container(
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
          child: Container(
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
            child: Center(
              child: Text(
                'No matching Game :(',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        filter: (person) => [
          person.toString(),
//          person['image_url'].toString(),
//          person.surname,
//          person.age.toString(),
        ],
        builder: (person) => InkWell(
          onTap: () {
            // print(person['title'].toString());
            pushNewScreen(
              context,
              screen: GamesView(
                game: person["game"],
                isFav: true,
              ),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          // child: Text(person["game"].toString()),
          child: Container(
            padding: const EdgeInsets.all(4.0),
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
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: Theme.of(context).accentColor,
                  child: Icon(
                    Icons.games,
                    color: Colors.white,
                    size: 20,
                  )),
              title: Text(
                person["game"]['title'].toString(),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // subtitle: Text(((person['post_type'] != null)? person['post_type'].toString(): 'Scholarship'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),
              trailing: Container(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Image.asset(
                      'assets/images/loading.gif',
                      fit: BoxFit.cover,
                    ),
                    imageUrl: person["game"]['image'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
//            subtitle: Text(person.surname),
//            trailing: Text('${person.age} yrs'),
            ),
          ),
        ),
      ),
    );
  }
}

class CountriesData {
  List<dynamic> countries;
  int statusCode;
  String errorMessage;
  int total;
  int nItems;

  CountriesData.fromResponse(http.Response response, [context]) {
    print('printing response');
    print(response.body);
    this.statusCode = response.statusCode;
    var jsonData = json.decode(response.body);
    final mapOfList = jsonData['favourites'];
    var pgn = jsonData['pagination'];
    // int tota = pgn['total'];
    // int tota = pgn['total'];
//    final mapOfList = jsonData['data'];
    print('printing data');
//    print(jsonData);
    countries = mapOfList;
    print("printing list item details");
    print(countries);
    Provider.of<AppProvider>(context, listen: false).updateFav(countries);
    total = countries.length;
    nItems = countries.length;
    print('length is $nItems');
    print('total is $total');
  }

  CountriesData.withError(String errorMessage) {
    this.errorMessage = errorMessage;
  }
}
