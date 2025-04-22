import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'constants/defautls.dart';

class TabWithGrowth extends StatelessWidget {
  const TabWithGrowth({
    super.key,
    required this.title,
    required this.imagePath,
    required this.iconBgColor,
    required this.page,
  });

  final String title, imagePath;
  final Color iconBgColor;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding * 0.75,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() {
                  isHovered = true;
                }),
                onExit: (_) => setState(() {
                  isHovered = false;
                }),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue;
                      }
                      return iconBgColor;
                    }),
                  ),
                  onPressed: () {
                    Get.to(() => page);
                  },
                  child: Text('Acceder'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
