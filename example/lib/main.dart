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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Video JS"),
        ),
        body: Column(
          children: [
            WebPlayer(
                source: WebPlayerSource.videoJs(
              "https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8",
              autoPlay: true,
              poster:
                  "https://avatars.githubusercontent.com/u/3287189?s=200&v=4",
              customControlsBuilder: (controller) {
                return CustomWebPlayerController(controller);
              },
            )),
            WebPlayer(
                source: WebPlayerSource.videoJs(
              "https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8",
              poster:
                  "https://avatars.githubusercontent.com/u/3287189?s=200&v=4",
            )),
          ],
        ));
  }
}
