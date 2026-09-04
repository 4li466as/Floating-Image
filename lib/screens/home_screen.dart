import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'settings_screen.dart';
import '../services/storage_service.dart';
import '../services/overlay_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? _imagePath;
  String _size = 'M';
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final path = await StorageService.getImagePath();
    final size = await StorageService.getSize();

    if (path != null) {
      final file = File(path);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('The selected image is unavailable. Please select another image.'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        await StorageService.saveImagePath('');
        setState(() {
          _imagePath = null;
          _size = size;
        });
        return;
      }
    }

    setState(() {
      _imagePath = path;
      _size = size;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await StorageService.saveImagePath(image.path);
        setState(() {
          _imagePath = image.path;
        });

        bool isEnabled = await StorageService.getEnabled();
        if (isEnabled) {
          await OverlayService.updateImage(image.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('This image format isn\'t supported on this device. Please choose another image.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Floating Image', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, size: 28),
              onPressed: () async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
                _loadData();
              },
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)], // Slate to Deep Indigo
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Image Preview Area
                if (_imagePath == null || _imagePath!.isEmpty)
                  _buildEmptyState()
                else
                  _buildImagePreview(),

                const SizedBox(height: 40),

                // Upload Button
                _buildUploadButton(theme),

                const SizedBox(height: 40),

                // Info Note
                _buildInfoNote(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24, width: 2, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_search_rounded, size: 60, color: Colors.indigo.shade300),
              const SizedBox(height: 16),
              const Text(
                'Select an image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Hero(
          tag: 'image_preview',
          child: Container(
            constraints: const BoxConstraints(maxHeight: 350),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.black26, // Subtle backdrop for transparency
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('This image format isn\'t supported on this device. Please choose another image.', textAlign: TextAlign.center),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_size_select_large, size: 20, color: Colors.white70),
              const SizedBox(width: 10),
              Text(
                'Size: $_size',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _pickImage,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // Padding handled by Ink
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload_file_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Upload Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.indigo.shade200, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Note:\nIf you want a transparent floating\nimage, remove the background yourself\nbefore uploading. This app does\nnot remove or edit backgrounds.',
              style: TextStyle(fontSize: 14, color: Colors.indigo.shade100, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
