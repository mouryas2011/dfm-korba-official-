import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_text_field.dart';

class StudentLearningMaterialsScreen extends StatefulWidget {
  const StudentLearningMaterialsScreen({Key? key}) : super(key: key);

  @override
  State<StudentLearningMaterialsScreen> createState() =>
      _StudentLearningMaterialsScreenState();
}

class _StudentLearningMaterialsScreenState
    extends State<StudentLearningMaterialsScreen> {
  final _searchController = TextEditingController();
  String _selectedFormat = 'ALL';

  final List<Map<String, dynamic>> _materials = [
    {
      'material_id': 'MAT_001',
      'title': 'DGCA Civil Aviation Drone Regulations & Indian Airspace',
      'module': 'Module 1: Flight Regulations & Safety',
      'chapter': 'Chapter 1: Green, Yellow & Red Zones',
      'file_format': 'PDF',
      'file_size': '4.2 MB',
      'upload_date': '02 Nov 2026',
      'description':
          'Official guidelines for micro and small drone operations in India, Digital Sky registration, and flight permission protocols.',
      'drive_web_link': 'https://drive.google.com/sample_dgca.pdf',
      'is_bookmarked': true,
    },
    {
      'material_id': 'MAT_002',
      'title': 'Cinematic Flight Moves: Reveal, Orbit, and Parallax',
      'module': 'Module 2: Aerial Cinematography Techniques',
      'chapter': 'Chapter 2: Master Camera Movement Profiles',
      'file_format': 'VIDEO',
      'file_size': '248 MB',
      'upload_date': '04 Nov 2026',
      'description':
          'HD flight breakdown explaining stick coordination for smooth 360-degree subject tracking and altitude descent reveals.',
      'drive_web_link': 'https://drive.google.com/sample_orbit.mp4',
      'is_bookmarked': false,
    },
    {
      'material_id': 'MAT_003',
      'title': 'The 180-Degree Rule & ND Filter Selection Guide',
      'module': 'Module 3: Camera Optics & Exposure Control',
      'chapter': 'Chapter 1: Natural Motion Blur & Shutter Speed',
      'file_format': 'PPTX',
      'file_size': '18.5 MB',
      'upload_date': '05 Nov 2026',
      'description':
          'Presentation slides detailing ND4 through ND64 filter usage under midday sun versus golden hour lighting.',
      'drive_web_link': 'https://drive.google.com/sample_optics.pptx',
      'is_bookmarked': true,
    },
    {
      'material_id': 'MAT_004',
      'title': 'Pre-Flight Safety Inspection Standard Operating Procedure',
      'module': 'Module 1: Flight Regulations & Safety',
      'chapter': 'Chapter 2: Pre-Flight Checklist Protocol',
      'file_format': 'DOCX',
      'file_size': '1.8 MB',
      'upload_date': '06 Nov 2026',
      'description':
          'Step-by-step checklist for battery temperature, propeller integrity, IMU calibration, and failsafe RTH altitude configuration.',
      'drive_web_link': 'https://drive.google.com/sample_checklist.docx',
      'is_bookmarked': false,
    },
    {
      'material_id': 'MAT_005',
      'title': 'Color Grading Log Footage in DaVinci Resolve',
      'module': 'Module 4: Post-Production & Sound Design',
      'chapter': 'Chapter 1: D-Log to Rec.709 Color Transform',
      'file_format': 'PDF',
      'file_size': '8.6 MB',
      'upload_date': '07 Nov 2026',
      'description':
          'Guide to color management, contrast curve balancing, LUT application, and chromatic aberration removal.',
      'drive_web_link': 'https://drive.google.com/sample_color.pdf',
      'is_bookmarked': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _materials.filter((m) {
      if (_selectedFormat != 'ALL' && m['file_format'] != _selectedFormat) {
        return false;
      }
      if (query.isNotEmpty) {
        final title = (m['title'] as String).toLowerCase();
        final desc = (m['description'] as String).toLowerCase();
        final mod = (m['module'] as String).toLowerCase();
        return title.contains(query) ||
            desc.contains(query) ||
            mod.contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Learning Materials Hub'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: NeuTextField(
                controller: _searchController,
                hintText: 'Search chapters, modules, topics...',
                prefixIcon: Icons.search_rounded,
                onChanged: (_) => setState(() {}),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: ['ALL', 'PDF', 'VIDEO', 'PPTX', 'DOCX'].map((fmt) {
                  final isSelected = _selectedFormat == fmt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(fmt),
                      selected: isSelected,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.surfaceDarkInset,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      onSelected: (val) {
                        setState(() => _selectedFormat = fmt);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 12),

            // Materials Roster
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No materials found matching your search.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final m = filtered[idx];
                        final fmt = m['file_format'] as String;
                        final isBookmarked = m['is_bookmarked'] == true;

                        return NeuCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFormatBadge(fmt),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['title'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${m['module']} • ${m['chapter']}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.accentCyan,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isBookmarked
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_border_rounded,
                                      color: isBookmarked
                                          ? AppColors.primaryOrange
                                          : AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        m['is_bookmarked'] = !isBookmarked;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                m['description'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${m['file_size']} • Uploaded ${m['upload_date']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.surfaceDarkInset,
                                      side: const BorderSide(
                                          color: AppColors.accentCyan),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                    ),
                                    icon: const Icon(
                                      Icons.download_rounded,
                                      size: 14,
                                      color: AppColors.accentCyan,
                                    ),
                                    label: const Text(
                                      'Access File',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accentCyan,
                                      ),
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Opening ${m['title']} from Google Drive storage...'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatBadge(String format) {
    Color color;
    IconData icon;

    switch (format) {
      case 'PDF':
        color = const Color(0xFFFF3B30);
        icon = Icons.picture_as_pdf_rounded;
        break;
      case 'VIDEO':
        color = AppColors.accentCyan;
        icon = Icons.play_circle_fill_rounded;
        break;
      case 'PPTX':
        color = const Color(0xFFFF9500);
        icon = Icons.slideshow_rounded;
        break;
      case 'DOCX':
        color = const Color(0xFF007AFF);
        icon = Icons.description_rounded;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.insert_drive_file_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

extension FilterExtension<T> on List<T> {
  List<T> filter(bool Function(T element) test) {
    return where(test).toList();
  }
}

