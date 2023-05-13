import 'package:flutter/material.dart';

class Slidebar extends StatefulWidget {
  const Slidebar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SlidebarState createState() => _SlidebarState();
}

class _SlidebarState extends State<Slidebar> {
  // Define the selected index
  int _selectedIndex = 0;

  // Define the list of options
  List<String> options = const [
    'Analyze Image',
    'Describe Image',
    'Detect Objects',
    'Get Area of Interest',
    'Get Thumbnail',
    'OCR',
    'Read Image',
    'Recognize Entities',
    'Tag Image'
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [],
      ),
    );
  }
}
