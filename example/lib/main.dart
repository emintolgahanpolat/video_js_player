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
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(primary: Colors.red),
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
  final TextEditingController _editingController = TextEditingController();
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
                child: const Text("Open Player")),
            ListTile(
              title: const Text("Sample 1"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HomePage(
                              url:
                                  "https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8",
                              isIframe: false,
                            )));
              },
            ),
            ListTile(
              title: const Text("Sample 2"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HomePage(
                              url:
                                  "https://d2zihajmogu5jn.cloudfront.net/elephantsdream/hls/ed_hd.m3u8",
                              isIframe: false,
                            )));
              },
            )
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
    // controller.setErrorListener((error) {
    //   showAdaptiveDialog(
    //       context: context,
    //       builder: (c) => AlertDialog(
    //             title: const Text("Error"),
    //             content: Text(error),
    //             actions: [
    //               TextButton(
    //                 onPressed: () => Navigator.pop(context),
    //                 child: const Text('Ok'),
    //               ),
    //             ],
    //           ));
    // });

    controller.load(widget.isIframe
        ? WebPlayerSource.iframe(widget.url)
        : WebPlayerSource.source(
            WebPlayerVideoSource.source(
              widget.url,
              WebPlayerVideoSourceType.mpegURL,
            ),
            autoPlay: false,
            poster:
                "https://i.ebayimg.com/images/g/lVMAAOSwhQheYrmk/s-l400.jpg",
            // customControlsBuilder: (controller) {
            //   return CustomWebPlayerController(controller);
            // },
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
