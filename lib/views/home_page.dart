import 'package:flutter_app/provider/auth_provider.dart';
import 'package:flutter_app/provider/crud_provider.dart';
import 'package:flutter_app/provider/toggle.dart';
import 'package:flutter_app/views/auth_page.dart';
import 'package:flutter_app/views/create_page.dart';
import 'package:flutter_app/views/edit_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/views/post_detail_page.dart';
import 'package:flutter_app/views/recent_chats.dart';
import 'package:flutter_app/views/user_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final userData = ref.watch(singleUserStream);
    final usersData = ref.watch(allUserStream);
    final postData = ref.watch(postStream);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    late types.User currentUser;
    final isLiked = ref.watch(iconProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      drawer: Drawer(
        child: userData.when(
          data: (data) {
            currentUser = data;
            return ListView(
              children: [
                DrawerHeader(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(data.imageUrl!),
                            fit: BoxFit.cover)),
                    child: Text(data.firstName!)),
                ListTile(
                  leading: const Icon(Icons.mail),
                  title: Text(data.metadata!['email']),
                ),
                ListTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: const Text('Create Post'),
                  onTap: () {
                    Get.to(CreatePage(), transition: Transition.leftToRight);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Recent Chats'),
                  onTap: () {
                    Get.to(const RecentChats(), transition: Transition.leftToRight);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthPage(),));
                    ref.read(authProvider).userLogout();
                  },
                ),
              ],
            );
          },
          error: (err, stack) => Text('$err'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            height: 120,
            child: usersData.when(
                data: (data) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Get.to(() => UserDetails(user: data[index]), transition: Transition.leftToRight);
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data[index].imageUrl!),
                                maxRadius: 40,
                              ),
                            ),
                            Text(
                              data[index].firstName!,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                error: (err, stack) => Center(
                      child: Text('$err'),
                    ),
                loading: () => Container()),
          ),
          Expanded(
              child: postData.when(
            data: (data) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      height: 420,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data[index].title,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              if (uid == data[index].userId)
                                IconButton(
                                    onPressed: () {
                                      Get.defaultDialog(
                                          title: 'Customize',
                                          content:
                                              const Text('Edit or Remove the post'),
                                          actions: [
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Get.to(EditPage(data[index]),
                                                      transition: Transition
                                                          .leftToRight);
                                                },
                                                icon: const Icon(Icons.edit)),
                                            IconButton(
                                                onPressed: () {
                                                  Get.defaultDialog(
                                                      title: 'Hold On',
                                                      content: const Text(
                                                          'Are you sure you want to remove post'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              ref.read(crudProvider).removePost(
                                                                  postId: data[
                                                                          index]
                                                                      .id,
                                                                  imageId: data[
                                                                          index]
                                                                      .imageId);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .hideCurrentSnackBar();
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(const SnackBar(
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              700),
                                                                      content: Text(
                                                                          'Successfully deleted the post!')));
                                                            },
                                                            child: const Text('Yes')),
                                                        TextButton(
                                                            onPressed: () {
                                                              Get.back();
                                                            },
                                                            child: const Text('No')),
                                                      ]);
                                                },
                                                icon: const Icon(Icons.delete))
                                          ]);
                                    },
                                    icon: const Icon(Icons.more_horiz_outlined)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () => Get.to(PostDetailPage(post: data[index], currentUser: currentUser,)),
                            child: Image.network(
                              data[index].imageUrl,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (uid != data[index].userId)
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          if (data[index]
                                              .like
                                              .usernames
                                              .contains(
                                                  currentUser.firstName)) {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                duration: Duration(milliseconds: 700),
                                                content: Text('you\'ve already like this post'),
                                              ),
                                            );
                                            // ref.read(crudProvider).unlikePost(
                                            //   like: data[index].like.likes,
                                            //   postId: data[index].id,
                                            //   usernames: [...data[index].like.usernames, ""],
                                            //   currentUsername: currentUser.firstName!,
                                            // );
                                          } else {
                                            ref.read(crudProvider).likePost(
                                                like: data[index].like.likes,
                                                postId: data[index].id,
                                                usernames: [
                                                  ...data[index].like.usernames,
                                                  currentUser.firstName!
                                                ],);
                                            ref.read(iconProvider.notifier).state = true;
                                          }
                                        },
                                        icon: Icon(
                                          isLiked == false
                                              ? (CupertinoIcons.heart)
                                              : Icons.favorite,
                                          color: Colors.red,
                                        )),
                                    Text(data[index].like.likes != 0
                                        ? '${data[index].like.likes}'
                                        : ''),

                                  ],
                                ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                data[index].detail,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            error: (err, stack) => Center(
              child: Text('$err'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ))
        ],
      ),
    );
  }
}
