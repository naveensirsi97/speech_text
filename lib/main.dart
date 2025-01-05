// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:speech_text/db_helper.dart';
// import 'package:speech_text/show_data_seller.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await DatabaseHelper.createDatabase();
//
//   SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Speech to text',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const ProductsListScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: FlutterQuillForm());
  }
}

class FlutterQuillForm extends StatefulWidget {
  const FlutterQuillForm({super.key});

  @override
  _FlutterQuillFormState createState() => _FlutterQuillFormState();
}

class _FlutterQuillFormState extends State<FlutterQuillForm> {
  final quill.QuillController quillController = quill.QuillController.basic();
  final FocusNode editorFocusNode = FocusNode();
  bool isToolBarVisible = true;
  @override
  void initState() {
    editorFocusNode.addListener(() {
      setState(() {
        isToolBarVisible = editorFocusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reply form"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send),
            tooltip: "Send",
          )
        ],
      ),
      body: SafeArea(
        child: Form(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                toolbarHeight: isToolBarVisible ? 50 : 0,
                title:
                    Visibility(visible: isToolBarVisible, child: getToolBar()),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: getTextFields(),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: getEditor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getToolBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: quill.QuillToolbar(
        controller: quillController,
        showUnderLineButton: false,
        showStrikeThrough: false,
        showColorButton: false,
        showBackgroundColorButton: false,
        showListCheck: false,
        showIndent: false,
      ),
    );
  }

  List<Widget> getTextFields() {
    return [
      const Text("From: test@my.org"),
      const SizedBox(height: 8),
      const TextField(
        decoration: InputDecoration(labelText: "To"),
      ),
      const TextField(
        decoration: InputDecoration(labelText: "Cc"),
      ),
      const TextField(
        decoration: InputDecoration(labelText: "Bcc"),
      ),
    ];
  }

  Widget getEditor() {
    return QuillEditor(
      controller: quillController,
      scrollable: true,
      scrollController: ScrollController(),
      focusNode: editorFocusNode,
      padding: const EdgeInsets.all(5),
      autoFocus: true,
      readOnly: false,
      expands: false,
      placeholder: "compose_email",
    );
  }

  @override
  void dispose() {
    super.dispose();
    quillController.dispose();
  }
}
