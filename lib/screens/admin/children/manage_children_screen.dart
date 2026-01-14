import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../repositories/children_repository.dart';
import '../../../../models/models.dart';
import '../widgets/admin_drawer.dart';

enum SortOption {
  alphabetical,
  age,
  motherName,
  teacherName,
  dateAdded,
}

class ManageChildrenScreen extends StatefulWidget {
  const ManageChildrenScreen({super.key});

  @override
  State<ManageChildrenScreen> createState() => _ManageChildrenScreenState();
}

class _ManageChildrenScreenState extends State<ManageChildrenScreen> {
  List<Map<String, dynamic>> _allChildrenWithDetails = [];
  List<Map<String, dynamic>> _filteredChildrenWithDetails = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  SortOption _selectedSort = SortOption.alphabetical;

  @override
  void initState() {
    super.initState();
    _loadChildren();
    _searchController.addListener(_filterAndSortChildren);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<ChildrenRepository>();
      final children = await repository
          .getAllChildrenWithDetails(); // Already returns List<Map>

      if (mounted) {
        setState(() {
          _allChildrenWithDetails = children;
          _isLoading = false;
        });
        _filterAndSortChildren();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء جلب البيانات: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterAndSortChildren() {
    final query = _searchController.text.toLowerCase().trim();

    List<Map<String, dynamic>> temp = _allChildrenWithDetails.where((data) {
      final child = data['child'] as ChildModel;
      final guardianName = (data['guardianName'] as String).toLowerCase();
      final teacherName = (data['teacherName'] as String).toLowerCase();
      final childName = child.name.toLowerCase();

      return childName.contains(query) ||
          guardianName.contains(query) ||
          teacherName.contains(query);
    }).toList();

    temp.sort((a, b) {
      final childA = a['child'] as ChildModel;
      final childB = b['child'] as ChildModel;

      switch (_selectedSort) {
        case SortOption.alphabetical:
          return childA.name.compareTo(childB.name);
        case SortOption.age:
          return childA.birthDate.compareTo(childB
              .birthDate); // Youngest (latest birthdate) first or oldest? usually Age means Oldest first so earliest date
        case SortOption.motherName:
          final nameA = (a['guardianName'] as String);
          final nameB = (b['guardianName'] as String);
          return nameA.compareTo(nameB);
        case SortOption.teacherName:
          final nameA = (a['teacherName'] as String);
          final nameB = (b['teacherName'] as String);
          return nameA.compareTo(nameB);
        case SortOption.dateAdded:
          // Assuming models have created_at, if not fallback to now
          final dateA = childA.createdAt ?? DateTime(2000);
          final dateB = childB.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA); // Newest first
      }
    });

    // Determine age sort order (Ascending birthdate = Oldest first)
    // If selectedSort is age, maybe we want oldest first?
    // Usually lists sort Ascending A-Z.
    // For dates, Ascending is Oldest -> Newest.
    // Let's stick to standard compareTo.

    setState(() {
      _filteredChildrenWithDetails = temp;
    });
  }

  Future<void> _deleteChild(ChildModel child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${child.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = context.read<ChildrenRepository>();
        await repository.deleteChild(child.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الحذف بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadChildren();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء الحذف: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأطفال'),
        centerTitle: true,
      ),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/admin/children/add');
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
                          hintText: 'بحث عن طفل، أم، معلمة...',
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
                            _filterAndSortChildren();
                          });
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<SortOption>>[
                          const PopupMenuItem<SortOption>(
                            value: SortOption.alphabetical,
                            child: Text('أبجدي'),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.age,
                            child: Text('العمر'),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.motherName,
                            child: Text('حسب الأم'),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.teacherName,
                            child: Text('حسب المعلمة'),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.dateAdded,
                            child: Text('تاريخ الإضافة'),
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
                                Text(
                                  _errorMessage!,
                                  style:
                                      const TextStyle(color: AppColors.error),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadChildren,
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          )
                        : _filteredChildrenWithDetails.isEmpty
                            ? const Center(
                                child: Text('لا يوجد نتائج مطابقة'),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadChildren,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  itemCount:
                                      _filteredChildrenWithDetails.length,
                                  itemBuilder: (context, index) {
                                    final data =
                                        _filteredChildrenWithDetails[index];
                                    final child = data['child'] as ChildModel;
                                    final guardianName =
                                        data['guardianName'] as String;
                                    final teacherName =
                                        data['teacherName'] as String;
                                    final isBoy = child.gender == Gender.boy;

                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        leading: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: isBoy
                                              ? AppColors.primary
                                                  .withOpacity(0.1)
                                              : AppColors.girl.withOpacity(0.1),
                                          backgroundImage: child.imageUrl !=
                                                      null &&
                                                  child.imageUrl!.isNotEmpty
                                              ? NetworkImage(child.imageUrl!)
                                              : null,
                                          child: child.imageUrl == null ||
                                                  child.imageUrl!.isEmpty
                                              ? ClipOval(
                                                  child: Image.asset(
                                                    child.defaultImagePath,
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: 50,
                                                        height: 50,
                                                        color:
                                                            Colors.transparent,
                                                        child: Icon(
                                                          Icons.child_care,
                                                          color: isBoy
                                                              ? AppColors
                                                                  .primary
                                                              : AppColors.girl,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : null,
                                        ),
                                        title: Text(
                                          child.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.face_3,
                                                    size: 14,
                                                    color: AppColors
                                                        .textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'ولي الأمر: $guardianName',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.person,
                                                    size: 14,
                                                    color: AppColors
                                                        .textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'المعلمة: $teacherName',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.cake,
                                                    size: 14,
                                                    color: AppColors
                                                        .textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'العمر: ${child.ageText}',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: PopupMenuButton(
                                          icon: const Icon(Icons.more_vert,
                                              color: AppColors.textSecondary),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              context.go('/admin/children/edit',
                                                  extra: child.toJson());
                                            } else if (value == 'delete') {
                                              _deleteChild(child);
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
}
