import 'package:eco_collect/pages/complaints.dart';
import 'package:eco_collect/pages/complaints_home.dart';
import 'package:eco_collect/pages/profile.dart';
import 'package:eco_collect/pages/dashboard.dart';
import 'package:eco_collect/pages/datachart.dart';
import 'package:eco_collect/pages/schedule.dart';
import 'package:eco_collect/pages/trucks.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the NavigationController
    final NavigationController controller = Get.put(NavigationController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          color: const Color(0xFF27AE60), // Set the color here
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60), // Rounded corners
            child: SizedBox(
              height: 64, // Set the height here
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildIcon(controller, Iconsax.clock, 0),
                  buildIcon(controller, Iconsax.truck, 1),
                  buildIcon(controller, Iconsax.chart_214, 2),
                  buildIcon(controller, Iconsax.message_question4, 3),
                  buildIcon(controller, Iconsax.profile_circle, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the icons
  Widget buildIcon(NavigationController controller, IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: controller.selectedIndex.value == index
            ? Colors.white
            : Colors.black.withOpacity(0.4),
      ),
      onPressed: () {
        controller.selectedIndex.value = index; // Update the selectedIndex
      },
    );
  }
}

class NavigationController extends GetxController {
  // Observing the selectedIndex state
  final Rx<int> selectedIndex = 0.obs;

  // List of screens for navigation
  final screens = [
    const Schedule(),
    const Trucks(),
    const DataChart(),
    const ComplaintsHome(),
    Profile(),
  ];
}
