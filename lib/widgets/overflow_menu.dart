import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverflowMenuItem {
  final Widget icon;
  final String name;
  void Function() onPressed;

  OverflowMenuItem({@required this.name, this.icon, this.onPressed});
}

class OverflowMenu extends StatelessWidget {
  final List<OverflowMenuItem> items;

  OverflowMenu({this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) {
        return items.map<PopupMenuEntry<int>>((e) {
          return PopupMenuItem(
            key: Key(e.name),
            //FIXME inefficient as fuck but I couldn't care less rn
            value: items.indexOf(e),
            child: ListTile(
              leading: e.icon ?? Container(),
              title: Text(e.name ?? ""),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList();
      },
      onSelected: (i) => items[i].onPressed?.call(),
    );
  }
}
