import 'package:example/custom_web_player_controller_widget.dart';
import 'package:flutter/material.dart';
import 'package:video_js_player/video_js_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var controller = WebVideoPlayerController();
  @override
  void initState() {
    controller.setErrorListener((error) {
      showAdaptiveDialog(
          context: context,
          builder: (c) => AlertDialog(
                title: const Text("Error"),
                content: Text(error),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ok'),
                  ),
                ],
              ));
    });
    controller.load(WebPlayerSource.videoJs(
      "http://cfd-v4-service-channel-stitcher-use1-1.prd..tv/stitch/hls/channel/62ba60f059624e000781c436/master.m3u8?appName=web&appVersion=unknown&clientTime=0&deviceDNT=0&deviceId=6c25e430-30d3-11ef-9cf5-e9ddff8ff496&deviceMake=Chrome&deviceModel=web&deviceType=web&deviceVersion=unknown&includeExtendedEvents=false&serverSideAds=false&sid=1b7de8e4-d114-4438-b098-6f7aee77b4be",
      autoPlay: true,
      poster: "https://avatars.githubusercontent.com/u/3287189?s=200&v=4",
      customControlsBuilder: (controller) {
        return CustomWebPlayerController(controller);
      },
    ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: WebPlayerBuilder(
          player: WebPlayer(controller: controller),
          builder: (c, p) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Video JS"),
                  actions: [
                    IconButton(
                        onPressed: () {
                          controller.toggleFullScreenMode();
                        },
                        icon: const Icon(
                          Icons.fullscreen,
                          color: Colors.red,
                        ))
                  ],
                ),
                body: ListView(
                  children: [
                    p,
                    const SizedBox(
                      height: 24,
                    ),
                  ],
                ));
          }),
    );
  }
}
