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
  String dropdownValue = 'All notes';
  final Map<String, int> itemsWithCount = {
    'All notes': 5,
    'Favorite': 3,
  };

  @override
  void initState() {
    super.initState();
    final box = Hive.box<UserModel>('user_Box');
    filteredList = box.values.toList().cast<UserModel>();
  }


  bool isSearchActive = false;
  bool isSelectionMode = false; // حالت انتخابی
  List<int> selectedIndexes = [];
  List<UserModel> filteredList = [];
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<UserModel>('user_Box');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5A630),
        title: isSelectionMode
            ? Text(
                '${selectedIndexes.length} selected',
                style: TextStyle(color: Colors.white),
              )
            : AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstChild: DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
                  items: itemsWithCount.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            '${itemsWithCount[value]}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
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
                    _filterNotes(value, box);
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
                        // اگر همه انتخاب شده‌اند، همه را لغو کن
                        selectedIndexes.clear();
                      } else {
                        // اگر هیچ یا تعدادی انتخاب شده‌اند، همه را انتخاب کن
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
                    _deleteSelectedNotes(box);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_outline, color: Colors.white),
                  onPressed: () {
                    // عملیات علاقه‌مندی
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
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
                      }
                    });
                  },
                ),
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 1,
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text('Manage category'),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    // عمل مربوط به آیتم انتخاب شده را اینجا پیاده‌سازی کنید
                  },
                  style: ButtonStyle(
                    iconColor: WidgetStateProperty.all(Colors.white),
                  ),
                ),
              ],
      ),
      body: ValueListenableBuilder<Box<UserModel>>(
        valueListenable: box.listenable(),
        builder: (BuildContext context, Box box, Widget? child) {
          if(!isSearchActive){
            // زمانی که جستجو فعال نیست، لیست فیلتر شده را از دیتابیس بروز می‌کنیم
            filteredList = box.values.toList().cast<UserModel>();
          }
          return filteredList.isEmpty
              ? const Center(child: Text('There is no any note'))
              : ListView.builder(
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
                              builder: (context) =>
                                  ShowScreen(note: user, noteIndex: index),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
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
                            maxLines: 1,
                            user.title ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          subtitle: Text(
                              maxLines: 1,
                              user.description ?? 'No Description'),
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
              builder: (context) => const AddScreen(),
            ),
          );
        },
      ),
    );
  }

  void _deleteSelectedNotes(Box box) {
    // حذف از آخرین ایندکس به اولین
    selectedIndexes.sort((a, b) => b.compareTo(a)); // مرتب‌سازی نزولی
    for (int index in selectedIndexes) {
      box.deleteAt(index);
    }
    setState(() {
      selectedIndexes.clear();
      isSelectionMode = false;
    });
  }
  void _filterNotes(String query, Box<UserModel> box) {
    setState(() {
      if (query.isEmpty) {
        filteredList = box.values.toList().cast<UserModel>();
      } else {
        filteredList = box.values
            .where((note) =>
        (note.title?.toLowerCase().contains(query.toLowerCase()) ??
            false) ||
            (note.description
                ?.toLowerCase()
                .contains(query.toLowerCase()) ??
                false))
            .toList()
            .cast<UserModel>();
      }
    });
  }

}
