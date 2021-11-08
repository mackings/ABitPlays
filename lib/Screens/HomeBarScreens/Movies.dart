import 'dart:math';

import 'package:abitplay/ViewScreen/videoScreen.dart';
import 'package:abitplay/ViewScreen/webview.dart';
import 'package:abitplay/ViewScreen/youtubeVideo.dart';
import 'package:abitplay/services/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:search_page/search_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Movies extends StatefulWidget {
  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<dynamic> values = [
    {
      "title": "Teego Lagos",
      "artist": "Teego",
      "desc": "",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2Fimage0.jpeg?alt=media&token=cb799128-5342-4c8f-b7bd-0a3b9bd11745",
      "url": "https://youtu.be/pyGjUpCYZnQ",
    },
    {
      "title": "Teego Money iz Coming",
      "artist": "Teego",
      "desc": "",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2Fimage2.jpeg?alt=media&token=40784f69-69d5-489a-a0e6-01bb65c9842c",
      "url": "https://youtu.be/IlDpWE7y6qU",
    },
    {
      "title": "Teego Skolombo",
      "artist": "Teego",
      "desc": "",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2Fimage1.jpeg?alt=media&token=14077496-daaa-4fb4-8820-f52d5b7c064f",
      "url": "https://youtu.be/n2iH8Rq1_fo",
    },
    {
      "title": "Teego Lagos",
      "artist": "Teego",
      "desc": "",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2Fimage0.jpeg?alt=media&token=cb799128-5342-4c8f-b7bd-0a3b9bd11745",
      "url": "https://youtu.be/pyGjUpCYZnQ",
    },
    {
      "title": "Teego Money iz Coming",
      "artist": "Teego",
      "desc": "",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2Fimage2.jpeg?alt=media&token=40784f69-69d5-489a-a0e6-01bb65c9842c",
      "url": "https://youtu.be/IlDpWE7y6qU",
    },
    {
      "title": "Teego Skolombo",
      "artist": "Teego",
      "desc": "",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2Fimage1.jpeg?alt=media&token=14077496-daaa-4fb4-8820-f52d5b7c064f",
      "url": "https://youtu.be/n2iH8Rq1_fo",
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        backgroundColor: Color(0xff031D39),
//
//        title: Padding(
//          padding: const EdgeInsets.all(0.0),
//          child: SearchBox(
//            isLoading: false,
//            focusNode: null,
//            hintText: 'Search Leaderboard',
//            textEditingController: null,
//            function: () {
//              search();
//            },
//          ),
//        ),
//        // toolbarHeight: 50,
//        elevation: 0.0,
//        bottom: TabBar(
//          isScrollable: true,
//          controller: _tabController,
//          indicatorColor: Colors.white,
//          labelColor: Colors.white,
//          // unselectedLabelColor: Colors.white,
//          labelStyle: TextStyle(
//            color: Colors.white,
//            fontSize: 12,
//            fontWeight: FontWeight.w800,
//          ),
//          unselectedLabelStyle: TextStyle(
//            fontSize: 12.0,
//            color: Colors.white,
//            fontWeight: FontWeight.w400,
//          ),
//          tabs: <Widget>[
//            Tab(
//              // icon: Icon(Icons.whatshot),
//              text: "Trending",
//            ),
//            Tab(
//              text: "Action",
//            ),
//            Tab(
//              text: "Adventure",
//            ),
//            Tab(
//              text: "African",
//            ),
//            Tab(
//              text: "HollyWood",
//            ),
//            Tab(
//              text: "NollyWood",
//            ),
//            Tab(
//              text: "Comedy",
//            ),
//          ],
//        ),
//      ),
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
        child: Center(
          child: Container(
            height: 100,
            color: Color(0xff041B9D),
            margin:
                const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () => pushNewScreen(
                  context,
                  screen: WebView(
                    title: "Leaderboard",
                    url: "https://abitplay.io/tournaments",
                  ),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                ),
                child: Text(
                  "View Leaderboard",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
//      WebView(title: "", url: "https://abitplay.io/tournaments"),

//      Container(
//        decoration: BoxDecoration(
//          image: DecorationImage(
//            image: AssetImage(
//              'assets/images/bg.jpg',
////             width: 220.0,
////             height: 120,
//            ),
////            colorFilter: ColorFilter.mode(
////                Colors.black.withOpacity(0.8), BlendMode.srcOver),
//            fit: BoxFit.fitWidth,
//          ),
//        ),
//        child: Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: SingleChildScrollView(
//            child: Column(
//              children: [
//                SizedBox(
//                  height: 5,
//                ),
//
//                // Padding(
//                //   padding: const EdgeInsets.symmetric(vertical:16.0),
//                //   child: Row(
//                //     children: [
//                //       // Text("Top Picks", style: TextStyle(fontWeight: FontWeight.w600),),
//                //     ],
//                //   ),
//                // ),
//                GridView.builder(
//                  scrollDirection: Axis.vertical,
//                  shrinkWrap: true,
//                  primary: false,
//                  physics: NeverScrollableScrollPhysics(),
//                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                    crossAxisCount: 2,
//                    childAspectRatio: MediaQuery.of(context).size.width /
//                        (MediaQuery.of(context).size.height / 1.8),
//                  ),
//                  itemCount: values == null ? 0 : values.length,
//                  itemBuilder: (BuildContext context, int index) {
//                    Map cat = values[index];
//                    String videolink = cat['url'].toString();
//                    return GestureDetector(
//                      onTap: () async {
//                        print(videolink);
//                        if (videolink.toString().contains('youtu', 0)) {
//                          String videoId;
//                          videoId = await YoutubePlayer.convertUrlToId(
//                              videolink.toString());
//                          print(videoId);
//                          print('youtube video');
//                          pushNewScreen(
//                            context,
//                            screen: YoutubeVideo(
//                              url: videoId ?? '',
//                              title: cat['title'].toString() ?? '',
//                              body: cat['desc'].toString() ?? '',
//                            ),
//                            withNavBar:
//                                false, // OPTIONAL VALUE. True by default.
//                            pageTransitionAnimation:
//                                PageTransitionAnimation.cupertino,
//                          );
//                        } else {
//                          pushNewScreen(
//                            context,
//                            screen: ZoomVideo(
//                              url: videolink.toString() ?? '',
//                              title: cat['title'].toString() ?? '',
//                              body: cat['desc'].toString() ?? '',
//                              // position: _controller.value.position,
//                            ),
//                            withNavBar:
//                                false, // OPTIONAL VALUE. True by default.
//                            pageTransitionAnimation:
//                                PageTransitionAnimation.cupertino,
//                          );
//                        }
//                      },
//                      child: Card(
//                        color: Colors.black,
//                        shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(18),
//                        ),
//                        child: Stack(
//                          children: [
//                            ClipRRect(
//                              borderRadius: BorderRadius.circular(18),
//                              child: Container(
//                                decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.circular(18.0),
//                                ),
//                                width: MediaQuery.of(context).size.width,
//                                height: MediaQuery.of(context).size.height,
//                                child: CachedNetworkImage(
//                                  fit: BoxFit.cover,
//                                  imageUrl: cat['img'].toString(),
//                                  placeholder: (context, url) => Image.asset(
//                                    'assets/images/loading.gif',
//                                    fit: BoxFit.cover,
//                                  ),
//                                  errorWidget: (context, url, error) =>
//                                      Image.asset(
//                                    'assets/images/loading.gif',
//                                    fit: BoxFit.cover,
//                                  ),
//                                ),
//                              ),
//                            ),
//                            Card(
//                              color: Colors.black.withOpacity(0.2),
//                              margin: EdgeInsets.all(0.0),
//                              shape: RoundedRectangleBorder(
//                                borderRadius: BorderRadius.circular(18),
//                              ),
//                              child: Container(),
//                            ),
//                            Card(
//                              margin: EdgeInsets.all(0.0),
//                              color: Theme.of(context)
//                                  .accentColor
//                                  .withOpacity(0.1),
//                              // color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.3),
//                              shape: RoundedRectangleBorder(
//                                borderRadius: BorderRadius.circular(18),
//                              ),
//                              elevation: 1,
//                              child: Stack(
//                                children: <Widget>[
//                                  // Positioned(
//                                  //     top: 30,
//                                  //     right: 10,
//                                  //
//                                  //     child: Icon(MyFlutterApp.award, size: 35,color: Colors.white.withOpacity(0.5),)),
//
//                                  Container(
////                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.2, ),
//                                    height: 180,
//                                    width: MediaQuery.of(context).size.width,
//                                  ),
//                                  Column(
//                                    mainAxisAlignment: MainAxisAlignment.end,
//                                    crossAxisAlignment:
//                                        CrossAxisAlignment.start,
//                                    children: [
//                                      Padding(
//                                        padding: const EdgeInsets.all(0.0),
//                                        child: ListTile(
////                        trailing: Text('${lists[i]['award_price'].toString()}'),
//                                          title: Text(
//                                            cat['title']
//                                                .toString()
//                                                .toUpperCase(),
//                                            maxLines: 1,
//                                            style: TextStyle(
//                                                color: Colors.white,
//                                                fontWeight: FontWeight.w800,
//                                                fontSize: 13),
//                                            overflow: TextOverflow.ellipsis,
//                                          ),
//                                          subtitle: Row(
//                                            mainAxisAlignment:
//                                                MainAxisAlignment.spaceBetween,
//                                            crossAxisAlignment:
//                                                CrossAxisAlignment.center,
//                                            children: [
//                                              Text(
//                                                cat['artist'].toString(),
//                                                style: TextStyle(
//                                                    color: Colors.white,
//                                                    fontWeight: FontWeight.w400,
//                                                    fontSize: 10),
//                                              ),
//                                              SmoothStarRating(
//                                                starCount: 5,
//                                                color: Colors.orange,
//                                                allowHalfRating: true,
//                                                rating: 5.0,
//                                                size: 8.0,
//                                              ),
//                                            ],
//                                          ),
//                                          // trailing:SmoothStarRating(
//                                          //   starCount: 5,
//                                          //   color: Colors.orange,
//                                          //   allowHalfRating: true,
//                                          //   rating: 5.0,
//                                          //   size: 8.0,
//                                          // ),
//                                        ),
//                                      ),
//                                    ],
//                                  ),
//                                  Positioned(
//                                      top: 1,
//                                      left: 1,
//                                      right: 1,
//                                      bottom: 1,
//                                      child: Icon(
//                                        Icons.play_circle_outline,
//                                        color: Colors.white,
//                                        size: 50,
//                                      ))
//                                ],
//                              ),
//                            ),
//                          ],
//                        ),
//                      ),
//                    );
//                    ;
//                    //   function:
//                    // );
//                  },
//                ),
//              ],
//            ),
//          ),
//        ),
//      ),
    );
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
        items: values,
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
          onTap: () async {
            String videolink = person['url'].toString();
            print(person['title'].toString());
            print(videolink);
            print(videolink);
            if (videolink.toString().contains('youtu', 0)) {
              String videoId;
              videoId =
                  await YoutubePlayer.convertUrlToId(videolink.toString());
              print(videoId);
              print('youtube video');
              pushNewScreen(
                context,
                screen: YoutubeVideo(
                  url: videoId ?? '',
                  title: person['title'].toString() ?? '',
                  body: person['desc'].toString() ?? '',
                ),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            } else {
              pushNewScreen(
                context,
                screen: ZoomVideo(
                  url: videolink.toString() ?? '',
                  title: person['title'].toString() ?? '',
                  body: person['desc'].toString() ?? '',
                  // position: _controller.value.position,
                ),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }
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
                    imageUrl: person['img'],
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
