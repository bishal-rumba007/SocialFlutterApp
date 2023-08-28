import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


final authStream = StreamProvider.autoDispose((ref) => FirebaseAuth.instance.authStateChanges());
final authProvider = Provider((ref) => AuthProvider());

final singleUserStream = StreamProvider.autoDispose((ref) => AuthProvider().userStream());
final allUserStream = StreamProvider((ref) => AuthProvider().allUserStream());

class AuthProvider{

  final userDb = FirebaseFirestore.instance.collection('users');

  Future<String> userSignup({required String username, required String email, required String password, required XFile image}) async{

    try{
      final imageId = DateTime.now().toString();
      final ref = FirebaseStorage.instance.ref().child(imageId);
      await ref.putFile(File(image.path));

      final url = await ref.getDownloadURL();

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: username,
          id: credential.user!.uid,
          imageUrl: url,
          metadata: {
            'email': email
          }
        ),
      );

      return 'Registration Successful';

    } on FirebaseAuthException catch(err){
      return '${err.message}';
    }
  }


  Future<String> userLogin({required String email, required String password}) async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return 'Login Successful';
    } on FirebaseAuthException catch(err){
      return '${err.message}';
    }

  }

  Future<String> userLogout() async{
    try{
      await FirebaseAuth.instance.signOut();
      return 'success';
    } on FirebaseAuthException catch(err){
      return '${err.message}';
    }

  }


  Stream<types.User> userStream(){
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try{
      final data = userDb.doc(uid).snapshots().map((event) {

        final json = event.data() as Map<String, dynamic>;
        return types.User(
          id: event.id,
          imageUrl: json['imageUrl'],
          firstName: json['firstName'],
          metadata:{
            'email': json['metadata']['email']
          }
        );
      });
      return data;
    } on FirebaseException catch (err){
      throw '${err.message}';
    }
  }

  //fetch users
  Stream<List<types.User>> allUserStream(){
    try{
      final data = FirebaseChatCore.instance.users();
      return data;
    } on FirebaseException catch (err){
      throw '${err.message}';
    }
  }



}