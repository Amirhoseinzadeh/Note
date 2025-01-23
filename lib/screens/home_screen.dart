import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note/model/user_model.dart';
import 'package:note/screens/add_screen.dart';
import 'package:note/screens/show_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box<UserModel>('user_Box');

  String dropdownValue = 'All notes';
  Map<String, int> itemsWithCount = {};
  bool isSearchActive = false;
  bool isSelectionMode = false;
  List<int> selectedIndexes = [];
  List<UserModel> filteredList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = box.values.toList().cast<UserModel>();
    updateItemsWithCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5A630),
        title: isSelectionMode
            ? Text(
                '${selectedIndexes.length} selected',
                style: const TextStyle(color: Colors.white),
              )
            : AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstChild: DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: itemsWithCount.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(value,
                              style: const TextStyle(color: Colors.black)),
                          Text(
                            '${itemsWithCount[value]}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    updateDropdownFilter(newValue);
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return itemsWithCount.keys.map((String value) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 7.0, top: 7.0, bottom: 7.0),
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
                secondChild: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _filterNotes(value);
                  },
                ),
                crossFadeState: isSearchActive
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      if (selectedIndexes.length == box.length) {
                        selectedIndexes.clear();
                      } else {
                        selectedIndexes =
                            List.generate(box.length, (index) => index);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_outlined,
                      color: Colors.white),
                  onPressed: () {
                    deleteSelectedNotes();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isSelectionMode = false;
                      selectedIndexes.clear();
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: Icon(
                    isSearchActive ? Icons.close : Icons.search,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      isSearchActive = !isSearchActive;
                      if (!isSearchActive) {
                        searchController.clear();
                        _filterNotes('');
                      }
                    });
                  },
                ),
              ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<UserModel>('user_Box').listenable(),
        builder: (context, box, _) {
          final allNotes = box.values.toList().cast<UserModel>();
          final List<UserModel> filteredList = dropdownValue == 'All notes'
              ? allNotes
              : allNotes.where((note) => note.isFavorite == true).toList();

          return filteredList.isEmpty
              ? const Center(child: Text('There is no any note'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: filteredList.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final user = filteredList[index];
                    final isSelected = selectedIndexes.contains(index);
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          isSelectionMode = true;
                          selectedIndexes.add(index);
                        });
                      },
                      onTap: () {
                        if (isSelectionMode) {
                          setState(() {
                            if (isSelected) {
                              selectedIndexes.remove(index);
                            } else {
                              selectedIndexes.add(index);
                            }
                            if (selectedIndexes.isEmpty) {
                              isSelectionMode = false;
                            }
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowScreen(
                                note: user,
                                noteIndex: index,
                                updateItemsWithCount: updateItemsWithCount,
                              ),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 11),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        color: isSelected ? Colors.blue[100] : Colors.white,
                        shadowColor: Colors.black,
                        child: ListTile(
                          leading: isSelectionMode
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value!) {
                                        selectedIndexes.add(index);
                                      } else {
                                        selectedIndexes.remove(index);
                                      }
                                      if (selectedIndexes.isEmpty) {
                                        isSelectionMode = false;
                                      }
                                    });
                                  },
                                )
                              : null,
                          title: Text(
                            user.title,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          subtitle: Text(
                            user.description,
                            maxLines: 1,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFC9401),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddScreen(updateItemsWithCount: updateItemsWithCount),
            ),
          );
        },
      ),
    );
  }

  void deleteSelectedNotes() {
    selectedIndexes.sort((a, b) => b.compareTo(a));
    for (int index in selectedIndexes) {
      box.deleteAt(index);
    }
    setState(() {
      selectedIndexes.clear();
      isSelectionMode = false;
      _filterNotes(searchController.text);
      updateItemsWithCount();
    });
  }

  void _filterNotes(String query) {
    final allNotes = box.values.toList().cast<UserModel>();
    setState(() {
      if (dropdownValue == 'Favorite') {
        filteredList = allNotes.where((note) => note.isFavorite).toList();
      } else {
        filteredList = allNotes;
      }

      if (query.isNotEmpty) {
        filteredList = filteredList
            .where((note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void updateDropdownFilter(String? newValue) {
    setState(() {
      dropdownValue = newValue!;
      _filterNotes(searchController.text);
      updateItemsWithCount();
    });
  }

  void updateItemsWithCount() {
    final allNotesCount = box.values.length;
    final favoriteCount = box.values.where((note) => note.isFavorite).length;
    setState(() {
      itemsWithCount = {
        'All notes': allNotesCount,
        'Favorite': favoriteCount,
      };
    });
  }
}
