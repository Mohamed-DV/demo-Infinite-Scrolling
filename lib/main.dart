import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = ScrollController();
  List<String> ITEMS = [];
  int page = 1;
  bool hasmore = true;
  bool isloding = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetch();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
  }

  Future fetch() async {
    if (isloding) return;
    isloding = true;
    const limit = 15;
    final url =
        Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');
    final reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      final List newitems = json.decode(reponse.body);
      setState(() {
        if (items.length < limit) {
          hasmore = false;
        }
        isloding = false;
        page++;
        items = newitems.map<String>((item) {
          final number = item['id'];
          return 'item$number';
        }).toList();
      });
    }
  }

  List<String> items = ['item0', 'item8', 'item4', 'item2', 'item6', 'item10'];
  Future refresh() async {
    setState(() {
      isloding = false;
      hasmore = true;
      page = 0;
      items.clear();
    });
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("infinity scrolling"),
      ),
      body: items.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                  controller: controller,
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index < items.length) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item),
                      );
                    } else {
                      return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: hasmore
                              ?Center(child: const CircularProgressIndicator())
                              :Text("No more data"),
                              );
                    }
                  }),
            ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
