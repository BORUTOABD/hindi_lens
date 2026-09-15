import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  String _selectedDirection = 'hi-en'; // 'hi-en' or 'en-hi'

  Future<void> _pickAndCrop(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    final String title = _selectedDirection == 'hi-en'
        ? 'Crop Hindi Text Area'
        : 'Crop English Text Area';

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: const Color(0xFF4A4E74),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );

    if (cropped != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditScreen(
            imageFile: File(cropped.path),
            initialMode: _selectedDirection,
          ),
        ),
      );
    }
  }

  void _openDirectTextInput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditScreen(
          imageFile: null,
          initialMode: 'en-hi',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHindiToEnglish = _selectedDirection == 'hi-en';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HindiLens',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.translate,
                size: 80,
                color: Color(0xFF4285F4),
              ),
              const SizedBox(height: 20),
              const Text(
                'Translation Mode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your direction before processing',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Direction Toggle directly on Home Screen
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
                          setState(() {
                            _selectedDirection = 'hi-en';
                          });
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
                          setState(() {
                            _selectedDirection = 'en-hi';
                          });
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

              const Spacer(),

              // Take Photo Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _pickAndCrop(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E74),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    isHindiToEnglish ? 'Take Photo (Hindi Image)' : 'Take Photo (English Image)',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Choose from Gallery Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _pickAndCrop(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4A4E74)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.photo_library, color: Color(0xFF4A4E74)),
                  label: Text(
                    isHindiToEnglish ? 'Gallery (Hindi Image)' : 'Gallery (English Image)',
                    style: const TextStyle(color: Color(0xFF4A4E74), fontSize: 15),
                  ),
                ),
              ),

              // Type English directly option (ONLY visible when English -> Hindi is selected)
              if (!isHindiToEnglish) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton.icon(
                    onPressed: _openDirectTextInput,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    icon: const Icon(Icons.keyboard, color: Color(0xFF4A4E74)),
                    label: const Text(
                      'Type English Directly',
                      style: TextStyle(
                        color: Color(0xFF4A4E74),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}