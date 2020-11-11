import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/audio_player/audio_player.dart';
import 'package:yt_snatcher/widgets/audio_player/audio_player_controller.dart';
import 'package:yt_snatcher/widgets/provider/download_provider.dart';
import 'package:yt_snatcher/widgets/screen.dart';

class ListenScreen extends StatelessWidget {
  static const ROUTENAME = "/listen";

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: Text("Listen to Music"),
      content: FutureBuilder<List<Download>>(
        future: DownloadProvider.of(context)
            .service
            .getMusic()
            .then((set) => set.getDownloads()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final downloads = snapshot.data;
          return YtsAudioPlayer(downloads: downloads);
        },
      ),
    );
  }
}
