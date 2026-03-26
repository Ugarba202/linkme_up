import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_input.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  int _currentStep = 0; // 0: Username, 1: Profile, 2: Socials
  final TextEditingController _usernameController = TextEditingController(text: 'alexc');
  final TextEditingController _nameController = TextEditingController(text: 'Alex Harrison');
  final TextEditingController _bioController = TextEditingController(text: 'Digital designer and urban explorer. Let’s connect through tech and art.');
  Uint8List? _profileImageBytes;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      context.go('/home');
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.go('/auth');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _prevStep,
        ),
        title: const Text('LinkQR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ProgressHeader(currentStep: _currentStep + 2), // Mockup says Step 2 of 4 for Username
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildUsernameStep(),
                    _buildProfileSetupStep(),
                    _buildConnectSocialsStep(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: _currentStep == 0 
                  ? 'Next' 
                  : _currentStep == 1 
                    ? 'Continue to Final Step' 
                    : 'Generate My QR',
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose your\nusername', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
        const SizedBox(height: 12),
        Text('This will be your permanent link:', style: TextStyle(color: Colors.grey.shade600)),
        const Text('linkqr.app/[username]', style: TextStyle(color: Color(0xFF5B62F4), fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        const Text('USERNAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        CustomInputField(
          controller: _usernameController,
          hintText: 'username',
          prefixIcon: const Icon(Icons.alternate_email, size: 18, color: Color(0xFF5B62F4)),
          suffixIcon: const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ),
        const SizedBox(height: 8),
        const Text('alexc is available!', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        const Text('SUGGESTED FOR YOU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['alexc', 'alexchen', 'ac_design'].map((s) => ChoiceChip(
            label: Text(s),
            selected: _usernameController.text == s,
            onSelected: (val) => setState(() => _usernameController.text = s),
            backgroundColor: Colors.grey.shade100,
            selectedColor: const Color(0xFF5B62F4),
            labelStyle: TextStyle(color: _usernameController.text == s ? Colors.white : Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
            showCheckmark: false,
          )).toList(),
        ),
        const SizedBox(height: 48),
        _PersonalBrandBanner(),
      ],
    );
  }

  Widget _buildProfileSetupStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Create your profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Personalize how others see your digital identity when they scan your code.', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                   CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                    child: _profileImageBytes == null ? Icon(Icons.person_outline, size: 40, color: Colors.grey.shade400) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF5B62F4), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              const Text('ADD PROFILE PICTURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5B62F4))),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text('DISPLAY NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        CustomInputField(controller: _nameController, hintText: 'Your Name'),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('BIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text('${_bioController.text.length}/100', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        CustomInputField(controller: _bioController, hintText: 'Bio', maxLines: 3),
        const SizedBox(height: 40),
        _LivePreviewCard(name: _nameController.text, bio: _bioController.text, imageBytes: _profileImageBytes),
      ],
    );
  }

  Widget _buildConnectSocialsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Connect your\naccounts', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
        const SizedBox(height: 8),
        Text('Add at least one to generate your QR.', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 32),
        ..._buildMockSocialList(),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Custom Link', style: TextStyle(fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF5B62F4)),
          ),
        )
      ],
    );
  }

  List<Widget> _buildMockSocialList() {
    final platforms = [
      {'name': 'Instagram', 'icon': FontAwesomeIcons.instagram, 'color': Colors.pink},
      {'name': 'TikTok', 'icon': FontAwesomeIcons.tiktok, 'color': Colors.black},
      {'name': 'Twitter / X', 'icon': FontAwesomeIcons.xTwitter, 'color': Colors.black},
      {'name': 'YouTube', 'icon': FontAwesomeIcons.youtube, 'color': Colors.red},
      {'name': 'LinkedIn', 'icon': FontAwesomeIcons.linkedin, 'color': Colors.blue},
      {'name': 'Snapchat', 'icon': FontAwesomeIcons.snapchat, 'color': Colors.yellow.shade700},
    ];

    return platforms.map((p) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Icon(p['icon'] as IconData, color: p['color'] as Color),
        title: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('NOT CONNECTED', style: TextStyle(fontSize: 10, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    )).toList();
  }
}

class _ProgressHeader extends StatelessWidget {
  final int currentStep;
  const _ProgressHeader({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    double progress = currentStep / 4;
    String status = currentStep == 4 ? 'ALMOST THERE' : '${(progress * 100).toInt()}% COMPLETE';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STEP $currentStep OF 4', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5B62F4))),
              Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B62F4)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalBrandBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Personal Brand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text('A unique username makes your QR codes more memorable and professional for your audience.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.qr_code_2, size: 60, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

class _LivePreviewCard extends StatelessWidget {
  final String name;
  final String bio;
  final Uint8List? imageBytes;

  const _LivePreviewCard({required this.name, required this.bio, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text('LIVE PREVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, backgroundColor: Colors.black, letterSpacing: 1))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(bio, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _SmallCircle(color: Colors.pink, size: 8),
                        const SizedBox(width: 4),
                        _SmallCircle(color: Colors.black, size: 8),
                        const SizedBox(width: 4),
                        _SmallCircle(color: Colors.blue, size: 8),
                        const SizedBox(width: 4),
                        _SmallCircle(color: Colors.purple, size: 8),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _SmallCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
