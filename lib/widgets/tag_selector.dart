import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/widgets/dialogs/tag_select_dialog.dart';

class TagSelector extends StatelessWidget {
  final List<int> selected;

  final void Function(List<int>) onChange;

  const TagSelector({super.key, this.selected = const [], required this.onChange,});

  Future<void> _doAddTag(BuildContext context) async {

    List<int> newTagIds = await showDialog(context: context, builder: (context) => TagSelectDialog(selectedTags: selected)) ?? selected; 
    onChange(newTagIds);
  }


  void _doRemoveTag(int tagId) {
    List<int> newTags = selected.where((element) => element!=tagId).toList();
    onChange(newTags);
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> children = selected.map<Widget>((e) => _TagChip(tagId: e, removeTag: _doRemoveTag,)).toList();
    children.add(InputChip(label: const Icon(Icons.add), onPressed: (){_doAddTag(context);},));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Tags"),
            IconButton(onPressed: () {_doAddTag(context);}, icon: const Icon(Icons.new_label)),
          ],
        ),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: children
        ),
      ],
    );
  }
}

class _TagChip extends StatefulWidget {
  final int tagId;

  const _TagChip({required this.tagId, required this.removeTag});
  final void Function(int) removeTag;

  @override
  State<_TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<_TagChip> {
  late TagModel tag;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTag();
  }

  Future<void> loadTag() async {
    TagModel? found = await TagModel.getById(widget.tagId);
    setState(() {
      tag = found!;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      if (widget.tagId != tag.id!) {
        loadTag();
      }
    }
    return loading
        ? Container()
        : InputChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.label, color: tag.color,),
                Text(tag.name),
              ],
            ),
            onPressed: () => widget.removeTag(widget.tagId),
            selected: false,
            checkmarkColor: tag.color,
          );
  }
}
