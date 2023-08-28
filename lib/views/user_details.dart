import 'package:flutter/material.dart';
import 'package:flutter_app/provider/auth_provider.dart';
import 'package:flutter_app/provider/crud_provider.dart';
import 'package:flutter_app/provider/room_provider.dart';
import 'package:flutter_app/views/chat_page.dart';
import 'package:flutter_app/views/post_detail_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';


class UserDetails extends ConsumerWidget {
  final types.User user;
  const UserDetails({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postStream);
    final userData = ref.watch(singleUserStream);
    late types.User currentUser;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                   CircleAvatar(
                     radius: 45,
                     backgroundImage: NetworkImage(user.imageUrl!),
                   ),
                  const SizedBox(width: 15,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.firstName!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        Text(user.metadata!["email"], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),

                        ElevatedButton(
                          onPressed: () async{
                            final scaffoldMessage = ScaffoldMessenger.of(context);
                            final response = await ref.read(roomProvider).createRoom(user);
                            if(response != null){
                              Get.to(() => ChatPage(room: response), transition:  Transition.leftToRight);

                            }else{
                              scaffoldMessage.showSnackBar(
                                const SnackBar(duration: Duration(milliseconds: 1500) , content: Text("something went wrong")),
                              );
                            }
                          },
                          child: const Text('Start Chat'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Expanded(
                child: posts.when(
                  data: (data) {
                    final userPostData = data.where((element) => element.userId == user.id).toList();
                    return userPostData.isEmpty ? const Center(child: Text("Post not created yet")) : GridView.builder(
                      itemCount: userPostData.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3/4,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemBuilder: (context, index) {
                              return userData.when(
                                data: (singleUserData) {
                                  currentUser = singleUserData;
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(() => PostDetailPage(
                                          post: data[index],
                                          currentUser: currentUser));
                                    },
                                    child: Image.network(
                                        userPostData[index].imageUrl),
                                  );
                                },
                                error: (error, stackTrace) => Text('$error'),
                                loading: () =>
                                    const CircularProgressIndicator(),
                              );
                            },
                    );
                  },
                  error: (err, stack) => Text('$err'),
                  loading: () => const Center(child: CircularProgressIndicator(),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
