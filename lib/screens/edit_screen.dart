import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum TranslationMode { hindiToEnglish, englishToHindi }

class EditScreen extends StatefulWidget {
  final File imageFile;

  const EditScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String _translatedText = '';
  String? _errorMessage;
  TranslationMode _mode = TranslationMode.hindiToEnglish;

  @override
  void initState() {
    super.initState();
    _fetchOcrAndTranslation();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchOcrAndTranslation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.translateImage(widget.imageFile);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.error != null && result.error!.isNotEmpty) {
        _errorMessage = result.error;
      } else if (result.hindiText.isEmpty) {
        _errorMessage = 'No readable text found. Please crop closer to the text.';
      } else {
        _textController.text = result.hindiText;
        _translatedText = result.englishText;
      }
    });

    if (_errorMessage == null && _translatedText.isNotEmpty) {
      _showTranslationModal();
    }
  }

  void _showTranslationModal() {
    final isH2E = _mode == TranslationMode.hindiToEnglish;

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
                  label: Text(isH2E ? 'Hindi → English' : 'English → Hindi'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isH2E ? 'Source Text (Hindi):' : 'Source Text (English):',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(_textController.text, style: const TextStyle(fontSize: 15)),
            const Divider(height: 24),
            Text(
              isH2E ? 'Translated Text (English):' : 'Translated Text (Hindi):',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _translatedText,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isH2E = _mode == TranslationMode.hindiToEnglish;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify & Translate'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<TranslationMode>(
                segments: const [
                  ButtonSegment(
                    value: TranslationMode.hindiToEnglish,
                    label: Text('Hindi → English'),
                  ),
                  ButtonSegment(
                    value: TranslationMode.englishToHindi,
                    label: Text('English → Hindi'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _mode = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              Container(
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: isH2E ? 'Devanagari OCR Text' : 'English OCR Text',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _fetchOcrAndTranslation,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Retry OCR'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _textController.text.trim().isEmpty
                            ? null
                            : _showTranslationModal,
                        icon: const Icon(Icons.translate),
                        label: const Text('View Result'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}