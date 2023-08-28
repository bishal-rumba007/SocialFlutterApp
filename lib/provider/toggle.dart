
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final loadingProvider = StateNotifierProvider<LoadingProvider, bool>((ref) => LoadingProvider(false));

class LoadingProvider extends StateNotifier<bool> {
  LoadingProvider(super.state);
  void toggle(){
    state = !state;
  }

}




final loginProvider = StateNotifierProvider<LoginProvider, bool>((ref) => LoginProvider(true));

class LoginProvider extends StateNotifier<bool> {
  LoginProvider(super.state);

  void toggle(){
    state = !state;
  }

}


final imageProvider = StateNotifierProvider.autoDispose<ImageProvider, XFile?>((ref) => ImageProvider(null));

class ImageProvider extends StateNotifier<XFile?>{
  ImageProvider(super.create);

  void pickImage() async{
    final ImagePicker _picker = ImagePicker();
    state = await _picker.pickImage(source: ImageSource.gallery);
  }

}

final iconProvider = StateNotifierProvider((ref) => IconProvider(false));

class IconProvider extends StateNotifier<bool>{
  IconProvider(super.state);


  void changeIcon() async{
    state = !state;
  }
}