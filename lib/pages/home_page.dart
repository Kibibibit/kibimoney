import 'package:flutter/material.dart';
import 'package:kibimoney/db/shared_prefs.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/pages/transaction_page.dart';
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
  late double fromLastPay;
  bool loading = true;
  late double largestSpendAmount;
  TagModel? largestSpend;
  Map<String, double> spending = {};
  List<TagModel> sortedTag = [];
  DateTime? lastPayDate;

  @override
  void initState() {
    super.initState();
    getStats();
  }

  Future<void> getLargestSpend() async {
    List<TagModel> tags = await TagModel.get();
    TransactionModel? lastPay = await TransactionModel.lastPay();
    late DateTime payDate;
    if (lastPay == null) {
      payDate = DateTime.fromMicrosecondsSinceEpoch(0);
    } else {
      payDate = lastPay.date;
      setState(() {
        lastPayDate = lastPay.date;
      });
    }

    Map<String, double> spends = {};
    for (TagModel tag in tags) {
      double a = await TransactionModel.sumOfTagDedit(
          tag, "date > ?", [payDate.toIso8601String()]);
      if (a != 0) {
        setState(() {
          sortedTag.add(tag);
        });
        if (!spends.containsKey(tag.name)) {
          spends[tag.name] = a;
        } else {
          spends[tag.name] = spends[tag.name]! + a;
        }
      }
    }

    setState(() {
      spending = spends;
      sortedTag.sort((a, b) => spending[b.name]!.compareTo(spending[a.name]!));
    });
  }

  Future<void> getStats() async {
    double lastPay = await TransactionModel.changeFromLastPay();
    getLargestSpend();

    setState(() {
      total = SharedPrefs.total;
      fromLastPay = lastPay;
      loading = false;
    });
  }

  void onTap(TagModel tag) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TransactionPage(canEdit: false, tag: tag, from: lastPayDate,)));
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              "You currently have:",
              style: theme.textTheme.headlineSmall,
            ),
            loading
                ? LoadingSpinner.centered()
                : Text(
                    "\$${Formatters.formatMoney(total)}",
                    style: theme.textTheme.headlineMedium,
                  ),
            const Padding(padding: EdgeInsets.all(8.0)),
            Text(
              "Change since last pay:",
              style: theme.textTheme.headlineSmall,
            ),
            loading
                ? LoadingSpinner.centered()
                : Text(
                    "\$${Formatters.formatMoney(fromLastPay)}",
                    style: theme.textTheme.headlineMedium,
                  ),
            const Padding(padding: EdgeInsets.all(8.0)),
            Text("Biggest expenses since last pay:",
                style: theme.textTheme.headlineSmall),
            const Divider(),
            sortedTag.isEmpty
                ? LoadingSpinner.centered()
                : Flexible(
                    child: Scrollbar(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: sortedTag.length,
                          itemBuilder: (context, index) => ListTile(
                                onTap: () => onTap(sortedTag[index]),
                                dense: true,
                                minVerticalPadding: 0,
                                leading: Icon(Icons.label,
                                    color: sortedTag[index].color),
                                title: Text(
                                  sortedTag[index].name,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                trailing: Text(
                                  "\$${Formatters.formatMoney(spending[sortedTag[index].name] ?? 0)}",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                ),
                              )),
                    ),
                  )
          ]),
        ),
      ),
    );
  }
}
