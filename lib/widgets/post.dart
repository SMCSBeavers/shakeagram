import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shakeagram/models/post_object.dart';
import 'package:shakeagram/models/user_object.dart';

import '../screens/single_post.dart';

class PostWidget extends StatefulWidget {
  const PostWidget(
      {Key? key,
      required this.post,
      required this.title,
      required this.toggleToSinglePost})
      : super(key: key);

  final PostObject post;
  final String title;
  final bool toggleToSinglePost;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: widget.post.getUID)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            UserObject poster =
                UserObject.fromDocument(snapshot.data!.docs.first);
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: Image.network(
                              poster.avatar,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 8, 0, 0),
                              child: Text(
                                poster.getName,
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                              child: Text(widget.post.getLocation,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  )),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: () {
                      // future like and unlike
                      print("Double tap! for like");
                    },
                    onTap: () {
                      if (widget.toggleToSinglePost) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SinglePost(
                                      title: widget.title,
                                      post: widget.post,
                                    ))).then((value) {
                          setState(() {});
                        });
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(
                        widget.post.imageURL,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.getDescription,
                            style: const TextStyle(fontSize: 15.0),
                          ),
                          Text(timeago.format(widget.post.getDate),
                              style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Color.fromARGB(255, 66, 66, 66))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
