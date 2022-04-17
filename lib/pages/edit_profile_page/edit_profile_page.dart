import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/services/firestore_service.dart';
import 'package:socialmediaapp/services/storage_service.dart';

import '../../models/users.dart';
import '../../services/auth.dart';

class EditProfilePage extends StatefulWidget {
  final AppUsers? profile;

  const EditProfilePage({Key? key, this.profile}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  String? _about;
  File? _pickedPhoto;
  String? _pickedPhotoUrl;
  bool? _loading;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            )),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                var _formState = _formKey.currentState;
                if (_formState!.validate() != null) {
                  _formState.save();

                  if (_pickedPhoto == null) {
                    _pickedPhotoUrl = widget.profile!.fotoUrl;
                  } else {
                    _pickedPhotoUrl = await StorageService().uploadProfileImage(_pickedPhoto!);
                  }
                  String? _activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
                  FireStoreService().updateUser(_activeUserId, _userName, _about, photoUrl: _pickedPhotoUrl);
                  setState(() {
                    _loading = false;
                  });
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.check,
                color: Colors.black,
              )),
        ],
      ),
      body: ListView(
        children: [
          _loading == true ? LinearProgressIndicator() : SizedBox(),
          _profilePhoto(),
          _userInfo(),
        ],
      ),
    );
  }

  _profilePhoto() {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 20),
      child: widget.profile?.fotoUrl != ""
          ? InkWell(
              onTap: () {
                _fromGallery();
              },
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 50,
                  backgroundImage: _pickedPhoto == null
                      ? NetworkImage(
                          widget.profile?.fotoUrl ?? "",
                        )
                      : FileImage(_pickedPhoto!) as ImageProvider,
                ),
              ),
            )
          : InkWell(
              onTap: () {
                _fromGallery();
              },
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/default_user.png"),
                ),
              ),
            ),
    );
  }

  _userInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.profile!.userName,
              decoration: InputDecoration(labelText: "Username"),
              validator: (value) {
                if (value!.isEmpty && value.length < 4) {
                  return "Username must be at least 5 characters";
                }
                return null;
              },
              onSaved: (value) {
                _userName = value;
              },
            ),
            TextFormField(
              initialValue: widget.profile!.about,
              decoration: InputDecoration(labelText: "About"),
              validator: (value) {
                if (value!.isEmpty && value.length > 100) {
                  return "About  can be maximum 100 charactes";
                }
                return null;
              },
              onSaved: (value) {
                _about = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  _fromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 600, imageQuality: 80);
    setState(() {
      try {
        _pickedPhoto = File(image!.path);
      } catch (error) {
        print("error");
      }
    });
  }
}
