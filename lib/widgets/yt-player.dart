import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/video_info/video_info_screen.dart';
import 'package:yt_snatcher/services/youtube.dart';

class YtPlayer extends StatefulWidget {
  final String videoId;

  YtPlayer({@required this.videoId});

  @override
  State<YtPlayer> createState() {
    return YtPlayerState(id: videoId);
  }
}

class YtPlayerState extends State<YtPlayer> {
  final _yt = new Youtube();
  final String id;
  Video _video;

  YtPlayerState({@required this.id}) {
    _getVideo();
  }

  void _getVideo() async {
    var video = await _yt.getVideo(id);
    setState(() => _video = video);
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_video == null) return Center(child: CircularProgressIndicator());
    var url = _video.muxedStreams.highestResolution().url;
    return Center(
      child: BetterPlayer.network(
        url,
        betterPlayerConfiguration: BetterPlayerConfiguration(
          controlsConfiguration: BetterPlayerControlsConfiguration(
            overflowMenuCustomItems: [
              BetterPlayerOverflowMenuItem(
                Icons.info,
                "Info",
                () => Navigator.pushNamed(
                  context,
                  VideoInfoScreen.ROUTENAME,
                  arguments: _video,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
