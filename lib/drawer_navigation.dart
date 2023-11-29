import 'package:flutter/material.dart';
import 'package:fluttter_document_list/document_list_screen.dart';
import 'package:fluttter_document_list/person_name_list.dart';

class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({Key? key}) : super(key: key);

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Document List'),
              accountEmail: Text('Version 1.0'),
              currentAccountPicture: CircleAvatar(
                radius: 50.0,
                backgroundImage: AssetImage('images/flower1.jpg'),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.document_scanner,
              ),
              title: Text('Document List'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DocumentListScreen()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.person,
              ),
              title: Text('Person Name List'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PersonNameListScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
