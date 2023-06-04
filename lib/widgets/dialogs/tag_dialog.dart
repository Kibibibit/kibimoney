import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/widgets/dialogs/app_dialog.dart';

class TagDialog extends StatefulWidget {
  final TagModel? tag;
  final Function(String name, Color color) onSave;
  const TagDialog({super.key, this.tag, required this.onSave});

  @override
  State<TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  late TextEditingController controller;
  late bool editMode;
  late String name;
  late int red;
  late int green;
  late int blue;

  @override
  void initState() {
    super.initState();

    if (widget.tag != null) {
      editMode = true;
      name = widget.tag!.name;
      red = widget.tag!.color.red;
      green = widget.tag!.color.green;
      blue = widget.tag!.color.blue;
    } else {
      editMode = false;
      name = "";
      red = 255;
      blue = 0;
      green = 0;
    }

    controller = TextEditingController(text: name);
  }

  void setRed(int r) {
    setState(() {
      red = r;
    });
  }

  void setGreen(int g) {
    setState(() {
      green = g;
    });
  }

  void setBlue(int b) {
    setState(() {
      blue = b;
    });
  }

  Widget slider(
      {required int value,
      required Function(int) onChange,
      required Color color}) {
    return Slider(
      value: value.toDouble(),
      min: 0,
      max: 255,
      divisions: 256,
      onChanged: (val) {
        onChange(val.floor());
      },
      activeColor: color,
      label: "$value",
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.label,
              color: Color.fromARGB(255, red, green, blue),
            ),
          ),
          Text(editMode ? "Edit ${widget.tag!.name}" : "Create new tag"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onChanged: (value){
                setState(() {
                  name = value;
                });
              },
              decoration: const InputDecoration(label: Text("Tag Name")),
            ),
            slider(value: red, onChange: setRed, color: Colors.red),
            slider(value: green, onChange: setGreen, color: Colors.green),
            slider(value: blue, onChange: setBlue, color: Colors.blue),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              if (name.isEmpty) {
                name = "New Tag";
              }
              widget.onSave(name, Color.fromARGB(255, red, green, blue));
              Navigator.of(context).pop();
            },
            child: const Text("Save"))
      ],
    );
  }
}
