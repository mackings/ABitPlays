import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class ZoomVideo extends StatelessWidget {
  final String url;
  final String title;
  final String body;
  // final Duration position;
  static const String id = "ZoomVideo";
  ZoomVideo({Key key, @required this.url, this.title, this.body
    // this.position
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        toolbarHeight: 0.0,
      ),
      // backgroundColor: Colors.black,
      // appBar: new AppBar(
      //   backgroundColor: const Color(0xff211332),
      //   title: new Text(
      //     title,
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                new ZoomVideoScreen(url: url,
                  // position: position,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(title, style: TextStyle(fontWeight: FontWeight.w800),),
                ),
                Html(
                  // style: {
                  //   // tables will have the below background color
                  //   "table": Style(
                  //     backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                  //   ),
                  //   // some other granular customizations are also possible
                  //   "tr": Style(
                  //     border: Border(bottom: BorderSide(color: Colors.grey)),
                  //   ),
                  //   "th": Style(
                  //     padding: EdgeInsets.all(6),
                  //     backgroundColor: Colors.grey,
                  //   ),
                  //   "td": Style(
                  //     padding: EdgeInsets.all(6),
                  //     alignment: Alignment.topLeft,
                  //   ),
                  //   // text that renders h1 elements will be red
                  //   "h3": Style(color: Colors.red, fontWeight: FontWeight.w600),
                  // },
                  // shrinkWrap: true,
                  // onLinkTap: (e){
                  //   launchURL(
                  //     e,
                  //       () {
                  //       Fluttertoast.showToast(msg: 'unable to open $e');
                  //     },
                  //   );
                  // },
                  data: """$body""",
                ),
              ],
            ),
            Positioned(
              top: 3,
              left: 10,
              child: SafeArea(
                top: true,
                child: InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.black.withOpacity(0.5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.keyboard_backspace, color: Colors.white,),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ZoomVideoScreen extends StatefulWidget {
  final String url;
  // final Duration position;

  ZoomVideoScreen({Key key, @required this.url,
    // this.position
  }) : super(key: key);

  @override
  State createState() => new ZoomVideoScreenState(url: url,
      // position: position
  );
}

class ZoomVideoScreenState extends State<ZoomVideoScreen> {
  final String url;
  // final Duration position;
  VideoPlayerController _controller;

  ZoomVideoScreenState({Key key, @required this.url,
    // this.position
  });

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    _controller = VideoPlayerController.network(
      url,
//      closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.setLooping(false);
    _controller.initialize()
        // .then((value) =>
        // _controller.play().then((value) => _controller.seekTo(position)))
    ;
    print('******************printing new position');
    // print(position);

  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: MediaQuery.of(context).size.width,
      child: Container(
        padding: const EdgeInsets.all(0),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              VideoPlayer(_controller),
              _ControlsOverlay(controller: _controller),
              VideoProgressIndicator(_controller, allowScrubbing: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
            color: Colors.black26,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}