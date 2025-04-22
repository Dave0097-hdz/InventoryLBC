import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String? username;
  final String? email;
  final String? password;
  final String? id;

  UserModel({this.id, required this.username, required this.email, required this.password});

  static UserModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>>snapshot){
    return UserModel(
        username: snapshot['username'],
        email: snapshot['email'],
        password: snapshot['password']
    );
  }

  Map<String, dynamic> toJson(){
    return{
      "username": username,
      "email": email,
      "password": password,
      "id": id,
    };
  }
}