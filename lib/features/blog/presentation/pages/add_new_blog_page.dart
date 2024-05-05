import 'dart:io';
import 'package:clean_architecture/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:clean_architecture/core/theme/app_palette.dart';
import 'package:clean_architecture/core/utils/pick_image.dart';
import 'package:clean_architecture/core/utils/show_snackbar.dart';
import 'package:clean_architecture/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:clean_architecture/features/blog/presentation/pages/blog_page.dart';
import 'package:clean_architecture/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {

  static route() => MaterialPageRoute(builder: (context) => const AddNewBlogPage());

  const AddNewBlogPage({super.key});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
  File? image;

  void selectImage() async {
    final pickedImage = await pickImage();

    if(pickedImage != null) {
      setState(() { image = pickedImage; });
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  void uploadBlog() {
    if(formKey.currentState!.validate() &&
        selectedTopics.isNotEmpty &&
        image != null) {
      final posterId = (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      context.read<BlogBloc>()
          .add(
          BlogUpload(
              image: image!,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              posterId: posterId,
              topics: selectedTopics
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
            onPressed: () {
              uploadBlog();
            },
          )
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.message);
          }
          else if (state is BlogSuccess) {
            Navigator.pushAndRemoveUntil(
                context,
                BlogPage.route(),
                (route) => false
            );
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      image != null ?
                      GestureDetector(
                        onTap: selectImage,
                        child: SizedBox(
                          width: double.infinity,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(image!, fit: BoxFit.cover)
                          )
                        ),
                      ) :
                      GestureDetector(
                        onTap: selectImage,
                        child: DottedBorder(
                          color: AppPalette.borderColor,
                          dashPattern: const [10, 4],
                          radius: const Radius.circular(10),
                          borderType: BorderType.RRect,
                          strokeCap: StrokeCap.round,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open, size: 40),
                                SizedBox(height: 15,),
                                Text(
                                  'Select your image',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            ),
                          )
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'Technology',
                            'Business',
                            'Programming',
                            'Entertainment'
                          ].map((e) =>
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  if(selectedTopics.contains(e)) {
                                    selectedTopics.remove(e);
                                  }
                                  else {
                                    selectedTopics.add(e);
                                  }
                                  setState(() {});
                                },
                                child: Chip(
                                  label: Text(e),
                                  color: selectedTopics.contains(e) ? const MaterialStatePropertyAll(AppPalette.gradient1) : null,
                                  side: selectedTopics.contains(e) ? null : const BorderSide(
                                    color: AppPalette.borderColor,
                                  ),
                                ),
                              ),
                            )).toList()
                        ),
                      ),
                      const SizedBox(height: 10),
                      BlogEditor(
                        controller: titleController,
                        hintText: 'Blog Title',
                      ),
                      const SizedBox(height: 10),
                      BlogEditor(
                        controller: contentController,
                        hintText: 'Blog Content',
                      )
                    ],
                  ),
                ),
              ),
            );
        },
      )
    );
  }
}
