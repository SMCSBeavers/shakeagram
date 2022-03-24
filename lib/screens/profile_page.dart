import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shakeagram/models/post_object.dart';
import 'package:shakeagram/models/user_object.dart';
import 'package:shakeagram/screens/single_post.dart';
import 'package:shakeagram/widgets/profile_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void dummyFunction() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
          stream: firestore
              .collection('users')
              .where('uid', isEqualTo: auth.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              UserObject profile =
                  UserObject.fromDocument(snapshot.data!.docs.first);
              return StreamBuilder(
                  stream: firestore
                      .collection('posts')
                      .where('uid', isEqualTo: profile.getUID)
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      List<Widget> listChildren = [];
                      listChildren.add(ProfileCard(
                        profile: profile,
                        isCurrentUser: true,
                        isFollowing: false,
                        followFunction: dummyFunction,
                      ));
                      for (int p = 0; p < snapshot.data!.docs.length; p++) {
                        PostObject post =
                            PostObject.fromDocument(snapshot.data!.docs[p]);
                        listChildren.add(GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SinglePost(
                                          title: widget.title,
                                          post: post,
                                        ))).then((value) {
                              setState(() {});
                            });
                          },
                          child: SizedBox(
                              width: double.infinity,
                              child: Image.network(
                                post.getImageURL,
                                fit: BoxFit.fitWidth,
                              )),
                        ));
                      }
                      return ListView(
                        children: listChildren,
                      );
                    } else {
                      List<Widget> listChildren = [];
                      listChildren.add(ProfileCard(
                        profile: profile,
                        isCurrentUser: true,
                        isFollowing: false,
                        followFunction: dummyFunction,
                      ));
                      return ListView(
                        children: listChildren,
                      );
                    }
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
