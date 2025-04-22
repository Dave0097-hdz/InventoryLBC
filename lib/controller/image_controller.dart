import 'dart:io';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class EquipmentImageController extends GetxController {
  Rx<File?> equipmentImage = Rx<File?>(null);
  Rx<String?> imageUrl = Rx<String?>(null);

  void setEquipmentImage(File? image) {
    equipmentImage.value = image;
  }

  void setImageUrl(String? url) {
    imageUrl.value = url;
  }

  Future<void> loadEquipmentImage(String photoUrl) async {
    setImageUrl(photoUrl);
  }
}
