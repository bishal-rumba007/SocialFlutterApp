import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;



final crudProvider = Provider((ref) => CrudProvider());
final postStream = StreamProvider((ref) => CrudProvider().getPostData());

class CrudProvider{

  final postDb = FirebaseFirestore.instance.collection('posts');

  Future<String> addPost({required String title, required String detail, required XFile image, required String userId}) async{
    try{
      final imageId = DateTime.now().toString();
      final ref = FirebaseStorage.instance.ref().child('postImage/$imageId');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      await postDb.add({
        'title': title,
        'detail': detail,
        'imageUrl': url,
        'userId': userId,
        'imageId': imageId,
        'like':{
          'likes': 0,
          'usernames': []
        },
        'comments':[]
      });

      return 'Created';
    } on FirebaseException catch(err){
      return '${err.message}';
    }

  }


  Future<String> updatePost({required String title, required String detail, XFile? image, required String postId, String? imageId}) async{
    try{
      if(image == null){
        await postDb.doc(postId).update({
          'title': title,
          'detail': detail
        });
      }else{
        final ref = FirebaseStorage.instance.ref().child('postImage/$imageId');
        await ref.delete();
        final imageId1 = DateTime.now().toString();
        final ref1 = FirebaseStorage.instance.ref().child('postImage/$imageId1');
        await ref1.putFile(File(image.path));
        final url = await ref1.getDownloadURL();
        await postDb.doc(postId).update({
          'title': title,
          'detail': detail,
          'imageUrl': url,
          'imageId': imageId1,
        });

      }

      return 'Success';
    } on FirebaseException catch(err){
      return '${err.message}';
    }
  }



  Future<String> likePost({required int like, required String postId, required List<String> usernames}) async{
    try{
      await postDb.doc(postId).update({
        'like':{
          'likes': like + 1,
          'usernames': usernames
        }
      });
      return 'success';
    } on FirebaseException catch (err){
      return '${err.message}';
    }
  }



  Future<String> unlikePost({required int like, required String postId, required List<String> usernames, required currentUsername}) async{
    try{
      await postDb.doc(postId).update({
        'like':{
          'likes': like != 0 ? like - 1 : like,
          'usernames': usernames.remove(currentUsername),
        }
      });
      return 'success';
    } on FirebaseException catch (err){
      return '${err.message}';
    }
  }


  Future<String> addComment({
    required String postId,
    required List<Comment> comments
  })async{
    try{

      await postDb.doc(postId).update({
        'comments': comments.map((e) => e.toJson()).toList()
      });
      return 'success';

    }on FirebaseException catch (err){
      return '${err.message}';
    }
  }



  Future<String> removePost({ required String postId,
    required String imageId
  })async{
    try{

      final ref = FirebaseStorage.instance.ref().child('postImage/$imageId');
      await ref.delete();
      await postDb.doc(postId).delete();
      return 'success';

    }on FirebaseException catch (err){
      return '${err.message}';
    }


  }



  Stream<List<Post>> getPostData(){
    try{
      final response = postDb.snapshots().map((event) {
        return event.docs.map((e) {
          final json = e.data();
          return   Post(
              like: Like.fromJson(json['like']),
              title: json['title'],
              id: e.id,
              imageUrl: json['imageUrl'],
              comments: (json['comments'] as List).map((e) => Comment.fromJson(e)).toList(),
              detail: json['detail'],
              imageId: json['imageId'],
              userId: json['userId']
          );
        }).toList();
      });

      return response;

    }on FirebaseException catch(err){
      throw '${err.message}';
    }
  }




}