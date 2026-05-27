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
      
      // 2. Convert to JSON and Bytes
      String jsonData = jsonEncode(allData);
      final Uint8List fileBytes = Uint8List.fromList(utf8.encode(jsonData));
      
      // 3. Generate Filename
      // This turns "2026-05-27T19:09:12" into "2026-05-27-T-19-09-12"
      String safeDate = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:-]'), '-').replaceFirst('T', '-T-').split('.').first;
      String os = kIsWeb ? 'web' : Platform.operatingSystem;
      String fileName = 'backup-$safeDate-$os.trackify'; // eg: backup-2026-05-27-T-19-09-12-web.trackify

      // 4. Unified Save Logic (Handles both Web and Desktop perfectly in v12)
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Trackify Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['trackify'],
        bytes: fileBytes, // Web uses this automatically to trigger a browser download
      );

      // On Desktop/Mobile, outputFile contains the path, so we write to the hard drive
      if (outputFile != null && !kIsWeb) {
        File file = File(outputFile);
        await file.writeAsString(jsonData);
      }
      
      return true;
    } catch (e) {
      debugPrint("Export Error: $e");
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
          // THE FIX: Safely await readAsBytes() instead of the deprecated .bytes!
          final Uint8List bytes = await result.files.single.readAsBytes();
          jsonData = utf8.decode(bytes);
        } else {
          // THE FIX: Use dart:io File to safely read from the hard drive path
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
          if (value is List) {
            await prefs.setStringList(key, List<String>.from(value));
          }
        }
        return true; 
      }
      return false; 
    } catch (e) {
      debugPrint("Import Error: $e");
      return false;
    }
  }
}