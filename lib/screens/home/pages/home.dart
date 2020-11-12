import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/listen/listen_screen.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/audio_player/audio_player.dart';
import 'package:yt_snatcher/widgets/provider/download_provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text(
              "Absolutely amazing home screen.\n\nBy using our app you agree to our privacy policy as well as to be absolutely blown away by how amazing our home screen is.",
              textAlign: TextAlign.center,
            ),
            FutureBuilder<List<Download>>(
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
          ],
        ),
      ),
    );
  }
}
