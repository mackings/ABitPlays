import 'dart:async';
import 'dart:ui';

import 'package:abitplay/ViewScreen/webview.dart';
import 'package:abitplay/services/firebase_analytics.dart';
import 'package:abitplay/utils/CustomWidgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';


enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }
class PodCastViewPage extends StatefulWidget {
  final String title;
  final String link;
  final String date;
  final String body;
  final String img;


  PodCastViewPage({
    @required this.title,
    @required this.date,
    @required this.link,
    @required this.body,
    @required this.img});

  @override
  _PodCastViewPageState createState() => _PodCastViewPageState();
}



class _PodCastViewPageState extends State<PodCastViewPage> {
  Duration duration;
  bool isPlaying = false;
  bool animate = false;
  PlayerMode mode;
  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;
  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;
  StreamSubscription<PlayerControlCommand> _playerControlCommandSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  open() async{
    await _initAudioPlayer();
    return _play();
  }


  @override
  void initState() {
    open();
//    _initAudioPlayer();
    super.initState();
    // FlutterStatusbarcolor.setNavigationBarColor(Colors.black, animate: true);
    // FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
    analytics.setCurrentScreen(screenName: "AudioPlayerScreen");
    analytics.logEvent(
        name: 'Listening_to_Pod_cast',
        parameters: {'Screen': 'Pod_cast_View_Screen',});
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    // FlutterStatusbarcolor.setNavigationBarColor(Colors.white, animate: true);
    // FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    // TODO: implement dispose
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Container(
            child: CachedNetworkImage(
              fit: BoxFit.fill,
              imageUrl: widget.img,
              placeholder: (context, url) => Image.asset(
                'assets/images/loading.gif',
                fit: BoxFit.cover,
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/loading.gif',
                fit: BoxFit.none,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Card(
                  elevation: 15.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    height:  MediaQuery.of(context).size.width/2,
                    width: MediaQuery.of(context).size.width/2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            Image.asset(
                              'assets/images/loading.gif',
                              fit: BoxFit.cover,
                            ),
                        imageUrl: widget.img ?? '',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

                ListTile(
                  title: Center(child: Text(widget.title, maxLines: 2, overflow: TextOverflow.fade, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),)),
                  subtitle: MarqueeWidget(
//                    pauseDuration: const Duration(minutes: 1),
                    animationDuration: const Duration(seconds: 30),
                  direction: Axis.horizontal,
                          child: Text(widget.body, style: TextStyle(color: Colors.white),),)),
                _audio (),

              ],
            ),
          ),
          Positioned(
            top: 10.0,
            left: 18.0,
            child:
            SafeArea(
              top: true,
              child: InkWell(
                onTap: () {Navigator.of(context).pop();},
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back, color: Colors.white, ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  _audio () {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('play_button'),
              onPressed: _isPlaying ? null : () => _play(),
              iconSize: 32.0,
              icon: Icon(Icons.play_arrow),
              color: Color(0xffFF9100),
            ),
            IconButton(
              key: Key('pause_button'),
              onPressed: _isPlaying ? () => _pause() : null,
              iconSize: 40.0,
              icon: Icon(Icons.pause_circle_filled),
              color: Color(0xffFF9100),
            ),
            IconButton(
              key: Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? () => _stop() : null,
              iconSize: 32.0,
              icon: Icon(Icons.stop),
              color: Color(0xffFF9100),
            ),
//                          Expanded(
//                            flex: 1,
//                            child: IconButton(
//                              onPressed: _earpieceOrSpeakersToggle,
//                              iconSize: 32.0,
//                              icon: _isPlayingThroughEarpiece
//                                  ? Icon(Icons.volume_up)
//                                  : Icon(Icons.hearing),
//                              color: Colors.cyan,
//                            ),
//                          ),
//
          ],
        ),

        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Stack(
                children: [
                  Slider(
                    onChanged: (v) {
                      final Position = v * _duration.inMilliseconds;
                      _audioPlayer
                          .seek(Duration(milliseconds: Position.round()));
                    },
                    activeColor: Color(0xffFF9100),
                    inactiveColor: Color(0xffFF9100).withOpacity(0.3),
                    value: (_position != null &&
                        _duration != null &&
                        _position.inMilliseconds > 0 &&
                        _position.inMilliseconds < _duration.inMilliseconds)
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                  ),
                ],
              ),
            ), _isPlaying == true && _position == null ?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Theme(data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark)),
                  child: CupertinoActivityIndicator(
                    animating: true,
                  ),
                ),
                SizedBox(width: 10,),
                Text('loading', style: TextStyle(color: Colors.white),),
              ],
            ):
            Text(
              _position != null
                  ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                  : _duration != null ? _durationText : '',
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
//todo: this is a backup
//            Text(
//              _position != null
//                  ? '${_positionText ?? ''} / ${_durationText ?? ''}'
//                  : _duration != null ? _durationText : '',
//              style: TextStyle(fontSize: 15.0),
//            ),
          ],
        ),
        //_audioPlayerState == AudioPlayerState.STOPPED ?
        InkWell(
          onTap: (){
            print(widget.link);
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => WebView(
                  url: widget.link ?? '',
                  title: widget.title ?? '',
                )));
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Play in Browser', style: TextStyle(color: Colors.white),),
                )),
          ),
        ),
        SizedBox(),

       // Text('State: $_audioPlayerState')
      ],


    );
  }



  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // TODO implemented for iOS, waiting for android impl
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
       // _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.notificationService;
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
          _position = p;
        }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
          _onComplete();
          setState(() {
            _position = _duration;
          });
        });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _playerControlCommandSubscription =
        _audioPlayer.onPlayerCompletion.listen((command) {
          print('command');
        });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
    });

    _playingRouteState = PlayingRouteState.speakers;
  }


  Future<int> _play() async {
    String url = widget.link;
    final playPosition = (_position != null &&
        _duration != null &&
        _position.inMilliseconds > 0 &&
        _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) setState(()  {_playerState = PlayerState.playing; animate = true;} );

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    //_audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(()  {_playerState = PlayerState.paused; animate = false;});
    return result;
  }

  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1)
      setState(() => _playingRouteState =
      _playingRouteState == PlayingRouteState.speakers
          ? PlayingRouteState.earpiece
          : PlayingRouteState.speakers);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
        animate = false;
      });
//      _ac.reverse();
    }
    return result;
  }

  void _onComplete() {
    _stop();
//    int stat = _statNum;
//    int newStat = stat+5;
//    if (widget.isToday == true && _statNum < 6){
//      crudObj.upDateStat(formattedDate.format(currentDate).toString(),
//          {
////            'day': _day,
////            'date': clickedDay,
//            'stat': newStat,
//          });
//
//      _stop();
//      Future.delayed(Duration(milliseconds: 500), (){
//        Fluttertoast.showToast(msg: 'stat: $newStat');
//        _getStat();
//      });
//
//    }else{
//      _stop();
//    }
  }
}
