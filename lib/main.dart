import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sign/sign_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signature App',
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
  // Comes from signature page or saved locale
  File? _signature;

  _saveSignature() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('signature', _signature!.path).then((res) {
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signature saved!')));
      }
    });
    await _readSignatureFromLocale();
  }

  _pushToSignPage() async {
    //File returns from SignaturePage and redraw page
    var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SignaturePage()));
    if (res != null && res is File) {
      setState(() {
        _signature = res;
      });
    }
  }

  _readSignatureFromLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? signaturePath = prefs.getString('signature');
    if (signaturePath != null) {
      setState(() {
        _signature = File(signaturePath);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _readSignatureFromLocale();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Signature App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Signature Path:\n${_signature?.path}'),
            ),
            if (_signature != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async => await _pushToSignPage(),
                  child: Image.memory(
                    _signature!.readAsBytesSync(),
                    height: size.height * 0.5,
                  ),
                ),
              ),
            if (_signature != null) ElevatedButton(onPressed: () async => await _saveSignature(), child: const Text('Save Signature'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit_sharp),
        onPressed: () async => await _pushToSignPage(),
      ),
    );
  }
}
