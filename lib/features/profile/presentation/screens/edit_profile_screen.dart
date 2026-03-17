import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  late ProfileGender _gender;
  late DateTime _dateOfBirth;
  late int _avatarColorValue;

  static const _avatarColors = [
    Color(0xFF2F66F3),
    Color(0xFF0F766E),
    Color(0xFFB45309),
    Color(0xFF7C3AED),
    Color(0xFFDC2626),
  ];

  @override
  void initState() {
    super.initState();
    final profile = mockProfileStore.value;
    _nameController = TextEditingController(text: profile.name);
    _weightController = TextEditingController(
      text: profile.weightKg.toStringAsFixed(1),
    );
    _heightController = TextEditingController(
      text: profile.heightCm.toStringAsFixed(0),
    );
    _gender = profile.gender;
    _dateOfBirth = profile.dateOfBirth;
    _avatarColorValue = profile.avatarColorValue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _pickAvatarColor() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Avatar Style',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mock avatar picker until image upload API is ready.',
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _avatarColors.map((color) {
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pop(color.toARGB32()),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: color,
                        child: _avatarColorValue == color.toARGB32()
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _avatarColorValue = selected;
      });
    }
  }

  void _saveProfile() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (_nameController.text.trim().isEmpty ||
        weight == null ||
        height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all profile fields')),
      );
      return;
    }

    mockProfileStore.patch(
      (current) => current.copyWith(
        name: _nameController.text.trim(),
        weightKg: weight,
        heightCm: height,
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        avatarColorValue: _avatarColorValue,
        clearAvatarUrl: true,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mock profile updated')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _nameController.text.trim().isEmpty
        ? 'SC'
        : _nameController.text
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part.substring(0, 1).toUpperCase())
              .join();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(_avatarColorValue),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickAvatarColor,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Change Avatar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'Basic Info',
              child: Column(
                children: [
                  _InputField(
                    controller: _nameController,
                    label: 'Name',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InputField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InputField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Gender',
              child: SegmentedButton<ProfileGender>(
                showSelectedIcon: false,
                segments: ProfileGender.values
                    .map(
                      (gender) => ButtonSegment<ProfileGender>(
                        value: gender,
                        label: Text(gender.label),
                      ),
                    )
                    .toList(),
                selected: {_gender},
                onSelectionChanged: (selection) {
                  setState(() {
                    _gender = selection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Date of Birth',
              child: InkWell(
                onTap: _pickDateOfBirth,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM yyyy').format(_dateOfBirth),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _saveProfile,
            child: const Text('Save Profile'),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _InputField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
