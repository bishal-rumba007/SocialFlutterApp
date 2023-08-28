import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/views/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../provider/auth_provider.dart';
import '../provider/toggle.dart';



class AuthPage extends StatefulWidget {

  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final passController = TextEditingController();

  bool isObscure = true;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async => FocusScope.of(context).unfocus(),
      child: Scaffold(
          body: Consumer(
              builder: (context, ref, child) {
                final isLogin = ref.watch(loginProvider);
                final image = ref.watch(imageProvider);
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _form,
                      child: ListView(
                        children: [
                          SizedBox(height: isLogin ? 180 : 80,),
                          const Text('Welcome',
                              style: TextStyle(
                                fontSize: 34,
                                fontFamily: 'Poppins',

                              )
                          ),
                          Text(isLogin == true ? 'Fill up the credential to Sign in' : 'Fill up the credential to Sign Up',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                                fontSize: 14
                            ),
                          ),
                          const SizedBox(height: 30,),
                          if(isLogin == false) TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: nameController,
                            validator: (val){
                              if(val!.isEmpty){
                                return 'please provide username';
                              }else if(val.length > 15){
                                return 'maximum character is 15';

                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFF666666),
                                size: 20,
                              ),
                              fillColor: Color(0xFFF2F3F5),
                              hintStyle: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 14,
                              ),
                              hintText: "Username",
                            ),
                          ),
                          const SizedBox(height: 15,),
                          TextFormField(
                            validator: (val){
                              if(val!.isEmpty){
                                return 'email is required';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            controller: mailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xFF666666),
                                size: 20,
                              ),
                              fillColor: Color(0xFFF2F3F5),
                              hintStyle: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 14,
                              ),
                              hintText: "Email",
                            ),
                          ),
                          const SizedBox(height: 15,),
                          TextFormField(
                            controller: passController,
                            obscureText: isObscure,
                            validator: (val){
                              if(val!.isEmpty){
                                return 'password required';
                              }else if(val.length > 15){
                                return 'maximum character is 15';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF666666),
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                  onPressed: (){
                                    setState(() {
                                      isObscure = !isObscure;
                                    });
                                  },
                                  icon: Icon(
                                    isObscure ? Icons.remove_red_eye : Icons.visibility_off,
                                    color: const Color(0xFF666666),
                                    size: 20,
                                  ),
                              ),
                              fillColor: const Color(0xFFF2F3F5),
                              hintStyle: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14,
                              ),
                              hintText: "Password",
                            ),
                          ),
                          const SizedBox(height: 15,),

                          if(isLogin == false)  InkWell(
                            onTap: (){
                              ref.read(imageProvider.notifier).pickImage();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.white,
                                child: image == null ?const Center(child: Text('please select an image')) : Image.file(File(image.path)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30,),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xfff652a0),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )
                            ),
                              onPressed: () async{
                              final scaffoldMessage = ScaffoldMessenger.of(context);
                              final navigate = Navigator.of(context);
                                _form.currentState!.save();
                                if(_form.currentState!.validate()){
                                  if(isLogin){
                                    final response = await ref.read(authProvider).userLogin(
                                      email: mailController.text.trim(),
                                      password: passController.text.trim(),
                                    );

                                    if(response == 'success'){
                                      navigate.pushReplacement(MaterialPageRoute(builder: (context) => const HomePage(),));
                                      scaffoldMessage.showSnackBar(
                                          SnackBar(duration: const Duration(milliseconds: 1500) , content: Text(response)),
                                      );
                                    }else{
                                      scaffoldMessage.showSnackBar(
                                        SnackBar(duration: const Duration(milliseconds: 1500) , content: Text(response)),
                                      );
                                    }
                                  } else{
                                    if(image == null){
                                      Get.defaultDialog(
                                          titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600,),
                                          title: 'Image required',
                                          content: const Text('Please select an image for your profile!'),
                                          actions: [
                                            TextButton(
                                                onPressed: (){
                                                  navigate.pop();
                                                },
                                                child: const Text('close', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),)
                                            )
                                          ]
                                      );
                                    } else{
                                      final response = await ref.read(authProvider).userSignup(
                                        username: nameController.text.trim(),
                                        email: mailController.text.trim(),
                                        password: passController.text.trim(),
                                        image: image,
                                      );

                                      if(response != 'success'){
                                        scaffoldMessage.showSnackBar(
                                          SnackBar(duration: const Duration(milliseconds: 1500) , content: Text(response)),
                                        );
                                      }else{
                                        scaffoldMessage.showSnackBar(
                                          SnackBar(duration: const Duration(milliseconds: 1500) , content: Text(response)),
                                        );
                                        navigate.pushReplacement(MaterialPageRoute(builder: (context) => const HomePage(),));
                                      }
                                    }
                                  }

                                }

                              },
                              child: Text(
                                isLogin? "Login" : "Submit",
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                ),
                              )
                          ),
                          SizedBox(height: isLogin ? 100 : 30,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(isLogin == true ? 'Don\'t have an account ?' : 'Already Have an account',),
                              TextButton(onPressed: (){
                                ref.read(loginProvider.notifier).toggle();
                              }, child: Text(isLogin == true ? 'Sign Up' : 'Login', style: const TextStyle(color: Color(0xfff652a0)),))
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                );
              }
          )
      ),
    );
  }
}
