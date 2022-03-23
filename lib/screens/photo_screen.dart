import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  final quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  bool imageToggle = false;
  late File _imageFile;

  Location location = Location();
  late LocationData _locationData;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  // recommended usage of permissions for location
  void checkLocationPermissionsAndObtainLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
  }

  void getImage() async {
    // gets an image from the gallery
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      _imageFile = File(pickedFile!.path);
      setState(() {
        imageToggle = true;
      });
    } catch (e) {
      setState(() {
        print(e);
      });
    }
  }

  Future<String> uploadImage(File imageFile) async {
    // return a string URL
    String imageURL = '';
    try {
      // get current timestamp in milliseconds
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      // turn timestamp into string
      String cloudStorageName = timestamp.toString();
      firebase_storage.Reference storage = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child(cloudStorageName);
      firebase_storage.UploadTask uploadTask = storage.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref(cloudStorageName)
            .getDownloadURL();
        imageURL = downloadURL;
      });
    } on firebase_core.FirebaseException catch (e) {
      e.code == 'canceled';
    }
    return imageURL;
  }

  void createPost(double quantity, File imageFile) async {
    final String imageURL = await uploadImage(imageFile);
    String locationString;
    // location handling
    if (_permissionGranted == PermissionStatus.granted) {
      locationString = _locationData.latitude.toString() +
          _locationData.longitude.toString();
    } else {
      locationString = '';
    }
    FirebaseFirestore.instance
        .collection('posts')
        .add({
          'comments': [],
          'date': DateTime.now(),
          'location': locationString,
          'description': '',
          'imageURL': imageURL,
          'likers': [],
          'uid': auth.currentUser!.uid,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
    ;
  }

  @override
  void initState() {
    super.initState();
    getImage();
    checkLocationPermissionsAndObtainLocation();
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        centerTitle: true,
      ),
      body: imageToggle
          ? Column(
              children: [
                Expanded(
                  child: ListView(
                      padding: const EdgeInsets.only(top: 10.0),
                      children: [
                        SizedBox(
                          width: 200.0,
                          height: 300.0,
                          child: Image.file(
                            _imageFile,
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 15.0, 10.0, 10.0),
                            child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the quantity';
                                  }
                                  return null;
                                },
                                controller: quantityController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(),
                                style: const TextStyle(fontSize: 25.0),
                                keyboardType: TextInputType.number),
                          ),
                        ),
                      ]),
                ),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.purple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 160, vertical: 50)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createPost(
                            double.parse(quantityController.text), _imageFile);
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.cloud_upload,
                      color: Colors.white,
                      size: 60.0,
                      semanticLabel: 'Upload Post',
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
