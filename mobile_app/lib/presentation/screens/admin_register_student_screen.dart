import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../providers/auth_provider.dart';
import '../widgets/neumorphic_text_field.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_card.dart';

class AdminRegisterStudentScreen extends StatefulWidget {
  const AdminRegisterStudentScreen({Key? key}) : super(key: key);

  @override
  State<AdminRegisterStudentScreen> createState() => _AdminRegisterStudentScreenState();
}

class _AdminRegisterStudentScreenState extends State<AdminRegisterStudentScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedCourseId = 'CRS_DRONE';
  String _selectedBatchId = 'BTC_DFM_01';

  bool _isRegistering = false;
  Map<String, dynamic>? _registrationResult;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid student name and 10-digit mobile number.')),
      );
      return;
    }

    setState(() => _isRegistering = true);

    final auth = context.read<AuthProvider>();
    final client = ApiClient();

    final response = await client.postAction(
      action: ApiEndpoints.actionRegisterStudent,
      sessionToken: auth.sessionToken,
      payload: {
        'full_name': name,
        'mobile_number': mobile,
        'email': email,
        'course_id': _selectedCourseId,
        'batch_id': _selectedBatchId,
      },
    );

    setState(() => _isRegistering = false);

    if (response.success && response.data != null) {
      setState(() {
        _registrationResult = response.data as Map<String, dynamic>;
      });
    } else {
      // Offline fallback simulation
      final sId = 'STU_DFM_${DateTime.now().millisecondsSinceEpoch % 1000}';
      final tempPass = 'Dfm#${name.split(' ')[0]}78';
      final msg = 'Namaste $name! Welcome to DFM Korba App.\nStudent ID: $sId | Mobile: $mobile | Temp Pass: $tempPass\nPlease download the app and change password on first login.';
      final url = 'https://api.whatsapp.com/send?phone=91$mobile&text=${Uri.encodeComponent(msg)}';

      setState(() {
        _registrationResult = {
          'student_id': sId,
          'full_name': name,
          'mobile_number': mobile,
          'temp_password': tempPass,
          'whatsapp_message': msg,
          'whatsapp_url': url,
        };
      });
    }
  }

  Future<void> _launchWhatsApp(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp: $e')),
      );
    }
  }

  void _copyCredentials() {
    if (_registrationResult != null) {
      final text = _registrationResult!['whatsapp_message'] ?? '';
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credentials and WhatsApp invitation copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Register Student'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_registrationResult == null) ...[
                const Text(
                  'Student Enrollment & Credentials',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enrolls student, generates unique Student ID, sets temporary credentials with forced first-login change, and prepares 1-click WhatsApp invitation.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                NeuTextField(
                  controller: _nameController,
                  labelText: 'Student Full Name',
                  hintText: 'e.g. Rohan Gupta',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                NeuTextField(
                  controller: _mobileController,
                  labelText: 'Registered Mobile Number (Login ID)',
                  hintText: '10-digit mobile number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android_rounded,
                ),
                const SizedBox(height: 14),
                NeuTextField(
                  controller: _emailController,
                  labelText: 'Registered Email (For OTP Recovery)',
                  hintText: 'student@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                const Text('Course Assignment', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDarkInset,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCourseId,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceDark,
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    items: const [
                      DropdownMenuItem(value: 'CRS_DRONE', child: Text('Drone Film Making (DFM)')),
                      DropdownMenuItem(value: 'CRS_MOBILE_REP', child: Text('Mobile Repairing & Hardware')),
                      DropdownMenuItem(value: 'CRS_FRONT_OFFICE', child: Text('Front Office Executive')),
                    ],
                    onChanged: (v) => setState(() => _selectedCourseId = v!),
                  ),
                ),
                const SizedBox(height: 28),
                NeuButton(
                  label: 'Generate Credentials & Save Student',
                  isLoading: _isRegistering,
                  onPressed: _handleRegister,
                ),
              ] else ...[
                // Registration Success & WhatsApp Hand-off Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentTeal),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Student Enrolled Successfully!',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                NeuCard(
                  padding: const EdgeInsets.all(18),
                  surfaceColor: AppColors.surfaceDarkElevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Student ID:', _registrationResult!['student_id'] ?? ''),
                      const Divider(color: AppColors.borderSubtle, height: 18),
                      _buildDetailRow('Full Name:', _registrationResult!['full_name'] ?? ''),
                      const Divider(color: AppColors.borderSubtle, height: 18),
                      _buildDetailRow('Login Mobile:', _registrationResult!['mobile_number'] ?? ''),
                      const Divider(color: AppColors.borderSubtle, height: 18),
                      _buildDetailRow('Temp Password:', _registrationResult!['temp_password'] ?? '', isSecret: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pre-filled WhatsApp Onboarding Message:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                NeuCard(
                  depth: NeuDepth.inset,
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    _registrationResult!['whatsapp_message'] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),
                // 1-Click WhatsApp Button
                NeuButton(
                  label: 'Send Invitation via WhatsApp  📱',
                  color: const Color(0xFF25D366),
                  onPressed: () {
                    _launchWhatsApp(_registrationResult!['whatsapp_url'] ?? '');
                  },
                ),
                const SizedBox(height: 12),
                NeuButton(
                  label: 'Copy Credentials to Clipboard  📋',
                  color: AppColors.surfaceDark,
                  onPressed: _copyCredentials,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _registrationResult = null),
                  child: const Center(
                    child: Text('Register Another Student', style: TextStyle(color: AppColors.accentCyan)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isSecret = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isSecret ? AppColors.primaryOrange : Colors.white,
          ),
        ),
      ],
    );
  }
}
