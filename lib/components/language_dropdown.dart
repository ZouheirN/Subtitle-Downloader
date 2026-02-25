import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LanguageDropdown extends StatefulWidget {
  final void Function(String)? onLanguageChanged;
  final String initialLanguage;

  const LanguageDropdown({
    super.key,
    required this.onLanguageChanged,
    required this.initialLanguage,
  });

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  late Future<Map<String, dynamic>> dataFuture;

  Future<Map<String, dynamic>> getLanguages() async {
    String data = await rootBundle.loadString('assets/language_list.json');
    final jsonResult = jsonDecode(data);
    return jsonResult;
  }

  @override
  void initState() {
    dataFuture = getLanguages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if (snapshot.hasError) {
              return Text(
                  'Error loading languages: ${snapshot.error.toString()}');
            } else if (snapshot.hasData) {
              return _buildDropdown(snapshot.data as Map<String, dynamic>);
            } else {
              return const Text('No data');
            }
        }
      },
    );
  }

  DropdownButton<String> _buildDropdown(Map<String, dynamic> data) {
    return DropdownButton<String>(
      value: widget.initialLanguage,
      onChanged: (String? newValue) {
        widget.onLanguageChanged!(newValue!);
      },
      items: data.keys.map<DropdownMenuItem<String>>((String key) {
        return DropdownMenuItem<String>(
          value: key,
          child: Text(data[key]),
        );
      }).toList(),
    );
  }
}
