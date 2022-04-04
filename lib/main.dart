import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text fields' controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // FireStoreのドキュメントを取得
  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');
  // 追加・編集で使う関数
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '商品名'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: '価格',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  // 日本語表示のボタンを三項演算子で選ぶ
                  child: Text(action == 'create' ? '追加' : '更新'),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final double? price =
                        double.tryParse(_priceController.text);
                    // 追加の処理
                    if (name != null && price != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _productss.add({"name": name, "price": price});

                        // 追加のスナックバーを表示
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.blueAccent,
                            content: Text(
                              '${name}を追加しました!',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                            )));
                      }
                      // 編集の処理
                      if (action == 'update') {
                        // Update the product
                        await _productss
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "price": price});

                        // 編集のスナックバーを表示
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.yellowAccent,
                            content: Text(
                              '商品情報を更新しました!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                            )));

                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _priceController.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // 削除処理の関数
  Future<void> _deleteProduct(String productId) async {
    await _productss.doc(productId).delete();

    // 削除のスナックバーを表示
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          '商品を削除しました!',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FireStore CRUD Sample'),
          backgroundColor: Colors.orangeAccent,
        ),
        // StreamBuilderでFirestoreの値をListView.builderに渡す
        body: StreamBuilder(
          stream: _productss.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              // FireStoreの値をリスト形式で表示
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  // Cardウイジェットでドキュメントを表示
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(documentSnapshot['name']), // 商品名
                      subtitle: Text(documentSnapshot['price'].toString()), // 価格
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            // 編集ボタン
                            IconButton(
                              color: Colors.deepOrange[400],
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _createOrUpdate(documentSnapshot)),
                            // 削除ボタン
                            IconButton(
                                color: Colors.red[700],
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _deleteProduct(documentSnapshot.id)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        // 追加ボタン
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black87,
          onPressed: () => _createOrUpdate(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
