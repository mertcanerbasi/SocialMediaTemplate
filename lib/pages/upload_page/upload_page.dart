import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/services/auth.dart';
import 'package:socialmediaapp/services/firestore_service.dart';
import 'package:socialmediaapp/services/storage_service.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _file;
  bool _loading = false;
  TextEditingController _descController = TextEditingController();
  TextEditingController _locController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _file == null ? _loadImageButton() : _postForm(),
    );
  }

  Widget _loadImageButton() {
    return Center(
      child: IconButton(
          iconSize: 50,
          onPressed: () {
            _pickPhoto();
          },
          icon: const Icon(
            Icons.file_upload,
          )),
    );
  }

  Widget _postForm() {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: const Text(
            "Create Post",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              _file == null;
            },
          ),
          actions: [
            IconButton(
              onPressed: _createPost,
              icon: Icon(Icons.send, color: Colors.black),
            ),
          ]),
      body: ListView(
        children: [
          _loading == true ? LinearProgressIndicator() : SizedBox(),
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Image.file(
              _file!,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: "Add Description",
                contentPadding: EdgeInsets.only(left: 15, right: 15),
              )),
          TextFormField(
              controller: _locController,
              decoration: InputDecoration(
                hintText: "Add Location",
                contentPadding: EdgeInsets.only(left: 15, right: 15),
              )),
        ],
      ),
    );
  }

  void _createPost() async {
    if (!_loading) {
      setState(() {
        _loading = true;
      });
      String? imageUrl = await StorageService().uploadImage(_file!);
      String? _activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
      await FireStoreService().createPost(postImageUrl: imageUrl, about: _descController.text, location: _locController.text, publisherId: _activeUserId);
      setState(() {
        _loading = false;
        _descController.clear();
        _locController.clear();
        _file = null;
      });
    }
  }

  _pickPhoto() {
    return showDialog(
        context: context,
        builder: (builder) {
          return SimpleDialog(
            title: const Center(child: Text("Create Post")),
            children: [
              SimpleDialogOption(
                child: const Text('Take photo from Camera'),
                onPressed: () {
                  _fromCamera();
                },
              ),
              SimpleDialogOption(
                child: const Text('Take photo from Gallery'),
                onPressed: () {
                  _fromGallery();
                },
              ),
              SimpleDialogOption(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _fromCamera() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 600, imageQuality: 80);
    setState(() {
      _file = File(image!.path);
    });
  }

  _fromGallery() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 600, imageQuality: 80);
    setState(() {
      try {
        _file = File(image!.path);
      } catch (error) {
        print("error");
      }
    });
  }
}
