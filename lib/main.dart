// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: 'iwcqAfHLWI8', // Bu yerga YouTube videoning ID sini kiriting
//       flags: YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("YouTube Video Player"),
//       ),
//       body: Center(
//         child: YoutubePlayer(
//           controller: _controller,
//           showVideoProgressIndicator: true,
//           onReady: () {
//             _controller.play();
//           },
//         ),
//       ),
//     );
//   }
// }









//buyerdan vidiolarni list qilib olib kelish boshlangan

// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final List<String> _videoIds = [
//     'fqoUwGOATXg',
//     'MpKlVsjqvVI',
//     'aAR8JQmaUIM',
//     // Bu yerga ko'proq video IDlar qo'shing
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("YouTube Video Player"),
//       ),
//       body: ListView.builder(
//         itemCount: _videoIds.length,
//         itemBuilder: (context, index) {
//           return YoutubePlayerWidget(videoId: _videoIds[index]);
//         },
//       ),
//     );
//   }
// }

// class YoutubePlayerWidget extends StatefulWidget {
//   final String videoId;

//   YoutubePlayerWidget({required this.videoId});

//   @override
//   _YoutubePlayerWidgetState createState() => _YoutubePlayerWidgetState();
// }

// class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: widget.videoId,
//       flags: YoutubePlayerFlags(
//         autoPlay: false,
//         mute: false,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       child: YoutubePlayer(
//         controller: _controller,
//         showVideoProgressIndicator: true,
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DbService _dbService = DbService();
  List<String> _videoIds = [];

  @override
  void initState() {
    super.initState();
    _loadVideoIds();
  }

  Future<void> _loadVideoIds() async {
    await _dbService.openBox();
    List<dynamic> videoIds = await _dbService.getTodos();
    setState(() {
      _videoIds = List<String>.from(videoIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("YouTube Video Player"),
      ),
      body: ListView.builder(
        itemCount: _videoIds.length,
        itemBuilder: (context, index) {
          return YoutubePlayerWidget(videoId: _videoIds[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addVideoIdDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addVideoIdDialog(BuildContext context) async {
    TextEditingController videoIdController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Video ID qo'shish"),
          content: TextField(
            controller: videoIdController,
            decoration: InputDecoration(hintText: "YouTube video ID kiriting"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String videoId = videoIdController.text;
                if (videoId.isNotEmpty) {
                  await _dbService.writeToDB(videoId);
                  setState(() {
                    _videoIds.add(videoId);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text("Qo'shish"),
            ),
          ],
        );
      },
    );
  }
}

class YoutubePlayerWidget extends StatefulWidget {
  final String videoId;

  YoutubePlayerWidget({required this.videoId});

  @override
  _YoutubePlayerWidgetState createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
