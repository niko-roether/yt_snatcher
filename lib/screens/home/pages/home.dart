import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/listen/listen_screen.dart';

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
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, ListenScreen.ROUTENAME),
              child: Text("listen"),
            ),
          ],
        ),
      ),
    );
  }
}
