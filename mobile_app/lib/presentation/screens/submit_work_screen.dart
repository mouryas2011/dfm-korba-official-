import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/wavy_track_slider.dart';
import '../../core/animations/arrow_launch_button.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_text_field.dart';

class SubmitWorkScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const SubmitWorkScreen({
    Key? key,
    this.taskId = 'TSK_001',
    this.taskTitle = 'Drone Cinematic Sunset Shoot',
  }) : super(key: key);

  @override
  State<SubmitWorkScreen> createState() => _SubmitWorkScreenState();
}

class _SubmitWorkScreenState extends State<SubmitWorkScreen> {
  final _contributionController = TextEditingController();
  String? _selectedFileName;
  int _selectedFileSize = 0;
  String _selectedMimeType = 'video/mp4';
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Pre-populate with realistic file for visual matching
    _selectedFileName = 'drone_shoot.mp4';
    _selectedFileSize = 324 * 1024 * 1024; // 324 MB
  }

  @override
  void dispose() {
    _contributionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'jpg', 'jpeg', 'png', 'pdf', 'docx', 'pptx'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFileName = result.files.first.name;
          _selectedFileSize = result.files.first.size;
          _selectedMimeType = _getMimeType(result.files.first.extension);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File picker notice: $e')),
      );
    }
  }

  String _getMimeType(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.1;
    });

    final auth = context.read<AuthProvider>();
    final taskProv = context.read<TaskProvider>();

    // Mock realistic base64 payload chunk for demonstration
    final mockBase64 = 'AAAAHGZ0eXBtcDQyAAAAAGlzb21tcDQyAAAB';

    final success = await taskProv.uploadSubmission(
      token: auth.sessionToken,
      taskId: widget.taskId,
      fileName: _selectedFileName!,
      mimeType: _selectedMimeType,
      base64Data: mockBase64,
      contributionNotes: _contributionController.text.trim(),
      submitterType: auth.userRole,
    );

    setState(() {
      _isUploading = false;
      _uploadProgress = 1.0;
    });

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskProv.errorMessage ?? 'Upload failed.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Work Submitted!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your submission is now Pending Review by your instructor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Return to Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mbSize = (_selectedFileSize / (1024 * 1024)).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Submit Your Work'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.taskTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Task ID: TSK_001 • Max 100 Marks',
                style: TextStyle(fontSize: 12, color: AppColors.accentCyan),
              ),
              const SizedBox(height: 24),

              // Upload Container (Cloud Icon & Wavy Track Slider)
              NeuCard(
                onTap: _pickFile,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                surfaceColor: AppColors.surfaceDarkElevated,
                border: Border.all(color: AppColors.primaryOrange.withOpacity(0.35)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkInset,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            offset: Offset(2, 3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        color: AppColors.primaryOrange,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Upload Your Work',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Video, Image, PDF, PPT, DOC, Audio (Max 500 MB)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),

                    // Wavy Track Slider Animation
                    WavyTrackSlider(
                      progress: _isUploading ? _uploadProgress : 0.65,
                      label: _isUploading ? 'Uploading to Drive...' : 'Upload Track Active',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Selected File Pill
              if (_selectedFileName != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDarkInset,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.video_file_rounded, color: AppColors.accentCyan, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFileName!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$mbSize MB • Ready',
                              style: const TextStyle(fontSize: 11, color: AppColors.accentTeal),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedFileName = null;
                            _selectedFileSize = 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Member Contribution Description
              const Text(
                'Add Your Contribution',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              NeuTextField(
                controller: _contributionController,
                hintText: 'Describe what you have done in this task...',
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              // Submit CTA with Arrow Launch Animation
              ArrowLaunchButton(
                label: 'Submit Task',
                isLoading: _isUploading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
