import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String image_url = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {},
        ),
        title: const Text('Jellyfish Classifier'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: image_url.isNotEmpty
                    ? Image.network(
                        image_url,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text(
                          '이미지를 업로드 해주세요.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
              const Spacer(),
              // Image Upload Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      image_url =
                          'https://plus.unsplash.com/premium_photo-1684993843948-df77d091fbde?q=80&w=1586&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    '이미지 업로드',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Classify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final imageBytes =
                        await http.readBytes(Uri.parse(image_url));
                    final request = http.MultipartRequest('POST',
                        Uri.parse('http://localhost:8000/image_upload'));
                    request.files.add(http.MultipartFile.fromBytes(
                        'file', imageBytes,
                        filename: 'image.jpg'));
                    final response = await request.send();
                    if (response.statusCode == 201) {
                      final jsonData =
                          jsonDecode(await response.stream.bytesToString());
                      final result = jsonData['result'];
                      final type = jsonData['type'];

                      // TODO: Display the result
                      print(result);
                      print(type);
                    } else if (response.statusCode == 422) {
                      print('422 Error');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    '보내기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Bottom Row Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final response = await http.get(
                          Uri.parse('http://localhost:8000/inference_result'),
                        );

                        if (response.statusCode == 200) {
                          final jsonData = jsonDecode(response.body);
                          final result = jsonData['result'];
                          final type = jsonData['type'];

                          // TODO: Display the result
                          print(result);
                          print(type);
                        } else {
                          print('Failed to get result');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        '예측 결과',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final response = await http.get(
                          Uri.parse(
                              'http://localhost:8000/inference_probability'),
                        );

                        if (response.statusCode == 200) {
                          final jsonData = jsonDecode(response.body);
                          final probabilities = jsonData['probabilities'];

                          final class1 = probabilities['class1'];
                          final class2 = probabilities['class2'];
                          final class3 = probabilities['class3'];

                          // TODO: Display the result
                          print(
                              'class1: $class1, class2: $class2, class3: $class3');
                        } else {
                          print('Failed to get result');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        '예측 확률',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
