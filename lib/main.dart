import 'package:flutter/material.dart';

import 'screens/add_shipment_screen.dart';
import 'screens/container_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/management_dashboard_screen.dart';
import 'screens/roles_screen.dart';
import 'screens/search_screen.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Placeholder: does not call Firebase.initializeApp until configured.
  await FirebaseService.instance.initialize();
  runApp(const DoorToDoorApp());
}

class DoorToDoorApp extends StatelessWidget {
  const DoorToDoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Door-to-Door Shipping',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ContainerDetailScreen.routeName: (_) => const ContainerDetailScreen(),
        AddShipmentScreen.routeName: (_) => const AddShipmentScreen(),
        ItemDetailScreen.routeName: (_) => const ItemDetailScreen(),
        SearchScreen.routeName: (_) => const SearchScreen(),
        ManagementDashboardScreen.routeName: (_) =>
            const ManagementDashboardScreen(),
        RolesScreen.routeName: (_) => const RolesScreen(),
      },
    );
  }
}
