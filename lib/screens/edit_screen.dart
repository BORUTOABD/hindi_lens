import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditScreen extends StatefulWidget {
  final File? imageFile;
  final String initialMode;

  const EditScreen({
    super.key,
    this.imageFile,
    this.initialMode = 'hi-en',
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _textController;
  late String _mode; // 'hi-en' or 'en-hi'
  bool _isLoading = false;
  String? _errorMessage;
  TranslationResult? _result;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _textController = TextEditingController();

    if (widget.imageFile != null) {
      _runImageOCR();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _runImageOCR() async {
    if (widget.imageFile == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService.translateImage(
      widget.imageFile!,
      direction: _mode,
    );

    setState(() {
      _isLoading = false;
      if (res.error != null) {
        _errorMessage = res.error;
      } else {
        _result = res;
        _textController.text = _mode == 'hi-en' ? res.hindiText : res.englishText;
      }
    });
  }

  Future<void> _handleTranslation() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or scan some text first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService.translateText(
      text: text,
      direction: _mode,
    );

    setState(() {
      _isLoading = false;
      if (res.error != null) {
        _errorMessage = res.error;
      } else {
        _result = res;
        _showResultModal(res);
      }
    });
  }

  void _showResultModal(TranslationResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Translation Result',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _mode == 'hi-en' ? 'Hindi → English' : 'English → Hindi',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                ],
              ),
              const Divider(height: 24),
              Text(
                _mode == 'hi-en' ? 'Source Text (Hindi):' : 'Source Text (English):',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                _mode == 'hi-en' ? result.hindiText : result.englishText,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                _mode == 'hi-en' ? 'Translated Text (English):' : 'Translated Text (Hindi):',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _mode == 'hi-en' ? result.englishText : result.hindiText,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF1A237E)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E74),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Close'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHindiToEnglish = _mode == 'hi-en';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify & Translate'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Direction Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_mode != 'hi-en') {
                            setState(() {
                              _mode = 'hi-en';
                              _errorMessage = null;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isHindiToEnglish ? const Color(0xFFE8EAF6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isHindiToEnglish ? '✓ Hindi → English' : 'Hindi → English',
                            style: TextStyle(
                              fontWeight: isHindiToEnglish ? FontWeight.bold : FontWeight.normal,
                              color: isHindiToEnglish ? const Color(0xFF3F51B5) : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_mode != 'en-hi') {
                            setState(() {
                              _mode = 'en-hi';
                              _errorMessage = null;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isHindiToEnglish ? const Color(0xFFE8EAF6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            !isHindiToEnglish ? '✓ English → Hindi' : 'English → Hindi',
                            style: TextStyle(
                              fontWeight: !isHindiToEnglish ? FontWeight.bold : FontWeight.normal,
                              color: !isHindiToEnglish ? const Color(0xFF3F51B5) : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Image preview
              if (widget.imageFile != null) ...[
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(widget.imageFile!, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),
              ],

              // Error banner
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Text Editing Area
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: isHindiToEnglish
                      ? 'Devanagari OCR Text'
                      : 'Type English Text (or upload image)',
                  hintText: isHindiToEnglish
                      ? 'Extracted Hindi text will appear here...'
                      : 'Type English sentence to translate...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  if (widget.imageFile != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _runImageOCR,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Retry OCR'),
                      ),
                    ),
                  if (widget.imageFile != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_mode == 'en-hi') {
                                _handleTranslation();
                              } else if (_result != null) {
                                _showResultModal(_result!);
                              } else {
                                _runImageOCR();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4E74),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.translate),
                      label: Text(
                        _isLoading
                            ? 'Translating...'
                            : (_mode == 'en-hi' ? 'Translate Text' : 'View Result'),
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