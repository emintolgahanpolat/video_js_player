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
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({
    super.key,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _editingController = TextEditingController(
      text:
          "https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8");
  var isIframe = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            TextFormField(
              controller: _editingController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    _editingController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            CheckboxListTile(
              value: isIframe,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              onChanged: (v) {
                isIframe = !isIframe;
                setState(() {});
              },
              title: const Text("iFrame"),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HomePage(
                                url: _editingController.text,
                                isIframe: isIframe,
                              )));
                },
                child: const Text("Open Player"))
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String url;
  final bool isIframe;
  const HomePage({super.key, required this.url, required this.isIframe});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var controller = WebVideoPlayerController();
  @override
  void initState() {
    controller.setErrorListener((error) {
      print(error);
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
    controller.load(widget.isIframe
        ? WebPlayerSource.withUrl(
            widget.url,
            autoPlay: true,
            poster: "https://avatars.githubusercontent.com/u/3287189?s=200&v=4",
          )
        : WebPlayerSource.videoJs(
            widget.url,
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
    return WebPlayerBuilder(
        player: WebPlayer(
          controller: controller,
        ),
        builder: (c, player) {
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
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AspectRatio(aspectRatio: 16 / 9, child: player),
                ],
              ),
            ),
          );
        });
  }
}
