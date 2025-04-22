import 'dart:io';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AvatarController extends GetxController {
  Rx<File?> userImage = Rx<File?>(null);
  RxBool isImageChanged = false.obs;

  void setUserImage(File? image) {
    userImage.value = image;
    isImageChanged.value = true;
  }
}