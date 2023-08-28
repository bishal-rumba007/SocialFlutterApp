import 'package:flutter/material.dart';
import 'package:flutter_app/provider/crud_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;



class PostDetailPage extends StatelessWidget {
  final Post post;
  final types.User currentUser;
  const PostDetailPage({super.key, required this.post, required this.currentUser});



  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();
    return GestureDetector(
      onTap: () async => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            final postData = ref.watch(postStream);
            return ListView(
              children: [
                Image.network(post.imageUrl, height: 300, width: double.infinity, fit: BoxFit.cover,),
                const SizedBox(height: 15,),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                      const SizedBox(height: 5,),
                      Text(post.detail, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),),

                      const SizedBox(height: 15,),

                      TextFormField(
                        controller: commentController,
                        onFieldSubmitted: (value) {
                          if(value.isEmpty){

                          }else{
                            final newComment = Comment(
                                commentText: commentController.text.trim(),
                                userImage: currentUser.imageUrl!,
                                username: currentUser.firstName!,
                            );
                            ref.read(crudProvider).addComment(postId: post.id, comments: [...post.comments, newComment]);
                          }
                          commentController.clear();
                        },
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                            hintText: 'add a comment'
                        ),
                      ),

                      const SizedBox(height: 15,),
                    postData.when(
                      data: (data) {
                        final current = data.firstWhere((element) => element.id == post.id);
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: current.comments.length,
                          itemBuilder: (context, index) {
                            final comment = current.comments[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(comment.userImage),
                              ),
                              title: Text(comment.username),
                              subtitle: Text(comment.commentText),
                            );
                          },
                        );
                      },
                      error: (error, stackTrace) => Text('$error'),
                      loading: () => const CircularProgressIndicator(),
                    ),
                  ],
                  ),
                ),
              ],
            );
          },
        )
      ),
    );
  }
}
