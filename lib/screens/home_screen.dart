import 'package:flutter/material.dart';
import 'edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToEditScreen(BuildContext context, String source) {
    // Distinct mock samples reflecting typical real-world inputs
    final String mockExtractedHindi = (source == 'Camera')
        ? 'कृपया यहाँ कूड़ा न फेंकें। स्वच्छता बनाए रखें।'
        : 'यह सार्वजनिक सूचना सभी नागरिकों के लिए महत्वपूर्ण है।';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          initialHindiText: mockExtractedHindi,
          sourceType: source,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HindiLens'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Icon(
                  Icons.translate,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Translate Hindi from Images',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Capture or select an image containing Hindi text, crop the relevant area, and translate it into English.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _navigateToEditScreen(context, 'Camera'),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Take a Photo '),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _navigateToEditScreen(context, 'Gallery'),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery '),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}