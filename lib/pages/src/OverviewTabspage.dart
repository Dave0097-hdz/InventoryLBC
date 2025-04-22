import 'package:flutter/material.dart';
import 'package:inventorylbc/pages/src/AddEquipmentPage.dart';
import 'package:inventorylbc/pages/src/ResulScannerPage.dart';
import '../../components/constants/defautls.dart';
import '../../components/tabs_with_growth.dart';
import '../../components/theme/app_colors.dart';
import 'InventoryPage.dart';
import 'QrPage.dart';

class OverviewTabs extends StatefulWidget {
  const OverviewTabs({super.key});

  @override
  State<OverviewTabs> createState() => _OverviewTabsState();
}

class _OverviewTabsState extends State<OverviewTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.all(Radius.circular(AppDefaults.borderRadius)),
          ),
          child: TabBar(
            controller: _tabController,
            dividerHeight: 0,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: AppDefaults.padding),
            indicator: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(AppDefaults.borderRadius)),
              color: AppColors.bgSecondayLight,
            ),
            tabs: [
              TabWithGrowth(
                title: "Escaner",
                imagePath: "assets/images/escaner.png",
                iconBgColor: AppColors.secondaryBabyBlue,
                page: ScanScreen(),
              ),
              TabWithGrowth(
                title: "Inventario",
                imagePath: "assets/images/inventario.png",
                iconBgColor: AppColors.secondaryLavender,
                page: InventoryPage(),
              ),
              TabWithGrowth(
                title: "Añadir Equipo",
                imagePath: "assets/images/crear.png",
                iconBgColor: AppColors.secondaryMintGreen,
                page: AddEquipment(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
