import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:abitplay/ViewScreen/GamesView.dart';
import 'package:abitplay/services/firebase_analytics.dart';
import 'package:abitplay/utils/CustomWidgets.dart';
import 'package:abitplay/utils/paginatorClass.dart';
import 'package:abitplay/utils/smooth_star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:search_page/search_page.dart';

class Games extends StatefulWidget {
  @override
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  Future<dynamic> futur;
  List<dynamic> lists = [];

  List<dynamic> values = [
    {
      "title": "Black Ops War",
      "img":
          "https://happygamer.com/wp-content/uploads/2020/05/f7248cdc3d2c9d86da8125973dc1aea5.jpg"
    },
    {
      "title": "Subway Surf",
      "img":
          "https://m.media-amazon.com/images/M/MV5BMzllN2IwYzEtODZhNC00ODRkLWE2ZmUtODdiOTU2YjZlZTk0XkEyXkFqcGdeQXVyNTgyNTA4MjM@._V1_.jpg"
    },
    {
      "title": "Need for Speed",
      "img":
          "https://play-lh.googleusercontent.com/f3HtlzhRx1DGxT0aZU0jbiZzH1J44Aj9WyunR2SrF1-e94p85nnCEP0XL3XFqYZaL-Q"
    },
    {
      "title": "Resident Evil",
      "img": "https://i.ytimg.com/vi/pTbEOMUHG4E/maxresdefault.jpg"
    }
  ];

