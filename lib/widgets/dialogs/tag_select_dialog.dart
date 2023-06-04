import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/widgets/dialogs/app_dialog.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';
import 'package:kibimoney/widgets/tag_widget.dart';

class TagSelectDialog extends StatefulWidget {
  final List<int> selectedTags;

  const TagSelectDialog({super.key, required this.selectedTags});

  @override
  State<TagSelectDialog> createState() => _TagSelectDialogState();
}

class _TagSelectDialogState extends State<TagSelectDialog> {
  int tagCount = 0;
  List<int> selectedTags = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    selectedTags = widget.selectedTags;
    loadTags();
  }

  Future<void> loadTags() async {
    int queryTagCount = await TagModel.count();
    setState(() {
      tagCount = queryTagCount;
      loading = false;
    });
  }

  void onTap(TagModel tagModel) {
    setState(() {
      if (selectedTags.contains(tagModel.id!)) {
        selectedTags.remove(tagModel.id!);
      } else {
        selectedTags.add(tagModel.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: const Text("Select tags"),
      body: loading
          ? LoadingSpinner.centered()
          : Flexible(
            child: ListView.builder(
              shrinkWrap: true,
                itemCount: tagCount,
                itemBuilder: (BuildContext context, int index) => TagWidget(
                  tagId: TagModel.getNthId(index),
                  onTap: onTap,
                  selectedTags: selectedTags,
                ),
              ),
          ),
      actions: [TextButton(child: const Text("Save"), onPressed: () {Navigator.of(context).pop(selectedTags);})],
    );
  }
}
