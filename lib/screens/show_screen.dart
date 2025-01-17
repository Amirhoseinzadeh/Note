import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note/model/user_model.dart';

class ShowScreen extends StatefulWidget {
  final int noteIndex;
  final UserModel note;

  const ShowScreen({
    super.key,
    required this.note,
    required this.noteIndex,
  });

  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  bool isEditingTitle = false;
  bool isEditingDescription = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    descriptionController =
        TextEditingController(text: widget.note.description);
  }

  void updateNote() {
    final box = Hive.box<UserModel>('user_Box');

    final updatedNote = UserModel(
      title: titleController.text,
      description: descriptionController.text,
    );

    box.putAt(widget.noteIndex, updatedNote); // به‌روزرسانی یادداشت
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note updated successfully!'),
      ),
    );
    setState(() {
      isEditingTitle = false;
      isEditingDescription = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFC9401)),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_outline, color: Colors.black),
            onPressed: (){},
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: (){},
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: updateNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isEditingTitle = true;
                });
              },
              child: isEditingTitle
                  ? TextField(
                decoration: InputDecoration(
                  border: InputBorder.none
                ),
                controller: titleController,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onSubmitted: (_) => updateNote(),
              )
                  : Text(
                titleController.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  isEditingDescription = true;
                });
              },
              child: isEditingDescription
                  ? TextField(
                decoration: InputDecoration(
                    border: InputBorder.none
                ),
                controller: descriptionController,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
                onSubmitted: (_) => updateNote(),
              )
                  : Text(
                descriptionController.text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Last modified: ${DateTime.now().toLocal()}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
