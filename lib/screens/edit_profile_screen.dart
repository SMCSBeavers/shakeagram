import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:shakeagram/models/user_object.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _biography = TextEditingController();
  late String _currentImageURL;

  final ImagePicker _picker = ImagePicker();
  final quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  bool imageToggle = false;
  late File _imageFile;

  void getImage() async {
    // gets an image from the gallery
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
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

  void updateProfile() async {
    String imageURL = _currentImageURL;
    if (imageToggle) {
      imageURL = await uploadImage(_imageFile);
    }
    FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .get()
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(value.docs.first.id)
          .update({
        'avatar': imageURL,
        'bio': _biography.text,
        'name': _name.text,
      }).then((value) => null);
    }).catchError((error) {
      print("Failed to add user: $error");
    });
  }

  void getCurrentValues() async {
    FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .get()
        .then((value) {
      UserObject current = UserObject.fromDocument(value.docs.first);
      _name.text = current.getName;
      _biography.text = current.getBio;
      _currentImageURL = current.getAvatar;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Form(
            key: _formKey,
            child: ListView(
              children: [
                ElevatedButton(
                  onPressed: () {
                    getImage();
                  },
                  child: const Text('Change Avatar'),
                ),
                TextFormField(
                  controller: _name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _biography,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a biography';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      updateProfile();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            )));
  }
}
