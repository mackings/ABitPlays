import 'dart:convert';

import 'package:abitplay/network_utils/api.dart';
import 'package:abitplay/providers/app_provider.dart';
import 'package:abitplay/utils/smooth_star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GamesView extends StatefulWidget {
  final Map game;
  final bool isFav;
  final String favID;

  GamesView({@required this.game, this.isFav, this.favID});
  @override
  _GamesViewState createState() => _GamesViewState();
}

class _GamesViewState extends State<GamesView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading2 = false;
  bool isLoading = false;
  bool isFav;

  @override
  void initState() {
    isFav = widget.isFav;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var document = parse(widget.game["description"]);
    final String parsedString = parse(document.body.text).documentElement.text;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff031D39),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.game['title'],
        ),
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 10.0),
            Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  height: MediaQuery.of(context).size.height / 3.6,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Image.asset(
                        'assets/images/loading.gif',
                        fit: BoxFit.cover,
                      ),
                      imageUrl: widget.game["image"],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: -10.0,
                  bottom: 3.0,
                  child: RawMaterialButton(
                    onPressed: () {
                      if (isFav) {
                        print(widget.game["id"]);
                        _rmvFav();
                      } else {
                        _addtoFav();
                      }
                      // _sub2();
                    },
                    fillColor: Colors.white,
                    shape: CircleBorder(),
                    elevation: 4.0,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: isLoading2
                          ? Theme(
                              data: ThemeData(
                                  cupertinoOverrideTheme: CupertinoThemeData(
                                      brightness: Brightness.light)),
                              child: CupertinoActivityIndicator(
                                animating: true,
                              ),
                            )
                          : Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                              size: 17,
                            ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.0),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: Text(
                  widget.game["title"],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),

            SizedBox(
              height: 5,
            ),

            SmoothStarRating(
              starCount: 5,
              color: Colors.orange,
              allowHalfRating: true,
              rating: 5,
              size: 12.0,
            ),

            SizedBox(height: 12.0),

            Text(
              "About",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 2,
            ),
            SizedBox(height: 5.0),

            Text(
              parsedString,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
              maxLines: 1,
            ),

            SizedBox(height: 20.0),

            Text(
              "Game Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 2,
            ),

            SizedBox(height: 5.0),

            Text(
              parsedString,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),

            SizedBox(height: 20.0),

            Text(
              "Other Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 2,
            ),
            SizedBox(height: 10.0),

            // Text(widget.game["images"].toString()),

            // ListView.builder(
            //     shrinkWrap: true,
            //     primary: false,
            //     itemCount: widget.game["images"].length,
            //     itemBuilder: (BuildContext context, int index){
            //       var value = widget.game["images"];
            //       return Text(value[index]["image_original"].toString());
            //     }),

            (widget.game["images"] != null && widget.game["images"].isNotEmpty)
                ? CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 190,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.4,
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
                    itemCount: widget.game["images"].length,
                    itemBuilder: (BuildContext context, int i) {
                      var value = widget.game["images"];
                      //todo this is for gen random numbers
                      return GestureDetector(
                        // onTap: ()
                        // {
                        //   pushNewScreen(
                        //     context,
                        //     screen: GamesView(game: values[i], isFav: false,),
                        //     withNavBar: false, // OPTIONAL VALUE. True by default.
                        //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        //   );
                        // },
                        child: Card(
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        value[i]["image_original"].toString(),
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
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : SizedBox(),

            SizedBox(height: 20.0),
            // ListTile(
            //   title: Text("Average Rating"),
            //   trailing: Text(widget.product.averageRating),
            //   subtitle: Text("Availability: "+widget.product.stockStatus),
            // ),

            SizedBox(height: 10.0),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50.0,
        child: RaisedButton(
            child: isLoading
                ? Theme(
                    data: ThemeData(
                        cupertinoOverrideTheme:
                            CupertinoThemeData(brightness: Brightness.dark)),
                    child: CupertinoActivityIndicator(
                      animating: true,
                    ),
                  )
                : Text(
                    "Play",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
            color: Theme.of(context).accentColor,
            onPressed: () {
              _launchURL(widget.game["dynamic_link"].toString());
              // print(widget.game["dynamic_link"]);
              //   _showMsg('Not yet Installed');
            }),
      ),
    );
  }

  void _launchURL(_url) async =>
      await canLaunch(_url) ? await launch(_url) : _showMsg('Coming soon');

  void launchURL(String url, Function function) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      function();
      throw 'Could not launch $url';
    }
  }

  _addtoFav() async {
    var data = {
      "user_id": Provider.of<AppProvider>(context, listen: false)
          .data['id']
          .toString(),
      "game_id": widget.game['id'],
    };
    try {
      http.Response response = await Network().postData(data, "/favourites");
      print(response.body);
      var body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showMsg("successfully added to favourites");
        Network().sendCountriesDataRequest(1, context);
        setState(() {
          isFav = true;
        });
      } else {
        _showMsg(body["errors"]["game"].toString());
      }
    } on Exception catch (_) {
      _showMsg(_.toString());
    }
  }

  _rmvFav() async {
    if (widget.favID == null) {
      _showMsg("Already added to favourite");
    }
    var data = {
      // "user_id" : Provider.of<AppProvider>(context, listen: false).data['id'].toString(),
      "id": widget.favID,
    };
    try {
      print(data);
      http.Response response = await Network().postData(data, "/unfavourite");
      print(response.body);
      if (response.statusCode == 200) {
        _showMsg("successfully Removed favourites");
        setState(() {
          isFav = false;
        });
        Network()
            .sendCountriesDataRequest(1, context)
            .whenComplete(() => {Navigator.pop(context)});
      }
    } on Exception catch (_) {
      _showMsg(_.toString());
    }
  }

  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
