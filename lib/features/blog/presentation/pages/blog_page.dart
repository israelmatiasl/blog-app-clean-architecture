import 'package:clean_architecture/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlogPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const BlogPage());
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add_circled),
            onPressed: () {
              Navigator.push(context, AddNewBlogPage.route());
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Blog Page'),
      ),
    );
  }
}
