import 'package:flutter/material.dart';
import 'package:simple_infinite_scroll/simple_infinite_scroll.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SimpleInfiniteScrollController _scrollController =
      SimpleInfiniteScrollController();

  // Get list of articles data
  Future<List<Article>> fetchArticles(int page, int limit) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(10, (index) => Article(title: "Index $index"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Home Screen'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _scrollController.refresh(),
            )
          ],
        ),
        body: SimpleInfiniteScroll<Article>(
          controller: _scrollController,
          fetch: (page, limit) => fetchArticles(page, limit),
          loadingWidget: Center(
            child: Container(
                padding: const EdgeInsets.all(15),
                child: const CircularProgressIndicator()),
          ),
          itemBuilder: (context, index, item) {
            return ListTile(
              title: Text(item.title ?? ''),
            );
          },
        ));
  }
}

class Article {
  int? id;
  String? title, body;

  Article({this.id, this.title, this.body});
}
