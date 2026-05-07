import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper method to show a popup editing box
  void _showEditDialog(BuildContext context, UserProvider userProvider) {
    // These controllers hold the text while the user types
    final nameController = TextEditingController(text: userProvider.name);
    final bioController = TextEditingController(text: userProvider.bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Short Bio'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save the new text and close the dialog
              userProvider.updateProfile(nameController.text, bioController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Watch the provider for updates
    final userProvider = context.watch<UserProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: Padding(
          padding : const EdgeInsets.all(24.0),
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The User Avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.person, size: 60, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(height: 24),
              
              // The Display Name
              Text(
                userProvider.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              
              // The Bio
              Text(
                userProvider.bio,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // The Edit Button
              FilledButton.icon(
                onPressed: () => _showEditDialog(context, userProvider),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ],
          ),
        )
      ),
    );
  }
}