  @override
  void initState() {
    futur = sendCountriesDataRequest3(1);
    // TODO: implement initState
    super.initState();
    // futur = sendCountriesDataRequest3(1);
  }

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
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: SearchBox(
                    isLoading: false,
                    focusNode: null,
                    hintText: 'Search ABiTPlay',
                    textEditingController: null,
                    function: () {
                      search();
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      Text(
                        "FEATURED",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                future(),

//           CarouselSlider.builder(
//             options: CarouselOptions(
//               height: 190,
//               aspectRatio: 16/9,
//               viewportFraction: 0.9 ,
//               initialPage: 0,
//               enableInfiniteScroll: true,
//               reverse: false,
//               autoPlay:  true,
//               autoPlayInterval: Duration(seconds: 3),
//               autoPlayAnimationDuration: Duration(milliseconds: 800),
//               autoPlayCurve: Curves.fastOutSlowIn,
//               enlargeCenterPage: false,
// //                  onPageChanged: callbackFunction,
//               scrollDirection: Axis.horizontal,
//             ),
//             itemCount: values.length,
//             itemBuilder:
//                 (BuildContext context, int i) {
//               //todo this is for gen random numbers
//               return GestureDetector(
//                 onTap: ()
//                 {
//                   pushNewScreen(
//                     context,
//                     screen: GamesView(game: values[i]),
//                     withNavBar: false, // OPTIONAL VALUE. True by default.
//                     pageTransitionAnimation: PageTransitionAnimation.cupertino,
//                   );
//                 },
//                 child: Card(
//                   color: Colors.black,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: Stack(
//
//                     children: [
//
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(18),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(18.0),
//                           ),
//                           width: MediaQuery.of(context).size.width,
//                           height: MediaQuery.of(context).size.height,
//                           child: CachedNetworkImage(
//                             fit: BoxFit.cover,
//                             imageUrl: values[i]['img'].toString(),
//                             placeholder: (context, url) => Image.asset(
//                               'assets/images/loading.gif',
//                               fit: BoxFit.cover,
//                             ),
//                             errorWidget: (context, url, error) => Image.asset(
//                               'assets/images/loading.gif',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Card(
//                         color: Colors.black.withOpacity(0.2),
//                         margin: EdgeInsets.all(0.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         child: Container(),
//                       ),
//
//                       Card(
//                         margin: EdgeInsets.all(0.0),
//                         color: Theme.of(context).accentColor.withOpacity(0.1),
//                         // color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.3),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         elevation: 1,
//                         child: Stack(
//                           children: <Widget>[
//                             // Positioned(
//                             //     top: 30,
//                             //     right: 10,
//                             //
//                             //     child: Icon(MyFlutterApp.award, size: 35,color: Colors.white.withOpacity(0.5),)),
//
//                             Container(
// //                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.2, ),
//                               height: 180,
//                               width: MediaQuery.of(context).size.width,
//                             ),
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//
//                                 Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: ListTile(
// //                        trailing: Text('${lists[i]['award_price'].toString()}'),
//                                     title: Padding(
//                                       padding: const EdgeInsets.only(right:20.0),
//                                       child: Text(values[i]['title'].toString().toUpperCase(),
//                                         maxLines: 2,
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.w800,
//                                             fontSize: 15
//                                         ),
//                                         overflow: TextOverflow.ellipsis,),
//                                     ),
//                                     subtitle: Text("Action",
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w400,
//                                           // fontSize: 15
//                                       ),),
//                                     trailing:SmoothStarRating(
//                                       starCount: 5,
//                                       color: Colors.orange,
//                                       allowHalfRating: true,
//                                       rating: 5.0,
//                                       size: 12.0,
//                                     ),
//
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      Text(
                        "POPULAR",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                _pageNator(),

//                 GridView.builder(
//
//                   shrinkWrap: true,
//                   primary: false,
//                   physics: NeverScrollableScrollPhysics(),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: MediaQuery.of(context).size.width /
//                         (MediaQuery.of(context).size.height / 1.8),
//                   ),
//                   itemCount: values == null ? 0 : values.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     Map cat = values[index];
//                     return GestureDetector(
//                       onTap: ()
//                       {
//                         pushNewScreen(
//                           context,
//                           screen: GamesView(game: cat),
//                           withNavBar: false, // OPTIONAL VALUE. True by default.
//                           pageTransitionAnimation: PageTransitionAnimation.cupertino,
//                         );
//                       },
//                       child: Card(
//                         color: Colors.black,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         child: Stack(
//
//                           children: [
//
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(18),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(18.0),
//                                 ),
//                                 width: MediaQuery.of(context).size.width,
//                                 height: MediaQuery.of(context).size.height,
//                                 child: CachedNetworkImage(
//                                   fit: BoxFit.cover,
//                                   imageUrl: cat['img'].toString(),
//                                   placeholder: (context, url) => Image.asset(
//                                     'assets/images/loading.gif',
//                                     fit: BoxFit.cover,
//                                   ),
//                                   errorWidget: (context, url, error) => Image.asset(
//                                     'assets/images/loading.gif',
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Card(
//                               color: Colors.black.withOpacity(0.2),
//                               margin: EdgeInsets.all(0.0),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               child: Container(),
//                             ),
//
//                             Card(
//                               margin: EdgeInsets.all(0.0),
//                               color: Theme.of(context).accentColor.withOpacity(0.1),
//                               // color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.3),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               elevation: 1,
//                               child: Stack(
//                                 children: <Widget>[
//                                   // Positioned(
//                                   //     top: 30,
//                                   //     right: 10,
//                                   //
//                                   //     child: Icon(MyFlutterApp.award, size: 35,color: Colors.white.withOpacity(0.5),)),
//
//                                   Container(
// //                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.2, ),
//                                     height: 180,
//                                     width: MediaQuery.of(context).size.width,
//                                   ),
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//
//                                       Padding(
//                                         padding: const EdgeInsets.all(0.0),
//                                         child: ListTile(
// //                        trailing: Text('${lists[i]['award_price'].toString()}'),
//                                           title: Text(cat['title'].toString().toUpperCase(),
//                                             maxLines: 1,
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w800,
//                                                 fontSize: 13
//                                             ),
//                                             overflow: TextOverflow.ellipsis,),
//                                           subtitle: Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                             crossAxisAlignment: CrossAxisAlignment.center,
//                                             children: [
//                                               Text("Action",
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.w400,
//                                                   fontSize: 10
//                                                 ),),
//                                           SmoothStarRating(
//                                               starCount: 5,
//                                               color: Colors.orange,
//                                               allowHalfRating: true,
//                                               rating: 5.0,
//                                               size: 8.0,
//                                             ),
//                                             ],
//                                           ),
//                                           // trailing:SmoothStarRating(
//                                           //   starCount: 5,
//                                           //   color: Colors.orange,
//                                           //   allowHalfRating: true,
//                                           //   rating: 5.0,
//                                           //   size: 8.0,
//                                           // ),
//
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                           ],
//                         ),
//                       ),
//                     );
//                     //   function:
//                     // );
//                   },
//                 ),

//                  Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 16.0),
//                    child: Row(
//                      children: [
//                        Text(
//                          "CATEGORIES",
//                          style: TextStyle(fontWeight: FontWeight.w600),
//                        ),
//                      ],
//                    ),
//                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///featured games
  _setAuthHeaders() => {
        'content-type': 'application/json',
        'accept': 'application/json',
      };

  Widget loadingWidgetMaker2() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        alignment: Alignment.center,
        height: 160,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Image(
          image: AssetImage("assets/images/loading.gif"),
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future sendCountriesDataRequest3(int page) async {
    String url =
        Uri.encodeFull('https://api.abitplay.io/api/v1/games?page=$page');
    http.Response response =
        await http.get(Uri.parse(url), headers: _setAuthHeaders());
    var body = json.decode(response.body);
    final mapOfList = body['games'];
    var values = new List<dynamic>();
    for (var e in mapOfList) {
      values.add(e);
    }
    return values;
  }

  Widget future() {
    return FutureBuilder(
      future: futur,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return loadingWidgetMaker2();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Please check your internet connection'),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {});
                      futur = sendCountriesDataRequest3(1);
                      paginatorGlobalKey.currentState.changeState(
                          pageLoadFuture: sendCountriesDataRequest,
                          resetState: true);
                    },
                    child: Text('Retry'),
                  )
                ],
              );
            }
//            Future.microtask(() {
//              setState(() {});
//            });
            return slider(context, snapshot);
        }
        return null;
      },
    );
  }

  Future<CountriesData> sendCountriesDataRequest(int page) async {
    try {
      // await _getToken();
      String url =
          Uri.encodeFull('https://api.abitplay.io/api/v1/games?page=$page');
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

  Widget slider(BuildContext context, AsyncSnapshot snapshot) {
    print("*****************");
    List<dynamic> values = snapshot.data;
    print(values);
    if (values.isNotEmpty) {
      return CarouselSlider.builder(
        options: CarouselOptions(
          height: 190,
          aspectRatio: 16 / 9,
          viewportFraction: 0.9,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
//                  onPageChanged: callbackFunction,
          scrollDirection: Axis.horizontal,
        ),
        itemCount: values.length,
        itemBuilder: (BuildContext context, int i) {
          //todo this is for gen random numbers
          return GestureDetector(
            onTap: () {
              pushNewScreen(
                context,
                screen: GamesView(
                  game: values[i],
                  isFav: false,
                ),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            child: Card(
              color: Colors.black,
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
                        imageUrl: values[i]['image'].toString(),
                        placeholder: (context, url) => Image.asset(
                          'assets/images/loading.gif',
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/loading.gif',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.black.withOpacity(0.2),
                    margin: EdgeInsets.all(0.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Container(),
                  ),
                  Card(
                    margin: EdgeInsets.all(0.0),
                    color: Theme.of(context).accentColor.withOpacity(0.1),
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
                          width: MediaQuery.of(context).size.width,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ListTile(
//                        trailing: Text('${lists[i]['award_price'].toString()}'),
                                title: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Text(
                                    values[i]['title'].toString().toUpperCase(),
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                subtitle: Text(
                                  "Action",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    // fontSize: 15
                                  ),
                                ),
                                trailing: SmoothStarRating(
                                  starCount: 5,
                                  color: Colors.orange,
                                  allowHalfRating: true,
                                  rating: 5.0,
                                  size: 12.0,
                                ),
                              ),
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
        },
      );
    } else {
      return SizedBox();
    }
  }

  Widget _pageNator() {
    return Paginator.gridView(
      key: paginatorGlobalKey,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3),
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
    return GestureDetector(
      onTap: () {
        print(value["images"].runtimeType);
        pushNewScreen(
          context,
          screen: GamesView(
            game: value,
            isFav: false,
          ),
          withNavBar: false, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
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
                  placeholder: (context, url) => Image.asset(
                    'assets/images/loading.gif',
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
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
              color: Theme.of(context).accentColor.withOpacity(0.1),
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
                    width: MediaQuery.of(context).size.width,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        // visualDensity: VisualDensity(horizontal: -4, vertical: 0),
//                        trailing: Text('${lists[i]['award_price'].toString()}'),
                        title: Text(
                          value['title'].toString().toUpperCase(),
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
    return Center(
      child: Text("No Games Yet"),
    );
  }

  bool pageErrorChecker(CountriesData countriesData) {
    return countriesData.statusCode != 200;
  }

  ///search feature here
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
          primaryColor: Colors.red,
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
        suggestion: Center(
          child: Text('Filter Games'),
        ),
        failure: Center(
          child: Text('No matching Game :('),
        ),
        filter: (person) => [
          person['title'].toString(),
//          person['image_url'].toString(),
//          person.surname,
//          person.age.toString(),
        ],
        builder: (person) => InkWell(
          onTap: () {
            print(person['title'].toString());
            pushNewScreen(
              context,
              screen: GamesView(
                game: person,
                isFav: false,
              ),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: Theme.of(context).accentColor,
                  child: Icon(
                    Icons.games,
                    color: Colors.white,
                    size: 20,
                  )),
              title: Text(
                person['title'].toString(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
//              subtitle: Text(
//                ((person['post_type'] != null)
//                    ? person['post_type'].toString()
//                    : 'Scholarship'),
//                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//              ),
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
                    imageUrl: person['image'],
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
