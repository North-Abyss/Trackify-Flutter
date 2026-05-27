// lib/services/update_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String repoOwner = "North-Abyss";
  static const String repoName = "Trackify-Flutter";

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checking for updates...')),
      );

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = "v${packageInfo.version}"; 
      // If version is 0.1.0+1, this makes it v0.1.0

      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String latestVersion = data['tag_name']; 
        String releaseUrl = data['html_url'];

        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Very basic comparison (Assuming standard semver tags like v1.0.0)
        if (currentVersion != latestVersion && currentVersion != 'v0.0.0') {
          _showUpdateDialog(context, latestVersion, releaseUrl);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are on the latest version!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to check for updates: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static void _showUpdateDialog(BuildContext context, String version, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Update Available: $version"),
        content: const Text("A new version of Trackify is available on GitHub. Would you like to download it?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Later")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: const Text("Download"),
          ),
        ],
      ),
    );
  }
}