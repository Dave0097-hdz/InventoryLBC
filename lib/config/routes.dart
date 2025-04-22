import 'package:get/get.dart';
import '../pages/src/HomePage.dart';
import '../pages/src/ProfilePage.dart';

var pages = [
  GetPage(
    name: "/homepage",
    page: () => HomePage(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/edit-profile",
    page: () =>  EditProfile(),
    transition: Transition.rightToLeft,
  ),
];