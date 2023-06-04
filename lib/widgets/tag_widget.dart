import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';

class TagWidget extends StatefulWidget {
  final Future<int> tagId;
  final Function(TagModel tag) onTap;
  final Function(TagModel tag)? onDelete;
  final Widget? trailing;
  final List<int>? selectedTags;

  const TagWidget(
      {super.key,
      required this.tagId,
      required this.onTap,
      this.onDelete,
      this.trailing,
      this.selectedTags});

  @override
  State<TagWidget> createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  late TagModel tagModel;
  late int tagId;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loadTag();
  }

  Future<void> loadTag() async {
    int newTagId = await widget.tagId;
    setState(() {
      tagId = newTagId;
    });

    TagModel? tag = await TagModel.getById(newTagId);
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    bool? selected;
    if (!loading) {
      if (widget.selectedTags != null) {
        selected = widget.selectedTags!.contains(tagId);
      }
    }

    return loading
        ? ListTile(
            title: LoadingSpinner.centered(),
          )
        : ListTile(
            title:
                error ? Text("Could not get tag $tagId!") : Text(tagModel.name),
            leading: Icon(
              Icons.label,
              color: tagModel.color,
            ),
            trailing: widget.trailing ??
                ((selected ?? false)
                    ? const Icon(Icons.check)
                    : (widget.onDelete != null
                        ? IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              if (!loading &&
                                  !error &&
                                  widget.onDelete != null) {
                                widget.onDelete!(tagModel);
                              }
                            },
                          )
                        : null)),
            onTap: () {
              if (!loading && !error) {
                widget.onTap(tagModel);
              }
            },
          );
  }
}
