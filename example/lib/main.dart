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
          children: [
            TextFormField(
              controller: _editingController,
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HomePage(
                                url: _editingController.text,
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
  const HomePage({super.key, required this.url});

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
    controller.load(WebPlayerSource.videoJs(
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
