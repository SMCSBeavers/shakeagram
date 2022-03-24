import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shakeagram/models/authentication.dart';
import 'package:shakeagram/models/post_object.dart';
import 'package:shakeagram/models/user_object.dart';
import 'package:shakeagram/screens/photo_screen.dart';
import 'package:shakeagram/screens/profile_page.dart';
import 'package:shakeagram/screens/shake_photo.dart';
import 'package:shakeagram/widgets/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
                icon: const Icon(Icons.person),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                title: widget.title,
                              ))).then((value) {
                    setState(() {});
                  });
                }),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.camera),
          onPressed: () async {
            List<CameraDescription> cameras = await availableCameras();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShakeCameraScreen(
                          cameras: cameras,
                          title: widget.title,
                        ))).then((value) {
              setState(() {});
            });
          },
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: FlutterLogo(
                  size: 50.0,
                ),
              ),
              ListTile(
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                title: widget.title,
                              ))).then((value) {
                    setState(() {});
                  });
                },
              ),
              ListTile(
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                title: widget.title,
                              ))).then((value) {
                    setState(() {});
                  });
                },
              ),
              ListTile(
                title: const Text('Sign Out'),
                onTap: () {
                  context.read<AuthenticationService>().signOut();
                },
              ),
            ],
          ),
        ),
        body: StreamBuilder(
            stream: firestore
                .collection('users')
                .where('uid', isEqualTo: auth.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                UserObject loggedInUser2 =
                    UserObject.fromDocument(snapshot.data!.docs.first);
                return StreamBuilder(
                    stream: firestore
                        .collection('posts')
                        .where('uid', whereIn: loggedInUser2.following)
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              // test model
                              PostObject post = PostObject.fromDocument(
                                  snapshot.data!.docs[index]);
                              return PostWidget(
                                post: post,
                                title: widget.title,
                                toggleToSinglePost: true,
                              );
                            });
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
