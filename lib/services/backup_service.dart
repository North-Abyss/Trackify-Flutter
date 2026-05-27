// lib/services/backup_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static Future<bool> exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Gather all SharedPreferences data
      final Map<String, dynamic> allData = {};
      for (String key in prefs.getKeys()) {
        allData[key] = prefs.get(key);
      }
      
      // 2. Convert to JSON
      String jsonData = jsonEncode(allData);
      
      // 3. Generate Filename (e.g., backup-20260527-23:40:00-linux.trackify)
      String date = DateTime.now().toIso8601String().split('T').first.replaceAll('-', '');
      String time = DateTime.now().toIso8601String().split('T').last.split('.').first;
      String os = kIsWeb ? 'web' : Platform.operatingSystem;
      String fileName = 'backup-$date-$time-$os.trackify';

      // 4. Save Logic
      if (kIsWeb) {
        final bytes = Uint8List.fromList(utf8.encode(jsonData));
        await FilePicker.saveFile(
          dialogTitle: 'Save Trackify Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['trackify'],
          bytes: bytes,
        );
        return true;
      } else {
        String? outputFile = await FilePicker.saveFile(
          dialogTitle: 'Save Trackify Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['trackify'],
        );

        if (outputFile != null) {
          File file = File(outputFile);
          await file.writeAsString(jsonData);
          return true;
        }
      }
      return false; // Cancelled
    } catch (e) {
      // Notify using print for now, can be enhanced to show a SnackBar or dialog in the UI
      print("Export Error: $e");
      return false;
    }
  }

  static Future<bool> importData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['trackify'],
      );

      if (result != null) {
        String jsonData = '';
        
        if (kIsWeb) {
          jsonData = utf8.decode(result.files.single.bytes!);
        } else {
          File file = File(result.files.single.path!);
          jsonData = await file.readAsString();
        }

        Map<String, dynamic> dataMap = jsonDecode(jsonData);
        final prefs = await SharedPreferences.getInstance();
        
        // Wipe current data and inject the backup
        await prefs.clear(); 
        
        for (var entry in dataMap.entries) {
          final key = entry.key;
          final value = entry.value;
          if (value is int) await prefs.setInt(key, value);
          if (value is String) await prefs.setString(key, value);
          if (value is bool) await prefs.setBool(key, value);
          if (value is double) await prefs.setDouble(key, value);
          if (value is List) await prefs.setStringList(key, List<String>.from(value));
        }
        return true; 
      }
      return false; 
    } catch (e) {
      // Notify using print for now, can be enhanced to show a SnackBar & log or dialog in the UI 
      print("Import Error: $e");
      return false;
    }
  }
}