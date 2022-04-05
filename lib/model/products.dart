import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductModel extends ChangeNotifier {
  // text fields' controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // FireStoreのドキュメントを取得
  final CollectionReference productss =
      FirebaseFirestore.instance.collection('products');

  get context => "";

  // 追加・編集で使う関数
  Future<void> createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
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
                        await productss.add({"name": name, "price": price});

                        // 追加のスナックバーを表示
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.blueAccent,
                            content: Text(
                              '${name}を追加しました!',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white),
                            )));
                      }
                      // 編集の処理
                      if (action == 'update') {
                        // Update the product
                        await productss
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "price": price});

                        // 編集のスナックバーを表示
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                backgroundColor: Colors.yellowAccent,
                                content: Text(
                                  '商品情報を更新しました!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87),
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
        notifyListeners();
  }

  // 削除処理の関数
  Future<void> deleteProduct(String productId) async {
    await productss.doc(productId).delete();

    // 削除のスナックバーを表示
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          '商品を削除しました!',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        )));
        notifyListeners();
  }

  snapshots() {}
}
