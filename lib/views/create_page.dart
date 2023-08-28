import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/views/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../provider/auth_provider.dart';
import '../provider/crud_provider.dart';
import '../provider/toggle.dart';

class CreatePage extends StatelessWidget {


  final _form = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final detailController = TextEditingController();

  CreatePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer(
            builder: (context, ref, child) {
              final image = ref.watch(imageProvider);
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _form,
                    child: ListView(
                      children: [
                        const Text('Create Post', style: TextStyle(fontSize: 17),),
                        const SizedBox(height: 25,),
                        TextFormField(
                          controller:titleController,
                          validator: (val){
                            if(val!.isEmpty){
                              return 'please provider title';
                            }else if(val.length > 55){
                              return 'maximum character is 55';

                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              hintText: 'Title'
                          ),
                        ),
                        const SizedBox(height: 15,),
                        TextFormField(
                          validator: (val){
                            if(val!.isEmpty){
                              return 'please provide detail';
                            }
                            return null;
                          },
                          controller: detailController,
                          decoration: const InputDecoration(
                              hintText: 'Detail'
                          ),
                        ),

                        const SizedBox(height: 15,),
                        InkWell(
                          onTap: (){
                            ref.read(imageProvider.notifier).pickImage();
                          },
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            child: image == null ?const Center(child: Text('please select an image')) : Image.file(File(image.path)),
                          ),
                        ),
                        const SizedBox(height: 15,),
                        ElevatedButton(
                            onPressed: () async{
                              _form.currentState!.save();
                              if(_form.currentState!.validate()){

                                if(image ==  null){
                                  Get.defaultDialog(
                                      title: 'image required',
                                      content: const Text('please select an image'),
                                      actions: [
                                        TextButton(onPressed: (){
                                          Navigator.of(context).pop();
                                        }, child: const Text('close'))
                                      ]
                                  );
                                }else{
                                  final response = await ref.read(crudProvider).addPost(
                                      title: titleController.text.trim(),
                                      detail: detailController.text.trim(),
                                      userId: FirebaseAuth.instance.currentUser!.uid,
                                      image: image
                                  );
                                  if(response != 'success'){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            duration: const Duration(milliseconds: 1500),
                                            content: Text(response))
                                    );
                                  }else{
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
                                  }
                                }
                              }
                            }, child: const Text('Post', style: TextStyle(fontSize: 16),)
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        )
    );
  }
}



