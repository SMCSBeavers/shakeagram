import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:sensors_plus/sensors_plus.dart';

class ShakeCameraScreen extends StatefulWidget {
  const ShakeCameraScreen(
      {Key? key, required this.cameras, required this.title})
      : super(key: key);

  final String title;
  final List<CameraDescription> cameras;

  @override
  _ShakeCameraScreenState createState() => _ShakeCameraScreenState();
}

class _ShakeCameraScreenState extends State<ShakeCameraScreen> {
  // camera controller
  late CameraController cameraController;
  // file I/O
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool imageToggle = false;
  late File _imageFile;
  late StreamSubscription<AccelerometerEvent> motionListener;

  Location location = Location();
  late LocationData _locationData;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  bool includeLocation = false;

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
      final XFile? pickedFile = await cameraController.takePicture();
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

  void createPost(
      String description, bool includeLocation, File imageFile) async {
    final String imageURL = await uploadImage(imageFile);
    String locationString;
    // location handling
    if (_permissionGranted == PermissionStatus.granted && includeLocation) {
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
        .then((value) => print("Post Added"))
        .catchError((error) => print("Failed to add post: $error"));
    ;
  }

  @override
  void initState() {
    super.initState();
    checkLocationPermissionsAndObtainLocation();
    cameraController =
        CameraController(widget.cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    motionListener = accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() > 3.0) {
        getImage();
        motionListener.cancel();
      }
      if ((event.y.abs() - 9.8) > 3.0) {
        getImage();
        motionListener.cancel();
      }
      if (event.z.abs() > 3.0) {
        getImage();
        motionListener.cancel();
      }
    });
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  @override
  void dispose() {
    cameraController.dispose();
    motionListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }
    return imageToggle
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              centerTitle: true,
            ),
            body:
                ListView(padding: const EdgeInsets.only(top: 10.0), children: [
              SizedBox(
                width: double.infinity,
                height: 300.0,
                child: Image.file(
                  _imageFile,
                ),
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _descriptionController,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text("Description")),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Include Location?'),
                          Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: includeLocation,
                            onChanged: (bool? value) {
                              setState(() {
                                includeLocation = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              createPost(_descriptionController.text,
                                  includeLocation, _imageFile);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Post!',
                            style: TextStyle(fontSize: 20.0),
                          ))
                    ],
                  )),
            ]),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              centerTitle: true,
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox.expand(child: CameraPreview(cameraController)),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Shake the device to take a photo!',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              offset: Offset.zero,
                              blurRadius: 10.0)
                        ]),
                  ),
                )
              ],
            ),
          );
  }
}
