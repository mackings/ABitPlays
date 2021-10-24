import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideo extends StatefulWidget {
  final String url;
  final String title;
  final String body;
  static const String id = "ZoomVideo";
  YoutubeVideo({Key key, @required this.url, this.title, this.body})
      : super(key: key);
  @override
  _YoutubeVideoState createState() => _YoutubeVideoState();
}

class _YoutubeVideoState extends State<YoutubeVideo> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  YoutubePlayerController _controller;
  TextEditingController _idController;
  TextEditingController _seekToController;
  PlayerState _playerState;
  YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

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
    scaffoldKey.currentState?.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller = YoutubePlayerController(
      initialVideoId: widget.url,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _videoMetaData = const YoutubeMetaData();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.landscapeRight,
      // DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Color(0xff031D39),
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              log('Settings Tapped!');
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          // _controller
          //     .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
          _showSnackBar('Video Ended!');
        },
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff031D39),
          automaticallyImplyLeading: true,
          // leading: Padding(
          //   padding: const EdgeInsets.only(left: 12.0),
          //   child: Text(_videoMetaData.title)
          // ),
          title: Text(
            _videoMetaData.title,
            // style: TextStyle(color: Colors.white),
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.video_library),
          //     onPressed: () => Navigator.push(
          //       context,
          //       CupertinoPageRoute(
          //         builder: (context) => VideoList(),
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: ListView(
          children: [
            player,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _space,
                  _text('Title', _videoMetaData.title),
                  _space,
                  _text('Channel', _videoMetaData.author),
                  // _space,
                  // _text('Video Id', _videoMetaData.videoId),
                  _space,
                  // Row(
                  //   children: [
                  //     _text(
                  //       'Playback Quality',
                  //       _controller.value.playbackQuality ?? '',
                  //     ),
                  //     // const Spacer(),
                  //     // _text(
                  //     //   'Playback Rate',
                  //     //   '${_controller.value.playbackRate}x  ',
                  //     // ),
                  //   ],
                  // ),
                  _space,
                  // TextField(
                  //   enabled: _isPlayerReady,
                  //   controller: _idController,
                  //   decoration: InputDecoration(
                  //     border: InputBorder.none,
                  //     hintText: 'Enter youtube \<video id\> or \<link\>',
                  //     fillColor: Colors.blueAccent.withAlpha(20),
                  //     filled: true,
                  //     hintStyle: const TextStyle(
                  //       fontWeight: FontWeight.w300,
                  //       color: Colors.blueAccent,
                  //     ),
                  //     suffixIcon: IconButton(
                  //       icon: const Icon(Icons.clear),
                  //       onPressed: () => _idController.clear(),
                  //     ),
                  //   ),
                  // ),
                  // _space,
                  // Row(
                  //   children: [
                  //     _loadCueButton('LOAD'),
                  //     const SizedBox(width: 10.0),
                  //     _loadCueButton('CUE'),
                  //   ],
                  // ),
                  _space,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // IconButton(
                      //   icon: const Icon(Icons.skip_previous),
                      //   onPressed: _isPlayerReady
                      //       ? () => _controller.load(_ids[
                      //   (_ids.indexOf(_controller.metadata.videoId) -
                      //       1) %
                      //       _ids.length])
                      //       : null,
                      // ),
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: _isPlayerReady
                            ? () {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                                setState(() {});
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                        onPressed: _isPlayerReady
                            ? () {
                                _muted
                                    ? _controller.unMute()
                                    : _controller.mute();
                                setState(() {
                                  _muted = !_muted;
                                });
                              }
                            : null,
                      ),
                      FullScreenButton(
                        controller: _controller,
                        color: Color(0xff031D39),
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.skip_next),
                      //   onPressed: _isPlayerReady
                      //       ? () => _controller.load(_ids[
                      //   (_ids.indexOf(_controller.metadata.videoId) +
                      //       1) %
                      //       _ids.length])
                      //       : null,
                      // ),
                    ],
                  ),
                  _space,
                  Row(
                    children: <Widget>[
                      const Text(
                        "Volume",
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                      Expanded(
                        child: Slider(
                          inactiveColor: Colors.transparent,
                          value: _volume,
                          min: 0.0,
                          max: 100.0,
                          divisions: 10,
                          label: '${(_volume).round()}',
                          onChanged: _isPlayerReady
                              ? (value) {
                                  setState(() {
                                    _volume = value;
                                  });
                                  _controller.setVolume(_volume.round());
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  _space,
                  // AnimatedContainer(
                  //   duration: const Duration(milliseconds: 800),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(20.0),
                  //     color: _getStateColor(_playerState),
                  //   ),
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Text(
                  //     _playerState.toString(),
                  //     style: const TextStyle(
                  //       fontWeight: FontWeight.w300,
                  //       color: Colors.white,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // return Scaffold(
    //   key: scaffoldKey,
    //   appBar: AppBar(
    //     backgroundColor: Colors.black,
    //     elevation: 0.0,
    //     toolbarHeight: 0.0,
    //   ),
    //   body: SingleChildScrollView(
    //     child: Stack(
    //       children: [
    //         Column(
    //           children: [
    //             YoutubePlayer(
    //               onReady: () {
    //               _controller.addListener(listener);},
    //               controller: _controller,
    //               showVideoProgressIndicator: true,
    //               progressIndicatorColor: Colors.amber,
    //             ),
    //
    //             Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.w800),),
    //             ),
    //             Html(
    //               // style: {
    //               //   // tables will have the below background color
    //               //   "table": Style(
    //               //     backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
    //               //   ),
    //               //   // some other granular customizations are also possible
    //               //   "tr": Style(
    //               //     border: Border(bottom: BorderSide(color: Colors.grey)),
    //               //   ),
    //               //   "th": Style(
    //               //     padding: EdgeInsets.all(6),
    //               //     backgroundColor: Colors.grey,
    //               //   ),
    //               //   "td": Style(
    //               //     padding: EdgeInsets.all(6),
    //               //     alignment: Alignment.topLeft,
    //               //   ),
    //               //   // text that renders h1 elements will be red
    //               //   "h3": Style(color: Colors.red, fontWeight: FontWeight.w600),
    //               // },
    //               // shrinkWrap: true,
    //               // onLinkTap: (e){
    //               //   launchURL(
    //               //     e,
    //               //     _showMsg('unable to open $e'),
    //               //   );
    //               // },
    //               data: """${widget.body}""",
    //             ),
    //
    //           ],
    //         ),
    //         Positioned(
    //           top: 10,
    //           left: 10,
    //           child: SafeArea(
    //             top: true,
    //             child: InkWell(
    //                 onTap: (){
    //                   Navigator.pop(context);
    //                 },
    //                 child: Container(
    //                     decoration: BoxDecoration(
    //                       borderRadius: BorderRadius.circular(30.0),
    //                     color: Colors.black.withOpacity(0.5)
    //                     ),
    //                     child: Padding(
    //                       padding: const EdgeInsets.all(8.0),
    //                       child: Icon(Icons.keyboard_backspace, color: Colors.white,),
    //                     )),
    //               ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Color(0xff031D39),
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              // color: Colors.blueAccent,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700];
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Color(0xff031D39);
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900];
      default:
        return Colors.blue;
    }
  }

  Widget get _space => const SizedBox(height: 10);

  Widget _loadCueButton(String action) {
    return Expanded(
      child: MaterialButton(
        color: Color(0xff031D39),
        onPressed: _isPlayerReady
            ? () {
                if (_idController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                        _idController.text,
                      ) ??
                      '';
                  if (action == 'LOAD') _controller.load(id);
                  if (action == 'CUE') _controller.cue(id);
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  _showSnackBar('Source can\'t be empty!');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Color(0xff031D39),
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
