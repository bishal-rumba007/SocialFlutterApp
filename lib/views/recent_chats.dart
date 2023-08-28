import 'package:flutter/material.dart';
import 'package:flutter_app/provider/room_provider.dart';
import 'package:flutter_app/views/chat_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';



class RecentChats extends StatelessWidget {
  const RecentChats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Continue to chat with'),

      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final roomData = ref.watch(roomStream);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: roomData.when(
                data: (data){
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Get.to(() => ChatPage(room: data[index]), transition: Transition.leftToRight);
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(data[index].imageUrl!),
                        ),
                        title: Text(data[index].name!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                        subtitle: Text(data[index].name!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),),
                      );
                    },
                  );
                },
                error: (error, stackTrace) => Center(child: Text("$error")),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ),
    );
  }
}
