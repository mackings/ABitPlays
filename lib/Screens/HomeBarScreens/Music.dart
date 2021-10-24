import 'dart:math';

import 'package:abitplay/ViewScreen/audioview.dart';
import 'package:abitplay/services/firebase_analytics.dart';
import 'package:abitplay/utils/CustomWidgets.dart';
import 'package:abitplay/utils/smooth_star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:search_page/search_page.dart';

class Music extends StatefulWidget {
  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<dynamic> values = [
    {
      "title": "TATUC",
      "artist": "Frankcee",
      "desc":
          "Tat Anthem is a classic drop from frankcee showing all applicable use case of the community token",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2FTatcoin.jpeg?alt=media&token=4fff48bb-0527-42a0-bd06-a9107e81e55d",
      "url":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Audio%2FTatcoin.mpeg?alt=media&token=9db79844-c58f-4503-9bc4-cef00b6439c1"
    },
    {
      "title": "Raevel",
      "artist": "Raebel",
      "desc":
          "Konvest Music artiste Raebel make her debut in the music scene with two smashing singles. ",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2Fimage1%20(1).jpeg?alt=media&token=5e4e3876-0c71-4727-94de-ca260b62ca50",
      "url":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Audio%2FRaebel%20-%20Raevel.mp3?alt=media&token=005fa5b1-7701-46cf-bd4b-249e42ae0f27",
    },
    {
      "title": "Durotimi",
      "artist": "Raebel",
      "desc":
          "Konvest Music artiste Raebel make her debut in the music scene with two smashing singles. ",
      "rating": 5.0,
      "img":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Images%2Fimage0%20(2).jpeg?alt=media&token=03698e10-2c5c-4162-83f4-c6fa792e1188",
      "url":
          "https://firebasestorage.googleapis.com/v0/b/abitgames-acfcc.appspot.com/o/Audio%2FRaebel%20-%20Durotimi.mp3?alt=media&token=3ac95667-41ca-4c5e-8e41-8a2850316f67"
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff031D39),
        title: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SearchBox(
            isLoading: false,
            focusNode: null,
            hintText: 'Search Music',
            textEditingController: null,
            function: () {
              search();
            },
          ),
        ),
        // toolbarHeight: 50,
        elevation: 0.0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          // unselectedLabelColor: Colors.white,
          labelStyle: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.0,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          tabs: <Widget>[
            Tab(
              text: "Trending",
            ),
            Tab(
              text: "Jazz",
            ),
            Tab(
              text: "Gospel",
            ),
            Tab(
              text: "HipHop",
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
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
                SizedBox(
                  height: 5,
                ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical:16.0),
                //   child: Row(
                //     children: [
                //       // Text("Top Picks", style: TextStyle(fontWeight: FontWeight.w600),),
                //     ],
                //   ),
                // ),
                GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.8),
                  ),
                  itemCount: values == null ? 0 : values.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map cat = values[index];
                    return GestureDetector(
                      onTap: () {
                        pushNewScreen(
                          context,
                          screen: PodCastViewPage(
                              title: cat['title'].toString(),
                              date: "friday, 15th May 2021",
                              link: cat["url"].toString(),
                              body: cat["desc"].toString(),
                              img: cat['img'].toString()),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
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
                                  imageUrl: cat['img'].toString(),
                                  placeholder: (context, url) => Image.asset(
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
                              color: Colors.black.withOpacity(0.2),
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
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: ListTile(
//                        trailing: Text('${lists[i]['award_price'].toString()}'),
                                          title: Text(
                                            cat['title']
                                                .toString()
                                                .toUpperCase(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                cat['artist'] ?? 'ABiTPlay',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 10),
                                              ),
                                              SmoothStarRating(
                                                starCount: 5,
                                                color: Colors.orange,
                                                allowHalfRating: true,
                                                rating: cat['rating'],
                                                size: 8.0,
                                              ),
                                            ],
                                          ),
                                          // trailing:SmoothStarRating(
                                          //   starCount: 5,
                                          //   color: Colors.orange,
                                          //   allowHalfRating: true,
                                          //   rating: 5.0,
                                          //   size: 8.0,
                                          // ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                      top: 1,
                                      left: 1,
                                      right: 1,
                                      bottom: 1,
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 50,
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    ;
                    //   function:
                    // );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
          textTheme: Theme.of(context).textTheme.copyWith(
                headline6: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
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
          onTap: () {
            print(person['title'].toString());
            pushNewScreen(
              context,
              screen: PodCastViewPage(
                  title: person['title'].toString(),
                  date: "friday, 15th May 2021",
                  link: person['url'].toString(),
                  body: person['desc'].toString(),
                  img: person['img'].toString()),
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
