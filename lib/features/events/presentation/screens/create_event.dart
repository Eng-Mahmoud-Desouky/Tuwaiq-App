import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';
import '../cubit/create_event_cubit.dart';
import '../cubit/create_event_state.dart';
import '../../domain/entities/event_entity.dart';

class CreateEventScreen extends StatefulWidget {
  final EventEntity? eventToEdit;
  const CreateEventScreen({super.key, this.eventToEdit});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _googleMapsUrlController = TextEditingController();

  String? _selectedCategory;
  String? _selectedRegion;
  String? _selectedCity;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      final ev = widget.eventToEdit!;
      _titleController.text = ev.title;
      _descriptionController.text = ev.description;
      _locationNameController.text = ev.locationName;
      _googleMapsUrlController.text = ev.googleMapsUrl ?? '';
      _selectedCategory = ev.category;
      _selectedRegion = ev.region.isNotEmpty ? ev.region : null;
      _selectedCity = ev.city.isNotEmpty ? ev.city : null;
      _startDate = ev.startDate;
      _endDate = ev.endDate;
      _isOnline = ev.region.isEmpty && ev.city.isEmpty;

      // Let the cubit know we are in edit mode
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CreateEventCubit>().setEventIdForEdit(ev.id, ev.coverUrl);
      });
    }
  }

  final List<String> _categories = [
    'مواسم ومهرجانات',
    'حفلات ومهرجانات',
    'رياضة ومغامرات',
    'فنون وثقافة',
    'محاضرات وورش عمل',
    'طعام وترفيه',
    'معارض ومؤتمرات',
    'فعاليات مجتمعية',
    'أخرى',
  ];

  final List<String> _regions = [
    'المنطقة الوسطى',
    'المنطقة الغربية',
    'المنطقة الشرقية',
    'المنطقة الشمالية',
    'المنطقة الجنوبية',
  ];

  final List<String> _cities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الجبيل',
    'أبها',
    'تبوك',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    _googleMapsUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      context.read<CreateEventCubit>().selectImage(image.path);
    }
  }

  Future<void> _selectStartDateTime() async {
    final picked = await _selectDateTime(context, _startDate ?? DateTime.now());
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Adjust end date if it is before start date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate!.add(const Duration(hours: 2));
        }
      });
    }
  }

  Future<void> _selectEndDateTime() async {
    final picked = await _selectDateTime(
      context,
      _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(hours: 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<DateTime?> _selectDateTime(
    BuildContext context,
    DateTime initialDateTime,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return null;

    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'اختر التاريخ والوقت';
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يونيو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} | $hour:$minute';
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      context.showSnackBar(
        'يرجى تحديد أوقات البداية والنهاية للفعالية',
        isError: true,
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      context.showSnackBar(
        'تاريخ النهاية لا يمكن أن يكون قبل تاريخ البداية',
        isError: true,
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      context.showSnackBar(
        'يجب تسجيل الدخول أولاً لإنشاء فعالية',
        isError: true,
      );
      return;
    }

    context.read<CreateEventCubit>().submitEvent(
      creatorId: authState.user.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      region: _isOnline ? '' : (_selectedRegion ?? ''),
      city: _isOnline ? '' : (_selectedCity ?? ''),
      locationName: _locationNameController.text.trim(),
      googleMapsUrl: _googleMapsUrlController.text.trim().isNotEmpty
          ? _googleMapsUrlController.text.trim()
          : null,
      startDate: _startDate!,
      endDate: _endDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.eventToEdit != null ? 'تعديل فعالية' : 'إنشاء فعالية',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.eventToEdit != null) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.outline,
            width: 0.5,
          ),
        ),
      ),
      body: BlocConsumer<CreateEventCubit, CreateEventState>(
        listener: (context, state) {
          if (state is CreateEventSuccess) {
            context.showSnackBar(
              widget.eventToEdit != null ? 'تم حفظ التعديلات بنجاح!' : 'تم إنشاء الفعالية بنجاح!',
            );
            context.read<CreateEventCubit>().reset();
            // Reset local controllers
            _titleController.clear();
            _descriptionController.clear();
            _locationNameController.clear();
            _googleMapsUrlController.clear();
            if (mounted) {
              setState(() {
                _selectedCategory = null;
                _selectedRegion = null;
                _selectedCity = null;
                _startDate = null;
                _endDate = null;
                _isOnline = false;
              });
            }
            // Safely navigate back or switch tab to home
            if (widget.eventToEdit != null) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          } else if (state is CreateEventError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isUploading = state is CreateEventUploadingImage;
          final isSaving = state is CreateEventSavingData;
          final isLoading = isUploading || isSaving;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Selector
                    _buildImageSelector(state, isLoading),
                    const SizedBox(height: 24),

                    // Title
                    _buildLabel('عنوان الفعالية'),
                    TextFormField(
                      controller: _titleController,
                      enabled: !isLoading,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'مثال: معرض الرياض الدولي للكتاب',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'يرجى إدخال عنوان الفعالية'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel('تفاصيل الفعالية (اختياري)'),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !isLoading,
                      textAlign: TextAlign.right,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'اكتب تفاصيل الفعالية، الأنشطة، وشروط الحضور...',
                      ),
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    _buildLabel('التصنيف / الفئة'),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      alignment: Alignment.centerRight,
                      decoration: const InputDecoration(
                        hintText: 'اختر تصنيف الفعالية',
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(c, style: AppTextStyles.bodyMd),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (val) => setState(() => _selectedCategory = val),
                      validator: (value) =>
                          value == null ? 'يرجى اختيار تصنيف الفعالية' : null,
                    ),
                    const SizedBox(height: 16),

                    // Switch for online event
                    InkWell(
                      onTap: isLoading
                          ? null
                          : () {
                              setState(() {
                                _isOnline = !_isOnline;
                                if (_isOnline) {
                                  _selectedRegion = null;
                                  _selectedCity = null;
                                }
                              });
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isOnline
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Switch(
                              value: _isOnline,
                              activeColor: AppColors.primary,
                              onChanged: isLoading
                                  ? null
                                  : (val) {
                                      setState(() {
                                        _isOnline = val;
                                        if (_isOnline) {
                                          _selectedRegion = null;
                                          _selectedCity = null;
                                        }
                                      });
                                    },
                            ),
                            Text(
                              'فعالية أونلاين (افتراضية)',
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _isOnline
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Region and City Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('المنطقة (اختياري)'),
                              DropdownButtonFormField<String>(
                                value: _selectedRegion,
                                alignment: Alignment.centerRight,
                                decoration: InputDecoration(
                                  hintText: _isOnline ? 'أونلاين' : 'اختر المنطقة',
                                  enabled: !_isOnline && !isLoading,
                                ),
                                items: _isOnline
                                    ? null
                                    : _regions
                                        .map(
                                          (r) => DropdownMenuItem(
                                            value: r,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                r,
                                                style: AppTextStyles.bodyMd,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: isLoading || _isOnline
                                    ? null
                                    : (val) =>
                                          setState(() => _selectedRegion = val),
                                validator: (value) => null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('المدينة (اختياري)'),
                              DropdownButtonFormField<String>(
                                value: _selectedCity,
                                alignment: Alignment.centerRight,
                                decoration: InputDecoration(
                                  hintText: _isOnline ? 'أونلاين' : 'اختر المدينة',
                                  enabled: !_isOnline && !isLoading,
                                ),
                                items: _isOnline
                                    ? null
                                    : _cities
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                c,
                                                style: AppTextStyles.bodyMd,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: isLoading || _isOnline
                                    ? null
                                    : (val) =>
                                          setState(() => _selectedCity = val),
                                validator: (value) => null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location Name
                    _buildLabel('اسم موقع الفعالية'),
                    TextFormField(
                      controller: _locationNameController,
                      enabled: !isLoading,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'مثال: مركز الرياض للمعارض والمؤتمرات',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'يرجى إدخال اسم موقع الفعالية'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Google Maps URL
                    _buildLabel('رابط الموقع على خرائط جوجل (اختياري)'),
                    TextFormField(
                      controller: _googleMapsUrlController,
                      enabled: !isLoading,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        hintText: 'https://maps.google.com/...',
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final uri = Uri.tryParse(value.trim());
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'يرجى إدخال رابط خرائط جوجل صحيح';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start and End Date selection
                    _buildLabel('تاريخ ووقت البدء'),
                    InkWell(
                      onTap: isLoading ? null : _selectStartDateTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDateTime(_startDate),
                              style: AppTextStyles.bodyMd.copyWith(
                                color: _startDate != null
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant.withOpacity(
                                        0.5,
                                      ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('تاريخ ووقت الانتهاء'),
                    InkWell(
                      onTap: isLoading ? null : _selectEndDateTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDateTime(_endDate),
                              style: AppTextStyles.bodyMd.copyWith(
                                color: _endDate != null
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant.withOpacity(
                                        0.5,
                                      ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    PrimaryButton(
                      text: isUploading
                          ? 'جاري رفع الصورة الغلاف...'
                          : isSaving
                          ? 'جاري حفظ البيانات...'
                          : 'إنشاء الفعالية',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submitForm,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImageSelector(CreateEventState state, bool isLoading) {
    final localPath = state.localImagePath;
    final coverUrl = state.coverUrl;

    Widget childContent;
    if (localPath != null) {
      childContent = Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(localPath), fit: BoxFit.cover),
          if (coverUrl != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'تم الرفع',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'تغيير الصورة',
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      childContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'رفع صورة الغلاف للفعالية',
            style: AppTextStyles.titleSm.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الصيغ المدعومة: PNG, JPG (الحد الأقصى 5 ميجابايت)',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: isLoading ? null : _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: childContent,
      ),
    );
  }
}
