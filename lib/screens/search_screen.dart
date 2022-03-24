import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shakeagram/models/user_object.dart';
import 'package:shakeagram/screens/other_user_profile_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  late List<Widget> returnedItems = [];

  void searchUsers(String input) {
    returnedItems = [];
    FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: input)
        .get()
        .then((snapshot) {
      for (int i = 0; i < snapshot.docs.length; i++) {
        UserObject tempUserObject = UserObject.fromDocument(snapshot.docs[i]);
        returnedItems.add(GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OtherProfilePage(
                            title: widget.title,
                            uid: tempUserObject.getUID,
                          ))).then((value) {
                setState(() {});
              });
            },
            child: Text(tempUserObject.getName)));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: searchUsers,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text("Search")),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: returnedItems,
            ),
          )
        ],
      ),
    );
  }
}
