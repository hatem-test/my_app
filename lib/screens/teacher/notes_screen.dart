import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/models.dart';
import '../../repositories/note_repository.dart';

class NotesScreen extends StatefulWidget {
  final String? childId;

  const NotesScreen({super.key, this.childId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSending = false;
  final Set<String> _readNoteIds = {};

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.id;
    final noteRepo = context.read<NoteRepository>();
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
              child: widget.childId == null
                  ? _buildErrorState(
                      isSmallScreen, 'يجب تحديد طفل لعرض الملاحظات')
                  : StreamBuilder<List<NoteModel>>(
                      stream: noteRepo.watchNotes(widget.childId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return _buildErrorState(
                              isSmallScreen, 'حدث خطأ أثناء جلب الملاحظات');
                        }
                        final notes = snapshot.data ?? [];
                        if (notes.isEmpty) {
                          return _buildEmptyState(isSmallScreen);
                        }
                        return RefreshIndicator(
                          onRefresh: () async {},
                          child: ListView.builder(
                            padding: EdgeInsets.all(padding),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: notes.length,
                            itemBuilder: (context, index) =>
                                _buildNoteCard(notes[index], isSmallScreen, currentUserId),
                          ),
                        );
                      },
                    ),
            ),
            _buildAddNoteSection(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isSmallScreen, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: isSmallScreen ? 48 : 60, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 15 : 17,
                color: AppColors.textPrimary,
              ),
            ),
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

  Widget _buildNoteCard(
      NoteModel note, bool isSmallScreen, String? currentUserId) {
    final isFromTeacher =
        currentUserId != null && note.authorId == currentUserId;
    final statusLabel = isFromTeacher ? 'مرسلة' : 'من ولي الأمر';

    final isRead = _readNoteIds.contains(note.id);
    _readNoteIds.add(note.id);
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2))
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
                      Text(
                        statusLabel,
                        style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 10 : 12),
            Text(note.content,
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
                Text(note.timestampText,
                    style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: AppColors.textDisabled)),
                const SizedBox(width: 12),
                Icon(
                  Icons.check,
                  size: isSmallScreen ? 12 : 14,
                  color: AppColors.textDisabled,
                ),
                if (isRead) ...[
                  const SizedBox(width: 2),
                  Icon(
                    Icons.check,
                    size: isSmallScreen ? 12 : 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'مقروءة',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: AppColors.success,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 4),
                  Text(
                    'تم الإرسال',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
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
                onPressed: _isSending ? null : _addNote,
                icon: _isSending
                    ? SizedBox(
                        width: isSmallScreen ? 18 : 20,
                        height: isSmallScreen ? 18 : 20,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.send_rounded,
                        color: Colors.white, size: isSmallScreen ? 20 : 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty || widget.childId == null) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول لإرسال ملاحظة')),
      );
      return;
    }

    setState(() => _isSending = true);

    final repo = context.read<NoteRepository>();
    final note = NoteModel(
      id: '',
      childId: widget.childId!,
      authorId: userId,
      content: _noteController.text.trim(),
      isSentToParent: true, // المعلمة ترسل لولي الأمر
      createdAt: DateTime.now(),
    );

    try {
      await repo.createNote(note);
      _noteController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إرسال الملاحظة: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
