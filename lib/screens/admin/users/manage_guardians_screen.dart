import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../models/models.dart';
import '../../../repositories/guardian_repository.dart';
import '../../../repositories/children_repository.dart';
import '../widgets/admin_drawer.dart';

enum SortOption {
  alphabetical,
  dateJoined,
  childCount,
}

class ManageGuardiansScreen extends StatefulWidget {
  const ManageGuardiansScreen({super.key});

  @override
  State<ManageGuardiansScreen> createState() => _ManageGuardiansScreenState();
}

class _ManageGuardiansScreenState extends State<ManageGuardiansScreen> {
  List<GuardianModel> _allGuardians = [];
  List<GuardianModel> _filteredGuardians = [];
  Map<String, int> _guardianChildCounts = {};
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  SortOption _selectedSort = SortOption.alphabetical;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterAndSortGuardians);
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
      final guardianRepo = context.read<GuardianRepository>();
      final childrenRepo = context.read<ChildrenRepository>();

      // Fetch Guardians and Children in parallel
      final results = await Future.wait([
        guardianRepo.getAllGuardians(),
        childrenRepo.getAllChildren(),
      ]);

      final guardians = results[0] as List<GuardianModel>;
      final children = results[1] as List<ChildModel>;

      // Calculate child counts
      final counts = <String, int>{};
      for (var child in children) {
        counts[child.guardianId] = (counts[child.guardianId] ?? 0) + 1;
      }

      if (mounted) {
        setState(() {
          _allGuardians = guardians;
          _guardianChildCounts = counts;
          _isLoading = false;
        });
        _filterAndSortGuardians();
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

  void _filterAndSortGuardians() {
    final query = _searchController.text.toLowerCase().trim();

    List<GuardianModel> temp = _allGuardians.where((guardian) {
      final nameMatches = guardian.name.toLowerCase().contains(query);
      final emailMatches = guardian.email.toLowerCase().contains(query);
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
          final countA = _guardianChildCounts[a.id] ?? 0;
          final countB = _guardianChildCounts[b.id] ?? 0;
          return countB.compareTo(countA); // Most children first
      }
    });

    setState(() {
      _filteredGuardians = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة أولياء الأمور'),
        centerTitle: true,
      ),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/admin/guardians/add');
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
                          hintText: 'بحث عن ولي أمر...',
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
                            _filterAndSortGuardians();
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
                        : _filteredGuardians.isEmpty
                            ? const Center(
                                child: Text('لا يوجد نتائج مطابقة'),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  itemCount: _filteredGuardians.length,
                                  itemBuilder: (context, index) {
                                    final guardian = _filteredGuardians[index];
                                    final childCount =
                                        _guardianChildCounts[guardian.id] ?? 0;

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
                                          child: Icon(Icons.face_3,
                                              color: AppColors.accent),
                                        ),
                                        title: Text(
                                          guardian.name.isNotEmpty
                                              ? guardian.name
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
                                            Text('الأطفال: $childCount',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                    fontSize: 12)),
                                            Text(
                                                'العلاقة: ${guardian.relationship}',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            Text(guardian.email,
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
                                                  '/admin/guardians/edit',
                                                  extra: guardian);
                                              _loadData();
                                            } else if (value == 'delete') {
                                              _confirmDelete(context, guardian);
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

  void _confirmDelete(BuildContext context, GuardianModel guardian) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ولي الأمر "${guardian.name}"؟'),
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
                    .read<GuardianRepository>()
                    .deleteGuardian(guardian.id, deleteUser: true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف ولي الأمر بنجاح'),
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
