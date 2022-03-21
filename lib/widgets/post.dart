import 'package:flutter/material.dart';
import 'package:shakeagram/models/post_object.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({Key? key, required this.post}) : super(key: key);

  final PostObject post;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(widget.post.getUID),
          Text(widget.post.getLocation),
          SizedBox(
            height: 300.0,
            child: Image.network(
              widget.post.imageURL,
              fit: BoxFit.scaleDown,
            ),
          ),
          Text(widget.post.getDescription),
          Text(widget.post.getDate.toString())
        ],
      ),
    );
  }
}
