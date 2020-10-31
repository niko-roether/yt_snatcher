import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/util.dart';
import 'package:yt_snatcher/widgets/inherited/download_process_manager.dart';

// TODO add option to customize video quality

enum DownloadType { VIDEO, MUSIC }

class _DownloadInfo {
  String id;
  DownloadType type;
}

class DownloadForm extends StatefulWidget {
  final DownloadType initialDownloadType;

  DownloadForm({this.initialDownloadType = DownloadType.VIDEO})
      : assert(initialDownloadType != null);

  @override
  State<StatefulWidget> createState() => DownloadFormState();
}

class DownloadFormState extends State<DownloadForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: "Download Form");
  var _downloadInfo = _DownloadInfo();

  void _onError(ScaffoldState scaffold, _DownloadInfo info) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Failed to download ${info.id}"),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  void _download(BuildContext context, _DownloadInfo info) {
    var dpm = DownloadService.of(context);
    var scaffold = Scaffold.of(context);
    switch (_downloadInfo.type) {
      case DownloadType.VIDEO:
        dpm.downloadVideo(info.id).catchError((e) => _onError(scaffold, info));
        break;
      case DownloadType.MUSIC:
        dpm.downloadMusic(info.id).catchError((e) => _onError(scaffold, info));
        break;
    }
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text("Downloading video ${_downloadInfo.id}...")),
      );
    }
    _download(context, _downloadInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              validator: (value) {
                if (value.isEmpty) return "Please enter a url or video id";
                if (!validateYoutubeUrlOrId(value))
                  return "Please enter a valid url or video id.";
                return null;
              },
              onSaved: (value) => _downloadInfo.id = extractYoutubeId(value),
              decoration: InputDecoration(
                labelText: "Youtube url or video ID",
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onSubmit(context),
                    child: SizedBox(
                      child: Text("Download", textAlign: TextAlign.center),
                      width: double.infinity,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                FormField<DownloadType>(
                  builder: (field) {
                    return DropdownButton<DownloadType>(
                      items: [
                        DropdownMenuItem(
                          child: Text("as video"),
                          value: DownloadType.VIDEO,
                        ),
                        DropdownMenuItem(
                          child: Text("as music"),
                          value: DownloadType.MUSIC,
                        ),
                      ],
                      value: field.value,
                      onChanged: (v) => field.didChange(v),
                    );
                  },
                  onSaved: (value) => _downloadInfo.type = value,
                  initialValue: widget.initialDownloadType,
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.end,
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
      padding: EdgeInsets.all(16),
    );
  }
}
