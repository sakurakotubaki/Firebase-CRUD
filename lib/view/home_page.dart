import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:products_crud_sample/model/products.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductModel>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FireStore CRUD Sample'),
          backgroundColor: Colors.orangeAccent,
        ),
        // これは、アプリ内で使用されなくなったときに、ストリームの状態とストリームの破棄を自動的に管理するのに役立ちます。
        body: StreamBuilder(
          stream: products.snapshots(),
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
                      subtitle:
                          Text(documentSnapshot['price'].toString()), // 価格
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            // 編集ボタン
                            IconButton(
                                color: Colors.deepOrange[400],
                                icon: const Icon(Icons.edit),
                                onPressed: () => context
                                    .read<ProductModel>()
                                    .createOrUpdate(documentSnapshot)),
                            // 削除ボタン
                            IconButton(
                                color: Colors.red[700],
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    context.read<ProductModel>().deleteProduct(documentSnapshot.id)),
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
          onPressed: () => context.read<ProductModel>().createOrUpdate,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
