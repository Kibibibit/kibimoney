import 'package:flutter/material.dart';
import 'package:kibimoney/db/shared_prefs.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/utils/formatters.dart';
import 'package:kibimoney/widgets/app_scaffold.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';

class HomePage extends StatefulWidget implements AbstractPage {
  @override
  IconData get icon => Icons.home;

  @override
  String get title => "Home";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late double total;
  bool loading = true;


  @override
  void initState() {
    super.initState();
    getStats();
  }

  Future<void> getStats() async {
    total = SharedPrefs.total;
    setState(() {
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return AppScaffold(
      title: widget.title, 
      icon: widget.icon,
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("You currently have:", style: theme.textTheme.headlineSmall,),
                loading ? LoadingSpinner.centered() : Text("\$${Formatters.formatMoney(total)}",style: theme.textTheme.headlineMedium,)
              ],
            ),
          ),
      ),
    );
  }
}
