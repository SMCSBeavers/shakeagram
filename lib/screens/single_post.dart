import 'package:flutter/material.dart';
import 'package:shakeagram/models/post_object.dart';
import 'package:shakeagram/widgets/post.dart';

class SinglePost extends StatelessWidget {
  const SinglePost({Key? key, required this.title, required this.post})
      : super(key: key);

  final String title;
  final PostObject post;

  @override
  Widget build(BuildContext context) {
    List<Widget> commentWidgetCreator(PostObject post) {
      List<Widget> tempList = [];
      tempList.add(PostWidget(
        post: post,
        title: title,
        toggleToSinglePost: false,
      ));
      tempList.add(const Align(
        alignment: Alignment.center,
        child: Text(
          'Comments',
          style: TextStyle(fontSize: 18.0),
        ),
      ));
      for (int c = 0; c < post.getComments.length; c++) {
        tempList.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(post.getComments[c]),
        ));
      }
      return tempList;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(children: commentWidgetCreator(post)),
    );
  }
}
