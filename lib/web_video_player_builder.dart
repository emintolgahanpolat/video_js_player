import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_js_player/web_video_player.dart';

// /// A wrapper for [WebPlayer].
// class WebPlayerBuilder extends StatefulWidget {
//   /// Builder for [WebPlayer] that supports switching between fullscreen and normal mode.
//   const WebPlayerBuilder({
//     super.key,
//     required this.player,
//     required this.builder,
//     this.onEnterFullScreen,
//     this.onExitFullScreen,
//   });

//   /// The actual [WebPlayer].
//   final WebPlayer player;

//   /// Builds the widget below this [builder].
//   final Widget Function(BuildContext, Widget) builder;

//   /// Callback to notify that the player has entered fullscreen.
//   final VoidCallback? onEnterFullScreen;

//   /// Callback to notify that the player has exited fullscreen.
//   final VoidCallback? onExitFullScreen;

//   @override
//   State<WebPlayerBuilder> createState() => _WebPlayerBuilderState();
// }

// class _WebPlayerBuilderState extends State<WebPlayerBuilder>
//     with WidgetsBindingObserver {
//   final GlobalKey playerKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeMetrics() {
//     final physicalSize = PlatformDispatcher.instance.views.first.physicalSize;
//     final controller = widget.player.controller;
//     if (physicalSize.width > physicalSize.height) {
//       controller.updateValue(controller.value.copyWith(isFullScreen: true));
//       //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//       widget.onEnterFullScreen?.call();
//     } else {
//       controller.updateValue(controller.value.copyWith(isFullScreen: false));
//       //SystemChrome.restoreSystemUIOverlays();
//       widget.onExitFullScreen?.call();
//     }
//     super.didChangeMetrics();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final player = Container(
//       key: playerKey,
//       child: PopScope(
//         canPop: !widget.player.controller.value.isFullScreen,
//         onPopInvokedWithResult: (didPop, result) {
//           if (!didPop) {
//             widget.player.controller.toggleFullScreenMode();
//           }
//         },
//         child: widget.player,
//       ),
//     );
//     final child = widget.builder(context, player);

//     return OrientationBuilder(
//       builder: (context, orientation) {
//         return orientation == Orientation.portrait
//             ? child
//             : Material(color: Colors.black, child: Center(child: player));
//       },
//     );
//   }
// }
