import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';

class TagWidget extends StatefulWidget {
  final int tagId;
  final Function(TagModel tag) onTap;
  final Function(TagModel tag) onDelete;

  const TagWidget(
      {super.key,
      required this.tagId,
      required this.onTap,
      required this.onDelete});

  @override
  State<TagWidget> createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  late TagModel tagModel;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loadTag();
  }

  Future<void> loadTag() async {
    TagModel? tag = await TagModel.getById(widget.tagId);
    if (tag != null) {
      setState(() {
        loading = false;
        tagModel = tag;
      });
    } else {
      setState(() {
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? ListTile(
            title: LoadingSpinner.centered(),
          )
        : ListTile(
            title: error
                ? Text("Could not get tag ${widget.tagId}!")
                : Text(tagModel.name),
            leading: Icon(
              Icons.label,
              color: tagModel.color,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey,),
              onPressed: () {
                if (!loading && !error) {
                  widget.onDelete(tagModel);
                }
              },
            ),
            onTap: () {
              if (!loading && !error) {
                widget.onTap(tagModel);
              }
            },
          );
  }
}
