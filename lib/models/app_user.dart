import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppUser {
  String uid;
  String googleId;
  String email;
  String name;
  List<String> tanks;

  AppUser({this.uid, this.googleId, this.email, this.name, this.tanks});

  factory AppUser.fromDoc(Map<String, dynamic> doc) {
    return AppUser(
      uid: doc['uid'],
      googleId: doc['google_id'],
      email: doc['email'],
      name: doc['name'],
      tanks: doc['tanks'],
    );
  }
  toDoc() {
    return {
      'uid': this.uid,
      'google_id': this.googleId,
      'email': this.email,
      'name': this.name,
      'tanks': this.tanks,
    };
  }
}
