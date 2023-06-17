import 'package:flutter/material.dart';
import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/db/shared_prefs.dart';
import 'package:kibimoney/pages/home_page.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});


  Future<void> _doLoad() async {
    await DatabaseUtils.loadDatabase();
    await SharedPrefs.loadPrefs();
    await DatabaseUtils.getTotal();
  }



  @override
  Widget build(BuildContext context) {

    _doLoad().then((_) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const HomePage()));
    });

    return Scaffold(
      body: LoadingSpinner.centered(),
    );
  }




}