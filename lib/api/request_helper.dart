import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../global.dart';

class RequestHelper {
  static String subscriptionKey = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  static Future<http.StreamedResponse> detectObject(String imageUrl) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://centralindia.api.cognitive.microsoft.com/vision/v3.1/detect'));
    request.body = json.encode({'url': imageUrl});
    print(request.body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      decodeJson = await response.stream.bytesToString();
    } else {
      print(response.reasonPhrase);
    }
    return response;
  }

  // analyze image
  static Future<http.StreamedResponse> analyzeImage(String imageUrl) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://centralindia.api.cognitive.microsoft.com/vision/v3.1/analyze?visualFeatures=Categories&language=en'));
    request.body = json.encode({'url': imageUrl});
    print(request.body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      decodeJson = await response.stream.bytesToString();
    } else {
      print(response.reasonPhrase);
    }
    return response;
  }

  // describe image
  static Future<http.StreamedResponse> describeImage(String imageUrl) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://centralindia.api.cognitive.microsoft.com/vision/v3.1/describe?maxCandidates=1'));
    request.body = json.encode({'url': imageUrl});
    print(request.body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      decodeJson = await response.stream.bytesToString();
    } else {
      print(response.reasonPhrase);
    }
    return response;
  }

  //  ocr image
  static Future<http.StreamedResponse> ocrImage(String imageUrl) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://centralindia.api.cognitive.microsoft.com/vision/v3.1/ocr?language=en&detectOrientation=true'));
    request.body = json.encode({'url': imageUrl});
    print(request.body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      decodeJson = await response.stream.bytesToString();
    } else {
      print(response.reasonPhrase);
    }
    return response;
  }

  // tag image
  static Future<http.StreamedResponse> tagImage(String imageUrl) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://centralindia.api.cognitive.microsoft.com/vision/v3.1/tag'));
    request.body = json.encode({'url': imageUrl});
    print(request.body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      decodeJson = await response.stream.bytesToString();
    } else {
      print(response.reasonPhrase);
    }
    return response;
  }

  static Future<String> uploadImageToFirebaseStorage(
      File imageFile, String fileName) async {
    String downloadUrl = "";
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      downloadUrl = await taskSnapshot.ref.getDownloadURL();
    } catch (error) {
      print(error);
    }
    return downloadUrl;
  }

  static Future<void> deleteImageFromFirebaseStorage(String imageUrl) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = await storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (error) {
      print(error);
    }
  }

  static void navigateTo(BuildContext context, Widget page, double offset) {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return page;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(offset, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ));
  }
}
