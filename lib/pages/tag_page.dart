import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/widgets/app_scaffold.dart';
import 'package:kibimoney/widgets/dialogs/confirm_dialog.dart';
import 'package:kibimoney/widgets/dialogs/tag_dialog.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';
import 'package:kibimoney/widgets/tag_widget.dart';

class TagPage extends StatefulWidget implements AbstractPage {
  const TagPage({super.key});

  @override
  IconData get icon => Icons.label;

  @override
  String get title => "Tags";

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  List<int> tagIds = [];
  int tagCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTags();
  }

  Future<void> loadTags() async {
    int queryCount = await TagModel.count();
    setState(() {
      tagCount = queryCount;
      loading = false;
    });
  }

  Future<void> editTag([TagModel? tag]) async {
    late String name;
    late Color color;
    bool saved = false;
    await showDialog(
        context: context,
        builder: (context) => TagDialog(
              tag: tag,
              onSave: (String n, Color c) {
                name = n;
                color = c;
                saved = true;
              },
            ));
    if (!saved) {
      return;
    }
    setState(() {
      loading = true;
    });
    if (tag != null) {
      tag.color = color;
      tag.name = name;
    } else {
      tag = TagModel(name, color);
    }
    await tag.save();
    loadTags();
  }

  Future<void> deleteTag(TagModel tag) async {
    bool delete = await showDialog(
            context: context,
            builder: (context) => const ConfirmDialog(
                bodyText:
                    "Deleting this tag will remove it from all associated transactions and cannot be undone.")) ??
        false;
    if (delete) {
      setState(() {
        loading = true;
      });
      await tag.delete();
      loadTags();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      icon: widget.icon,
      actions: [
        IconButton(
            onPressed: () {editTag();}, icon: const Icon(Icons.new_label))
      ],
      body: loading
          ? LoadingSpinner.centered()
          : ListView.builder(
              itemCount: tagCount,
              itemBuilder: (context, index) => TagWidget(
                tagId: TagModel.getNthId(index),
                onTap: (tag) => editTag(tag),
                onDelete: (tag) => deleteTag(tag),
              ),
            ),
    );
  }
}
