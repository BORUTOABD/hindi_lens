import 'package:flutter/material.dart';

enum TranslationMode {
  hindiToEnglish,
  englishToHindi,
}

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
  TranslationMode _mode = TranslationMode.hindiToEnglish;

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

  void _switchDirection(TranslationMode newMode) {
    if (_mode == newMode) return;
    setState(() {
      _mode = newMode;
      if (_mode == TranslationMode.englishToHindi) {
        _textController.text = (widget.sourceType == 'Camera')
            ? 'Please do not throw garbage here. Maintain cleanliness.'
            : 'This public notice is important for all citizens.';
      } else {
        _textController.text = widget.initialHindiText;
      }
    });
  }

  void _submitForTranslation() {
    final trimmedText = _textController.text.trim();
    if (trimmedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Input text cannot be empty. Please verify or re-enter.'),
        ),
      );
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
      });

      String outputText;
      if (_mode == TranslationMode.hindiToEnglish) {
        outputText = (widget.sourceType == 'Camera')
            ? 'Please do not throw garbage here. Maintain cleanliness.'
            : 'This public notice is important for all citizens.';
      } else {
        outputText = (widget.sourceType == 'Camera')
            ? 'कृपया यहाँ कूड़ा न फेंकें। स्वच्छता बनाए रखें।'
            : 'यह सार्वजनिक सूचना सभी नागरिकों के लिए महत्वपूर्ण है।';
      }

      _showTranslationModal(trimmedText, outputText);
    });
  }

  void _showTranslationModal(String sourceText, String targetText) {
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
              isH2E ? 'Verified Hindi Input:' : 'Verified English Input:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(sourceText, style: const TextStyle(fontSize: 14)),
            const Divider(height: 24),
            Text(
              isH2E ? 'English Translation (IndicTrans2):' : 'Hindi Translation (IndicTrans2):',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                targetText,
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
    final isH2E = _mode == TranslationMode.hindiToEnglish;

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
              // Segmented Button to switch direction
              SegmentedButton<TranslationMode>(
                segments: const [
                  ButtonSegment(
                    value: TranslationMode.hindiToEnglish,
                    label: Text('Hindi → English'),
                    icon: Icon(Icons.sync_alt),
                  ),
                  ButtonSegment(
                    value: TranslationMode.englishToHindi,
                    label: Text('English → Hindi'),
                    icon: Icon(Icons.sync_alt),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (newSelection) {
                  _switchDirection(newSelection.first);
                },
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    isH2E
                        ? 'Tesseract OCR output may contain character ambiguities. Inspect and correct the Devanagari text before running machine translation.'
                        : 'Inspect and verify extracted English text before running machine translation into Hindi.',
                    style: const TextStyle(fontSize: 12),
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
                    labelText: isH2E ? 'Extracted Hindi Text' : 'Extracted English Text',
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
                  label: Text(isH2E ? 'Translate to English' : 'Translate to Hindi'),
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