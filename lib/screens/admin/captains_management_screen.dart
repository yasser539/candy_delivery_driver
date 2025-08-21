import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/delivery_captain_service.dart';
import '../../models/delivery_captain.dart';

class CaptainsManagementScreen extends StatefulWidget {
  const CaptainsManagementScreen({super.key});

  @override
  State<CaptainsManagementScreen> createState() =>
      _CaptainsManagementScreenState();
}

class _CaptainsManagementScreenState extends State<CaptainsManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterCity = '';
  String _filterStatus = '';
  String _filterPosition = '';
  late DeliveryCaptainService _service;
  StreamSubscription? _subscription;
  List<DeliveryCaptain> _captains = [];

  @override
  void initState() {
    super.initState();
    _service = DeliveryCaptainService();
    _subscription = _service.captainsStream.listen((data) {
      if (mounted) setState(() => _captains = data);
    });
    _service.loadCaptains();
    _service.subscribeToCaptainsChanges();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _service.loadCaptains(
      city: _filterCity.isEmpty ? null : _filterCity,
      status: _filterStatus.isEmpty ? null : _filterStatus,
      position: _filterPosition.isEmpty ? null : _filterPosition,
      query: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DesignSystem.background,
        appBar: AppBar(
          title: const Text('إدارة الكباتن والمناديب'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: DesignSystem.primary,
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildFilters()),
                if (_captains.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.users,
                            color: DesignSystem.textSecondary,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد بيانات متاحة',
                            style: DesignSystem.bodyMedium.copyWith(
                              color: DesignSystem.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCaptainCard(_captains[index]),
                      childCount: _captains.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openCreateOrEdit(),
          icon: const Icon(Icons.person_add),
          label: const Text('إضافة'),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _refresh(),
            decoration: InputDecoration(
              hintText: 'بحث بالاسم/الهاتف/البريد',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: _filterCity,
                  hint: 'المدينة',
                  items: const ['الرياض', 'جدة', 'الدمام'],
                  onChanged: (v) {
                    setState(() => _filterCity = v ?? '');
                    _refresh();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown(
                  value: _filterStatus,
                  hint: 'الحالة',
                  items: const ['نشط', 'إجازة', 'غير نشط'],
                  onChanged: (v) {
                    setState(() => _filterStatus = v ?? '');
                    _refresh();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown(
                  value: _filterPosition,
                  hint: 'الوظيفة',
                  items: const ['كابتن توصيل', 'مندوب'],
                  onChanged: (v) {
                    setState(() => _filterPosition = v ?? '');
                    _refresh();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        hint: Text(hint),
        decoration: const InputDecoration(border: InputBorder.none),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCaptainCard(DeliveryCaptain c) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    c.profileImage != null && c.profileImage!.isNotEmpty
                    ? NetworkImage(c.profileImage!)
                    : null,
                child: (c.profileImage == null || c.profileImage!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: DesignSystem.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(c.position ?? '-', style: DesignSystem.labelSmall),
                        const SizedBox(width: 6),
                        const Text('·'),
                        const SizedBox(width: 6),
                        Text(
                          c.status ?? '-',
                          style: DesignSystem.labelSmall.copyWith(
                            color: DesignSystem.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: DesignSystem.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      (c.rating ?? 0).toStringAsFixed(1),
                      style: DesignSystem.labelSmall.copyWith(
                        color: DesignSystem.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text(c.phone, style: DesignSystem.bodySmall)),
              Expanded(
                child: Text(
                  c.email,
                  style: DesignSystem.bodySmall,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStat('الطلبات', (c.totalDeliveries ?? 0).toString()),
              _buildStat('المهام', (c.tasks ?? 0).toString()),
              _buildStat('منجزة', (c.completed ?? 0).toString()),
              _buildStat('الأداء', (c.performance ?? 0).toString()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openCreateOrEdit(c),
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _confirmDelete(c),
                  icon: const Icon(Icons.delete),
                  label: const Text('حذف'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: DesignSystem.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignSystem.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: DesignSystem.labelSmall.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateOrEdit([DeliveryCaptain? captain]) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CaptainForm(initial: captain),
    );
    if (result != null) {
      if (captain == null) {
        await _service.createCaptain(result);
      } else {
        await _service.updateCaptain(captain.id, result);
      }
      await _refresh();
    }
  }

  void _confirmDelete(DeliveryCaptain captain) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الكابتن'),
        content: Text('هل تريد حذف ${captain.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteCaptain(captain.id);
      await _refresh();
    }
  }
}

class _CaptainForm extends StatefulWidget {
  final DeliveryCaptain? initial;
  const _CaptainForm({this.initial});

  @override
  State<_CaptainForm> createState() => _CaptainFormState();
}

class _CaptainFormState extends State<_CaptainForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _position = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _status = TextEditingController();
  final TextEditingController _vehicleType = TextEditingController();
  final TextEditingController _vehiclePlate = TextEditingController();
  final TextEditingController _profileImage = TextEditingController();

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _name.text = i.name;
      _email.text = i.email;
      _phone.text = i.phone;
      _position.text = i.position ?? '';
      _city.text = i.city ?? '';
      _status.text = i.status ?? '';
      _vehicleType.text = i.vehicleType ?? '';
      _vehiclePlate.text = i.vehiclePlate ?? '';
      _profileImage.text = i.profileImage ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _position.dispose();
    _city.dispose();
    _status.dispose();
    _vehicleType.dispose();
    _vehiclePlate.dispose();
    _profileImage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initial == null
                      ? 'إضافة كابتن/مندوب'
                      : 'تعديل البيانات',
                  style: DesignSystem.titleLarge,
                ),
                const SizedBox(height: 12),
                _tf(_name, 'الاسم', Icons.person, validator: _req),
                const SizedBox(height: 10),
                _tf(_email, 'البريد الإلكتروني', Icons.email, validator: _req),
                const SizedBox(height: 10),
                _tf(_phone, 'الهاتف', Icons.phone, validator: _req),
                const SizedBox(height: 10),
                _tf(_position, 'الوظيفة', Icons.badge),
                const SizedBox(height: 10),
                _tf(_city, 'المدينة', Icons.location_city),
                const SizedBox(height: 10),
                _tf(_status, 'الحالة', Icons.verified_user),
                const SizedBox(height: 10),
                _tf(_vehicleType, 'نوع المركبة', Icons.directions_car),
                const SizedBox(height: 10),
                _tf(_vehiclePlate, 'لوحة المركبة', Icons.confirmation_num),
                const SizedBox(height: 10),
                _tf(_profileImage, 'رابط صورة الملف', Icons.image),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ'),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'حقل مطلوب' : null;

  Widget _tf(
    TextEditingController c,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final payload = <String, dynamic>{
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'position': _position.text.trim().isEmpty ? null : _position.text.trim(),
      'city': _city.text.trim().isEmpty ? null : _city.text.trim(),
      'status': _status.text.trim().isEmpty ? null : _status.text.trim(),
      'vehicle_type': _vehicleType.text.trim().isEmpty
          ? null
          : _vehicleType.text.trim(),
      'vehicle_plate': _vehiclePlate.text.trim().isEmpty
          ? null
          : _vehiclePlate.text.trim(),
      'profile_image': _profileImage.text.trim().isEmpty
          ? null
          : _profileImage.text.trim(),
    };
    Navigator.pop(context, payload);
  }
}
