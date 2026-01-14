import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../models/models.dart';
import '../../../repositories/teacher_repository.dart';
import '../../../repositories/children_repository.dart';
import '../widgets/admin_drawer.dart';

enum SortOption {
  alphabetical,
  dateJoined,
  childCount,
}

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  List<TeacherModel> _allTeachers = [];
  List<TeacherModel> _filteredTeachers = [];
  Map<String, int> _teacherChildCounts = {};
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  SortOption _selectedSort = SortOption.alphabetical;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterAndSortTeachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teacherRepo = context.read<TeacherRepository>();
      final childrenRepo = context.read<ChildrenRepository>();

      // Fetch Teachers and Children in parallel
      final results = await Future.wait([
        teacherRepo.getAllTeachers(),
        childrenRepo.getAllChildren(),
      ]);

      final teachers = results[0] as List<TeacherModel>;
      final children = results[1] as List<ChildModel>;

      // Calculate child counts per teacher
      final counts = <String, int>{};
      for (var child in children) {
        if (child.teacherId != null) {
          counts[child.teacherId!] = (counts[child.teacherId!] ?? 0) + 1;
        }
      }

      if (mounted) {
        setState(() {
          _allTeachers = teachers;
          _teacherChildCounts = counts;
          _isLoading = false;
        });
        _filterAndSortTeachers();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterAndSortTeachers() {
    final query = _searchController.text.toLowerCase().trim();

    List<TeacherModel> temp = _allTeachers.where((teacher) {
      final nameMatches = teacher.name.toLowerCase().contains(query);
      final emailMatches = teacher.email.toLowerCase().contains(query);
      return nameMatches || emailMatches;
    }).toList();

    temp.sort((a, b) {
      switch (_selectedSort) {
        case SortOption.alphabetical:
          return a.name.compareTo(b.name);
        case SortOption.dateJoined:
          // Sort by creation date (newest first)
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        case SortOption.childCount:
          final countA = _teacherChildCounts[a.id] ?? 0;
          final countB = _teacherChildCounts[b.id] ?? 0;
          return countB.compareTo(countA); // Most children first
      }
    });

    setState(() {
      _filteredTeachers = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المعلمات'),
        centerTitle: true,
      ),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/admin/teachers/add');
          _loadData();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth > 800 ? 800 : double.infinity,
          child: Column(
            children: [
              // Search and Sort Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'بحث عن معلمة...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: PopupMenuButton<SortOption>(
                        initialValue: _selectedSort,
                        icon: const Icon(Icons.sort, color: AppColors.primary),
                        tooltip: 'ترتيب',
                        onSelected: (SortOption result) {
                          setState(() {
                            _selectedSort = result;
                            _filterAndSortTeachers();
                          });
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<SortOption>>[
                          const PopupMenuItem<SortOption>(
                            value: SortOption.alphabetical,
                            child: Text('أبجدي'),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.dateJoined,
                            child: Text('تاريخ الانضمام'),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.childCount,
                            child: Text('عدد الأطفال'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: AppColors.error),
                                const SizedBox(height: 16),
                                Text(_errorMessage!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          )
                        : _filteredTeachers.isEmpty
                            ? const Center(
                                child: Text('لا يوجد معلمات مضافات حالياً'),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  itemCount: _filteredTeachers.length,
                                  itemBuilder: (context, index) {
                                    final teacher = _filteredTeachers[index];
                                    final childCount =
                                        _teacherChildCounts[teacher.id] ?? 0;

                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        leading: const CircleAvatar(
                                          backgroundColor:
                                              AppColors.backgroundSecondary,
                                          radius: 25,
                                          child: Icon(Icons.person,
                                              color: AppColors.primary),
                                        ),
                                        title: Text(
                                          teacher.name.isNotEmpty
                                              ? teacher.name
                                              : 'بدون اسم',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(teacher.specializationText,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            Text(
                                              'عدد الأطفال: $childCount',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                  fontSize: 12),
                                            ),
                                            Text(teacher.email,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                        trailing: PopupMenuButton(
                                          icon: const Icon(Icons.more_vert,
                                              color: AppColors.textSecondary),
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              await context.push(
                                                  '/admin/teachers/edit',
                                                  extra: teacher);
                                              _loadData();
                                            } else if (value == 'delete') {
                                              _confirmDelete(context, teacher);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit,
                                                      size: 18,
                                                      color: AppColors.primary),
                                                  SizedBox(width: 8),
                                                  Text('تعديل'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      size: 18,
                                                      color: AppColors.error),
                                                  SizedBox(width: 8),
                                                  Text('حذف'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المعلمة "${teacher.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context
                    .read<TeacherRepository>()
                    .deleteTeacher(teacher.id, deleteUser: true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف المعلمة بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل الحذف: $e')),
                  );
                }
              }
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
