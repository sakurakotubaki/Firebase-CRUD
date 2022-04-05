import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:products_crud_sample/model/products.dart';
import 'package:products_crud_sample/view/home_page.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ProductModel()),
  ], child: const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'FireStore CRUD Sample',
      home: HomePage(),
    );
  }
}
