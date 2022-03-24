import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shakeagram/models/post_object.dart';
import 'package:shakeagram/models/user_object.dart';
import 'package:shakeagram/screens/single_post.dart';
import 'package:shakeagram/widgets/profile_card.dart';

class OtherProfilePage extends StatefulWidget {
  const OtherProfilePage({Key? key, required this.title, required this.uid})
      : super(key: key);

  final String title;
  final String uid;

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  late bool hasUserFollowed = false;

  Future<void> addFollow() async {
    // add following
    // add followers
    List<String> tempListofFollowers = [];
    String followersdocumentID = '';
    await firestore
        .collection('users')
        .where('uid', isEqualTo: widget.uid)
        .snapshots()
        .first
        .then((value) {
      followersdocumentID = value.docs.first.id;
      for (int r = 0; r < value.docs.first['followers'].length; r++) {
        tempListofFollowers.add(value.docs.first['followers'][r]);
      }
      tempListofFollowers.add(auth.currentUser!.uid);
    });
    firestore.collection('users').doc(followersdocumentID).update(
      {'followers': tempListofFollowers},
    ).then((value) {
      setState(() {
        hasUserFollowed = true;
      });
    });
  }

  Future<void> removeFollow() async {
    // add following
    // add followers
    List<String> tempListofFollowers = [];
    String documentID = '';
    await firestore
        .collection('users')
        .where('uid', isEqualTo: widget.uid)
        .snapshots()
        .first
        .then((value) {
      documentID = value.docs.first.id;
      for (int r = 0; r < value.docs.first['followers'].length; r++) {
        if (value.docs.first['followers'][r] == auth.currentUser!.uid) {
          continue;
        }
        tempListofFollowers.add(value.docs.first['followers'][r]);
      }
    });
    firestore.collection('users').doc(documentID).update(
      {'followers': tempListofFollowers},
    ).then((value) {
      setState(() {
        hasUserFollowed = false;
      });
    });
  }

  void followOrUnfollow() async {
    print("hello");
    await firestore
        .collection('users')
        .where('uid', isEqualTo: widget.uid)
        .snapshots()
        .first
        .then((value) {
      if (value.docs.first['followers'].contains(auth.currentUser!.uid)) {
        removeFollow();
      } else {
        addFollow();
      }
    });
  }

  void getUserLikeStatus() async {
    await firestore
        .collection('users')
        .where('uid', isEqualTo: widget.uid)
        .snapshots()
        .first
        .then((value) {
      if (value.docs.first['followers'].contains(auth.currentUser!.uid)) {
        hasUserFollowed = true;
      } else {
        hasUserFollowed = false;
      }
    });
  }

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
              .where('uid', isEqualTo: widget.uid)
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
                        isCurrentUser: false,
                        isFollowing: hasUserFollowed,
                        followFunction: followOrUnfollow,
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
                      return const Center(child: CircularProgressIndicator());
                    }
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
