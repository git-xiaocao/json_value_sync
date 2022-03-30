import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON值同步',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? json1;
  int file1Length = 0;
  Map<String, dynamic>? json2;
  int file2Length = 0;

  void sync(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    map1.forEach((key, value) {
      if (null != map2[key]) {
        if (map2[key] is Map) {
          sync(value, map2[key]);
        } else {
          map2[key] = value;
        }
      }
    });
  }

  void textDialog(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
            actions: [
              OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    void readFileToMap(void Function(int length, Map<String, dynamic> data) callback) {
      final fileUpload = FileUploadInputElement();

      fileUpload.onChange.listen((e1) {
        final file = fileUpload.files!.last;
        final reader = FileReader();
        reader.onLoadEnd.listen((e2) {
          try {
            final result = reader.result! as String;
            callback(result.length, jsonDecode(reader.result! as String));
          } catch (e) {
            textDialog(context, 'JSON解析错误');
          }
        });

        reader.readAsText(file);
      });

      fileUpload.click();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON值同步'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    readFileToMap((length, map) {
                      setState(() {
                        file1Length = length;
                        json1 = map;
                      });
                    });
                  },
                  child: const Text('选择文件1'),
                ),
                if (json1 == null) const Text('未选择JSON1') else Text('JSON1已导入 长度:$file1Length')
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    readFileToMap((path, map) {
                      setState(() {
                        file2Length = path;
                        json2 = map;
                      });
                    });
                  },
                  child: const Text('选择文件1'),
                ),
                if (json2 == null) const Text('未选择JSON2') else Text('JSON1已导入 长度:$file2Length')
              ],
            ),
            const SizedBox(height: 5),
            OutlinedButton(
              onPressed: () {
                if (json1 == null) {
                  textDialog(context, 'JSON1未导入');
                  return;
                }
                if (json2 == null) {
                  textDialog(context, 'JSON2未导入');
                  return;
                }
                final newJson = <String, dynamic>{};
                newJson.addAll(json2!);
                sync(json1!, newJson);
                js.context.callMethod("downloadTextFile", ["new-file.json", jsonEncode(newJson)]);
              },
              child: const Text('生成新的JSON'),
            )
          ],
        ),
      ),
    );
  }
}
