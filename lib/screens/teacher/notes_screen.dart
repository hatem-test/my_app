import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotesScreen extends StatefulWidget {
  final String? childId;

  const NotesScreen({super.key, this.childId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _notes = [
    {
      'content': 'أحمد كان نشيطاً جداً اليوم وشارك في جميع الأنشطة',
      'timestamp': 'اليوم، 10:30 ص',
      'sentToMother': true
    },
    {
      'content': 'يحتاج إلى متابعة في القراءة',
      'timestamp': 'أمس، 2:15 م',
      'sentToMother': true
    },
    {
      'content': 'تفاعل ممتاز مع الأطفال الآخرين',
      'timestamp': 'منذ 3 أيام',
      'sentToMother': false
    },
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('الملاحظات'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: _notes.isEmpty
                  ? _buildEmptyState(isSmallScreen)
                  : ListView.builder(
                      padding: EdgeInsets.all(padding),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) =>
                          _buildNoteCard(_notes[index], isSmallScreen),
                    ),
            ),
            _buildAddNoteSection(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notes_rounded,
                size: isSmallScreen ? 50 : 64, color: AppColors.primary),
          ),
          SizedBox(height: isSmallScreen ? 18 : 24),
          Text('لا توجد ملاحظات',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('أضف ملاحظة جديدة للطفل',
              style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.sticky_note_2_rounded,
                      color: AppColors.primary, size: isSmallScreen ? 16 : 20),
                ),
                const Spacer(),
                if (note['sentToMother'])
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: isSmallScreen ? 12 : 14,
                            color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('مُرسلة',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 10 : 12),
            Text(note['content'],
                style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 15,
                    color: AppColors.textPrimary,
                    height: 1.5)),
            SizedBox(height: isSmallScreen ? 10 : 12),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: isSmallScreen ? 12 : 14,
                    color: AppColors.textDisabled),
                const SizedBox(width: 4),
                Text(note['timestamp'],
                    style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: AppColors.textDisabled)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNoteSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
                ),
                child: TextField(
                  controller: _noteController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'اكتب ملاحظة جديدة...',
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  maxLines: null,
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8)
                ]),
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: IconButton(
                onPressed: _addNote,
                icon: Icon(Icons.send_rounded,
                    color: Colors.white, size: isSmallScreen ? 20 : 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNote() {
    if (_noteController.text.trim().isNotEmpty) {
      setState(() {
        _notes.insert(0, {
          'content': _noteController.text.trim(),
          'timestamp': 'الآن',
          'sentToMother': false
        });
        _noteController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تمت إضافة الملاحظة بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
