import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/overlay_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isOverlayOn = false;
  bool _isLockScreenOn = true;
  String _size = 'M';
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await StorageService.getEnabled();
    final size = await StorageService.getSize();
    final lockScreen = await StorageService.getLockScreen();
    setState(() {
      _isOverlayOn = enabled;
      _size = size;
      _isLockScreenOn = lockScreen;
    });
  }

  Future<void> _toggleOverlay(bool value) async {
    final imagePath = await StorageService.getImagePath();
    if (value && (imagePath == null || imagePath.isEmpty)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select an image first.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (value) {
      bool hasPermission = await OverlayService.checkOverlayPermission();
      if (!hasPermission) {
        await OverlayService.requestOverlayPermission();
        return;
      }
      await StorageService.saveEnabled(true);
      setState(() => _isOverlayOn = true);
      await OverlayService.startOverlay(imagePath!, _size, _isLockScreenOn);
    } else {
      await StorageService.saveEnabled(false);
      setState(() => _isOverlayOn = false);
      await OverlayService.stopOverlay();
    }
  }

  Future<void> _changeSize(String newSize) async {
    setState(() => _size = newSize);
    await StorageService.saveSize(newSize);
    if (_isOverlayOn) {
      await OverlayService.updateSize(newSize);
    }
  }

  Future<void> _toggleLockScreen(bool value) async {
    setState(() => _isLockScreenOn = value);
    await StorageService.saveLockScreen(value);
    if (_isOverlayOn) {
      await OverlayService.updateLockScreen(value);
    }
  }

  Future<void> _resetPosition() async {
    await OverlayService.resetPosition();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Position reset to default.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildToggleCard(theme, 'Floating Image', Icons.layers_rounded, Icons.layers_clear_rounded, _isOverlayOn, _toggleOverlay),
                  const SizedBox(height: 20),
                  _buildToggleCard(theme, 'Lock inside screen', Icons.lock_rounded, Icons.lock_open_rounded, _isLockScreenOn, _toggleLockScreen),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
                    child: Text('Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ),
                  _buildSizeSelector(theme),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _resetPosition,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Reset Position'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard(ThemeData theme, String title, IconData iconOn, IconData iconOff, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: value ? theme.colorScheme.primary.withOpacity(0.2) : Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  value ? iconOn : iconOff,
                  color: value ? theme.colorScheme.primary : Colors.white54,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: theme.colorScheme.primary,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _sizes.map((s) {
          final isSelected = s == _size;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: ChoiceChip(
              label: Text(
                s,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white54,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) _changeSize(s);
              },
              backgroundColor: Colors.transparent,
              selectedColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : Colors.white12,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
