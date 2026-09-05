import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  final String initialHindiText;
  final String sourceType;

  const EditScreen({
    super.key,
    required this.initialHindiText,
    required this.sourceType,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController _textController;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialHindiText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitForTranslation() {
    final trimmedText = _textController.text.trim();
    if (trimmedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hindi text cannot be empty. Please verify or re-enter.'),
        ),
      );
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    // Simulated network delay to cloud VM running IndicTrans2
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
      });

      // Distinct English outputs based on source sample
      final englishOutput = (widget.sourceType == 'Camera')
          ? 'Please do not throw garbage here. Maintain cleanliness.'
          : 'This public notice is important for all citizens.';

      _showTranslationModal(trimmedText, englishOutput);
    });
  }

  void _showTranslationModal(String sourceHindi, String targetEnglish) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Translation Result',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Chip(
                  label: Text(widget.sourceType),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Verified Hindi Input:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              sourceHindi,
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(height: 24),
            const Text(
              'English Translation (IndicTrans2):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                targetEnglish,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Extracted Text'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Tesseract OCR output may contain character ambiguities. Inspect and correct the Devanagari text below before running machine translation.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: 'Extracted Hindi Text',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              if (_isTranslating)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  onPressed: _submitForTranslation,
                  icon: const Icon(Icons.translate),
                  label: const Text('Translate to English'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}