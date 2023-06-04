import 'package:flutter/material.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/pages/home_page.dart';
import 'package:kibimoney/pages/tag_page.dart';
import 'package:kibimoney/pages/transaction_page.dart';

class AppDrawer extends StatelessWidget {

  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          _DrawerTile(page: HomePage()),
          _DrawerTile(page: TagPage()),
          _DrawerTile(page: TransactionPage()),
        ],
      ),
    );
  }

}

class _DrawerTile extends StatelessWidget {

  final AbstractPage page;

  const _DrawerTile({required this.page});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(page.icon),
      title: Text(page.title),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>page)),
    );
  }



}