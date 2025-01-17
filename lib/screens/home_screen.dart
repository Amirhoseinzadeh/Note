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

  bool isSearchActive = false; // حالت باز/بسته نوار جستجو
  TextEditingController searchController =
      TextEditingController(); // کنترلر جستجو



  @override
  Widget build(BuildContext context) {
    final box = Hive.box<UserModel>('user_Box');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5A630),
        title: AnimatedCrossFade(
          duration: Duration(milliseconds: 300),
          firstChild: DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            dropdownColor: Colors.white,
            underline: SizedBox(),
            items: itemsWithCount.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: TextStyle(color: Colors.black),

                    ),
                    Text(
                      '${itemsWithCount[value]}', // تعداد مربوط به هر آیتم
                      style: TextStyle(
                        color: Colors.grey, // رنگ تعداد
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
                  padding:
                      const EdgeInsets.only(right: 7.0, top: 7.0, bottom: 7.0),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white, // متن دیفالت سفید
                      fontSize: 20,
                    ),
                  ),
                );
              }).toList();
            },
          ),
          secondChild: TextField(
            controller: searchController,
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              // متنی که در حال جستجو هستید را اینجا مدیریت کنید
              // print(value);
            },
          ),
          crossFadeState: isSearchActive
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearchActive ? Icons.close : Icons.search,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                isSearchActive =
                    !isSearchActive; // تغییر وضعیت باز/بسته نوار جستجو
                if (!isSearchActive) {
                  searchController.clear(); // پاک کردن متن جستجو
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
        valueListenable: Hive.box<UserModel>('user_Box').listenable(),
        builder: (BuildContext context, Box box, Widget? child) {
          return box.isEmpty
              ? Center(child: Text('There is no any note'))
              : ListView.builder(
                  itemCount: box.length,
                  padding: EdgeInsets.all(10), // فاصله کلی از اطراف
                  itemBuilder: (context, index) {
                    final user = box.getAt(index);
                    return Card(
                      margin: EdgeInsets.only(bottom: 10), // فاصله بین کارت‌ها
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.white,
                      shadowColor: Colors.black,
                      child: ListTile(
                        title: Text(user.title ?? 'No Title',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),),
                        subtitle: Text(user.description ?? 'No Description'),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10), // فاصله داخل ListTile
                        onTap: () {
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowScreen(note: user,noteIndex: index,),
                              ),
                            );
                          }
                        },
                      )
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFC9401),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScreen(),
            ),
          );
        },
      ),
    );
  }
}
