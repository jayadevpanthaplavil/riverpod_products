import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_products/Products.dart';
import 'package:http/http.dart';
import 'package:riverpod_products/ProductsJson.dart';

class Apiservice {
  Future<List<Products>?> getProducts() async {
    Response response = await get(Uri.parse("https://dummyjson.com/products"));
    if (response.statusCode == 200) {
      var jsonString = json.decode(response.body.toString());
      var data = ProductsJson.fromJson(jsonString);
      var listProducts = data.products;
      //print(response.statusCode);
      return listProducts;
    } else {
      throw Exception(response.reasonPhrase);
    }
  }
}

final productsProvider = Provider<Apiservice>((ref) => Apiservice());
final productsDataprovider = FutureProvider<List<Products>?>((ref) async {
  return ref.watch(productsProvider).getProducts();
});

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _data = ref.watch(productsDataprovider);
    return Scaffold(
      appBar: AppBar(title: Text("Products"),),
      body: _data.when(
          data: (_data) {
            List<Products>? prolist=_data?.map((e) => e).toList();
            return ListView.builder(
                itemCount: prolist?.length,
                itemBuilder: (BuildContext context, int index) {
                  Products pro = prolist![index];
                  return InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DetailsPage(e:prolist[index])));
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 150,
                                  child: Image.network("${pro.thumbnail}"),
                                ),
                                Text("${pro.title}")
                              ],
                            ),
                            Text("${pro.description}"),
                            // Row(
                            //   children: [
                            //     Text("Status  - "),
                            //     Container(child: us.completed==true ? Icon(Icons.done): Icon(Icons.error)),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
          error: (err, s) => Text(err.toString()),
          loading: () => const Center(
                child: CircularProgressIndicator(),
              )),
    );
  }
}

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key, required this.e}) : super(key: key);
  final Products e;
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details"),),
      body:  Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Image.network("${widget.e.thumbnail}"),
              ),
              Text("${widget.e.description}"),

            ],
          ),
        ),
      ),
    );
  }
}
