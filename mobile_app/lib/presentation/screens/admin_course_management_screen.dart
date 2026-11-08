import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_text_field.dart';

class AdminCourseManagementScreen extends StatefulWidget {
  const AdminCourseManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminCourseManagementScreen> createState() => _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState extends State<AdminCourseManagementScreen> {
  final List<Map<String, dynamic>> _courses = [
    {
      'id': 'CRS_DRONE',
      'code': 'DFM_01',
      'name': 'Drone Film Making',
      'icon': Icons.flight_takeoff_rounded,
      'color': AppColors.accentCyan,
      'duration': '12 Weeks',
      'modules': 6,
      'batches': 4,
      'students': 68,
      'isActive': true,
      'desc': 'Aerial videography, DGCA flight rules, gimbal operation & 4K editing.'
    },
    {
      'id': 'CRS_MOBILE',
      'code': 'MR_02',
      'name': 'Mobile Hardware & Software Repair',
      'icon': Icons.phonelink_setup_rounded,
      'color': const Color(0xFF8F94FB),
      'duration': '8 Weeks',
      'modules': 4,
      'batches': 2,
      'students': 42,
      'isActive': true,
      'desc': 'Micro-soldering, SMD rework, schematic reading & firmware flashing.'
    },
    {
      'id': 'CRS_FRONT_OFFICE',
      'code': 'FOE_03',
      'name': 'Front Office Executive',
      'icon': Icons.support_agent_rounded,
      'color': AppColors.accentTeal,
      'duration': '6 Weeks',
      'modules': 4,
      'batches': 2,
      'students': 35,
      'isActive': true,
      'desc': 'Client communications, CRM management, hospitality etiquette.'
    },
    {
      'id': 'CRS_SOLAR',
      'code': 'STE_04',
      'name': 'Solar Technician & Installation',
      'icon': Icons.solar_power_rounded,
      'color': AppColors.primaryOrange,
      'duration': '10 Weeks',
      'modules': 5,
      'batches': 1,
      'students': 25,
      'isActive': false,
      'desc': 'PV panel wiring, inverter calibration, rooftop mounting & safety.'
    },
  ];

  void _showAddCourseDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final durCtrl = TextEditingController();
    final modCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.add_circle_outline_rounded, color: AppColors.accentCyan),
            SizedBox(width: 8),
            Text('Add Skill Course', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeuTextField(
                controller: nameCtrl,
                label: 'Course Name',
                hintText: 'e.g. Solar Technician',
                prefixIcon: Icons.school_rounded,
              ),
              const SizedBox(height: 12),
              NeuTextField(
                controller: codeCtrl,
                label: 'Course Code',
                hintText: 'e.g. STE_04',
                prefixIcon: Icons.qr_code_rounded,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NeuTextField(
                      controller: durCtrl,
                      label: 'Duration',
                      hintText: 'e.g. 8 Weeks',
                      prefixIcon: Icons.calendar_today_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeuTextField(
                      controller: modCtrl,
                      label: 'Modules',
                      hintText: 'e.g. 5',
                      prefixIcon: Icons.layers_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _courses.add({
                    'id': 'CRS_${DateTime.now().millisecondsSinceEpoch}',
                    'code': codeCtrl.text.trim().isEmpty ? 'NEW_01' : codeCtrl.text.trim(),
                    'name': nameCtrl.text.trim(),
                    'icon': Icons.workspace_premium_rounded,
                    'color': AppColors.accentTeal,
                    'duration': durCtrl.text.trim().isEmpty ? '8 Weeks' : durCtrl.text.trim(),
                    'modules': int.tryParse(modCtrl.text.trim()) ?? 4,
                    'batches': 0,
                    'students': 0,
                    'isActive': true,
                    'desc': 'Newly registered skill development course program.',
                  });
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course added successfully to system.'),
                    backgroundColor: AppColors.accentTeal,
                  ),
                );
              }
            },
            child: const Text('Save Course', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Skill Courses Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryOrange, size: 28),
            onPressed: _showAddCourseDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCourseDialog,
        backgroundColor: AppColors.primaryOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Course', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _courses.length,
          itemBuilder: (ctx, idx) {
            final c = _courses[idx];
            final bool isActive = c['isActive'] as bool;
            final Color color = c['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(c['icon'] as IconData, color: color, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['name'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c['code']} • ${c['duration']} • ${c['modules']} Modules',
                                style: const TextStyle(fontSize: 12, color: AppColors.accentCyan),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isActive,
                          activeColor: AppColors.accentTeal,
                          onChanged: (val) {
                            setState(() {
                              c['isActive'] = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      c['desc'] as String,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkInset,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat('Batches', '${c['batches']}'),
                          Container(width: 1, height: 20, color: AppColors.borderSubtle),
                          _buildMiniStat('Active Students', '${c['students']}'),
                          Container(width: 1, height: 20, color: AppColors.borderSubtle),
                          _buildMiniStat('Fee Policy', '100% Free'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
