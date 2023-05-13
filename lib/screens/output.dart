import 'dart:convert';

import 'package:azure/brand_colors.dart';
import 'package:flutter/material.dart';

class Output extends StatefulWidget {
  final String responsee;
  final String heading;
  final String imageUrl;
  const Output(
      {super.key,
      required this.responsee,
      required this.heading,
      required this.imageUrl});

  @override
  State<Output> createState() => _OutputState();
}

class _OutputState extends State<Output> {
  @override
  Widget build(BuildContext context) {
    print(widget.responsee);

    final response = jsonDecode(widget.responsee);
    int height = 0;
    int width = 0;
    if (response.toString().contains('metadata')) {
      height = response['metadata']['height'] ?? 0;
      width = response['metadata']['width'] ?? 0;
    }

    print(height);
    return Scaffold(
        backgroundColor: BrandColors.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                widget.heading,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.primaryTextColor),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(child: getWidgetBasedOnHeading()),
            ],
          ),
        ));
  }

// detect object
  ListView detectObject(response, int height, int width) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: response['objects'].length,
      itemBuilder: (BuildContext context, int index) {
        final object = response['objects'][index];
        final rectangle = object['rectangle'];
        int x = rectangle['x'];
        int y = rectangle['y'];
        int w = rectangle['w'];
        int h = rectangle['h'];
        final label = object['object'];
        final confidence = object['confidence'];
        final parent = object['parent'] == null
            ? {'object': '', 'confidence': '0'}
            : object['parent'] as Map<String, dynamic>;
        final parentLabel = parent['object'] ?? '';
        final parentConfidence = parent['confidence'] ?? '0';

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              drawRectangleOverImage(widget.imageUrl,
                  {"height": height, "width": width}, x, y, w, h),
              const SizedBox(
                height: 10,
              ),
              Text(label,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryTextColor)),
              const SizedBox(
                height: 10,
              ),
              Text('Confidence: ${confidence * 100 ~/ 1}%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryColor)),
            ],
          ),
        );
      },
    );
  }

  // describe image
  ListView describeImage(response) {
    print(response);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: (response['description']['captions']).length,
      itemBuilder: (BuildContext context, int index) {
        final caption = response['description']['captions'][index];
        final text = caption['text'];
        final confidence = caption['confidence'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: BrandColors.primaryColor,
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(text,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryTextColor)),
              const SizedBox(
                height: 10,
              ),
              Text('Confidence: ${confidence * 100 ~/ 1}%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryColor)),
            ],
          ),
        );
      },
    );
  }

  // analyze image
  ListView analyzeImage(response) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: response['categories'].length,
      itemBuilder: (BuildContext context, int index) {
        final category = response['categories'][index];
        final text = category['name'];
        final confidence = category['score'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: BrandColors.primaryColor,
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(text,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryTextColor)),
              const SizedBox(
                height: 10,
              ),
              Text('Confidence: ${confidence * 100 ~/ 1}%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryColor)),
            ],
          ),
        );
      },
    );
  }

  // ocr image
  ListView ocrImage(response) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: response['regions'].length,
      itemBuilder: (BuildContext context, int index) {
        final region = response['regions'][index];
        final lines = region['lines'];
        final boundingBox = region['boundingBox'];
        final List<int> box = boundingBoxToList(boundingBox);
        final x = box[0];
        final y = box[1];
        final w = box[2];
        final h = box[3];

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drawRectangleOverImage(
              //     widget.imageUrl, {"height": 1000, "width": 1000}, x, y, w, h),
              // const SizedBox(
              //   height: 10,
              // ),
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: lines.length,
                itemBuilder: (BuildContext context, int index) {
                  final line = lines[index];
                  final words = line['words'];
                  final boundingBox = line['boundingBox'];
                  final List<int> box = boundingBoxToList(boundingBox);
                  final x = box[0];
                  final y = box[1];
                  final w = box[2];
                  final h = box[3];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // drawRectangleOverImage(widget.imageUrl,
                        //     {"height": 1000, "width": 1000}, x, y, w, h),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: words.length,
                          itemBuilder: (BuildContext context, int index) {
                            final word = words[index];
                            final text = word['text'];
                            final boundingBox = word['boundingBox'];
                            final List<int> box =
                                boundingBoxToList(boundingBox);
                            final x = box[0];
                            final y = box[1];
                            final w = box[2];
                            final h = box[3];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // drawRectangleOverImage(
                                  //     widget.imageUrl,
                                  //     {"height": 1000, "width": 1000},
                                  //     x,
                                  //     y,
                                  //     w,
                                  //     h),
                                  // const SizedBox(
                                  //   height: 10,
                                  // ),
                                  Text(text,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: BrandColors.primaryTextColor)),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // tag image
  ListView tagImage(response) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: response['tags'].length,
      itemBuilder: (BuildContext context, int index) {
        final tag = response['tags'][index];
        final text = tag['name'];
        final confidence = tag['confidence'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryTextColor)),
              const SizedBox(
                height: 10,
              ),
              Text('Confidence: ${confidence * 100 ~/ 1}%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryColor)),
            ],
          ),
        );
      },
    );
  }

  Widget drawRectangleOverImage(String imageUrl, Map<String, dynamic> metadata,
      int x, int y, int w, int h) {
    // replace with your own image URL

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final imageWidth = constraints.maxWidth;
        final imageHeight = (metadata['height'] as int) *
            imageWidth ~/
            (metadata['width'] as int);
        final scale = imageWidth / (metadata['width'] as int);

        return Stack(
          children: [
            Container(
              height: imageHeight.toDouble(),
              width: imageWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: BrandColors.primaryColor,
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Image.network(
            //   '$imageUrl?width=$imageWidth',
            //   width: imageWidth,
            //   height: imageHeight.toDouble(),
            //   fit: BoxFit.cover,
            // ),
            Positioned(
              left: x.toDouble() * scale,
              top: y.toDouble() * scale,
              width: w.toDouble() * scale,
              height: h.toDouble() * scale,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getWidgetBasedOnHeading() {
    dynamic response = jsonDecode(widget.responsee);
    if (widget.heading == 'Analyzed Image') {
      return analyzeImage(response);
    } else if (widget.heading == 'OCR') {
      return ocrImage(response);
    } else if (widget.heading == 'Tagged Image') {
      return tagImage(response);
    } else if (widget.heading == 'Described Image') {
      return describeImage(response);
    } else if (widget.heading == 'Detected Objects') {
      final int height = response['metadata']['height'];
      final int width = response['metadata']['width'];
      return detectObject(response, height, width);
    } else {
      return Container();
    }
  }

  List<int> boundingBoxToList(String boundingBox) {
    List<String> parts = boundingBox.split(',');
    return parts.map((part) => int.parse(part)).toList();
  }
}
