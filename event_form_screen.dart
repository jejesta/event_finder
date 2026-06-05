// lib/screens/event_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../widgets/shimmer_loading.dart';

class EventFormScreen extends StatefulWidget {
  final EventModel? existingEvent;

  const EventFormScreen({super.key, this.existingEvent});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  // Controllers
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _organizerCtrl;
  late TextEditingController _maxAttendeesCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _imageUrlCtrl;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late EventCategory _selectedCategory;

  bool get isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    final event = widget.existingEvent;
    _titleCtrl = TextEditingController(text: event?.title ?? '');
    _descCtrl = TextEditingController(text: event?.description ?? '');
    _locationCtrl = TextEditingController(text: event?.location ?? '');
    _organizerCtrl = TextEditingController(text: event?.organizer ?? '');
    _maxAttendeesCtrl = TextEditingController(
        text: event?.maxAttendees.toString() ?? '100');
    _priceCtrl =
        TextEditingController(text: event?.price.toStringAsFixed(0) ?? '0');
    _imageUrlCtrl = TextEditingController(text: event?.imageUrl ?? '');

    _selectedDate = event?.date ?? DateTime.now().add(const Duration(days: 7));
    final timeParts = (event?.time ?? '09:00').split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    _selectedCategory = event?.category ?? EventCategory.music;
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _organizerCtrl.dispose();
    _maxAttendeesCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppTheme.background,
              appBar: _buildAppBar(context, provider),
              body: FadeTransition(
                opacity: _fadeAnim,
                child: _buildForm(context, provider),
              ),
            ),
            if (provider.isLoading)
              LoadingOverlay(
                message: isEditing ? 'Menyimpan perubahan...' : 'Menambah event...',
              ),
          ],
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, EventProvider provider) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary),
      ),
      title: Text(
        isEditing ? 'Edit Event' : 'Tambah Event',
        style: GoogleFonts.nunito(
          color: AppTheme.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ElevatedButton(
            onPressed: () => _submitForm(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isEditing ? 'Simpan' : 'Tambah',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, EventProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category selector
            _buildSectionLabel('Kategori Event'),
            _buildCategorySelector(),
            const SizedBox(height: 20),

            // Title
            _buildSectionLabel('Judul Event'),
            _buildTextField(
              controller: _titleCtrl,
              hint: 'Masukkan judul event yang menarik',
              icon: Icons.title_rounded,
              validator: (v) =>
              v?.isEmpty == true ? 'Judul tidak boleh kosong' : null,
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Description
            _buildSectionLabel('Deskripsi'),
            _buildTextField(
              controller: _descCtrl,
              hint: 'Ceritakan tentang event ini...',
              icon: Icons.description_rounded,
              validator: (v) =>
              v?.isEmpty == true ? 'Deskripsi tidak boleh kosong' : null,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Location
            _buildSectionLabel('Lokasi'),
            _buildTextField(
              controller: _locationCtrl,
              hint: 'Nama tempat dan kota',
              icon: Icons.location_on_rounded,
              validator: (v) =>
              v?.isEmpty == true ? 'Lokasi tidak boleh kosong' : null,
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Date & Time row
            _buildSectionLabel('Tanggal & Waktu'),
            Row(
              children: [
                Expanded(child: _buildDatePicker(context)),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker(context)),
              ],
            ),
            const SizedBox(height: 16),

            // Organizer
            _buildSectionLabel('Penyelenggara'),
            _buildTextField(
              controller: _organizerCtrl,
              hint: 'Nama penyelenggara atau organisasi',
              icon: Icons.person_rounded,
              validator: (v) =>
              v?.isEmpty == true ? 'Penyelenggara tidak boleh kosong' : null,
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Max attendees & Price
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Maks. Peserta'),
                      _buildTextField(
                        controller: _maxAttendeesCtrl,
                        hint: '100',
                        icon: Icons.people_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Wajib diisi';
                          if (int.tryParse(v!) == null)
                            return 'Angka tidak valid';
                          return null;
                        },
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Harga (Rp)'),
                      _buildTextField(
                        controller: _priceCtrl,
                        hint: '0 = Gratis',
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Wajib diisi';
                          if (double.tryParse(v!) == null)
                            return 'Angka tidak valid';
                          return null;
                        },
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image URL
            _buildSectionLabel('URL Gambar (Opsional)'),
            _buildTextField(
              controller: _imageUrlCtrl,
              hint: 'https://...',
              icon: Icons.image_rounded,
              maxLines: 1,
            ),

            // Preview
            if (_imageUrlCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _imageUrlCtrl.text,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: AppTheme.surfaceLight,
                    child: const Center(
                      child: Text(
                        'URL gambar tidak valid',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: AppTheme.textSecondary, size: 18),
        ),
        prefixIconConstraints:
        const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EventCategory.values.map((cat) {
        final isSelected = _selectedCategory == cat;
        final color = AppTheme.getCategoryColor(cat.name.toLowerCase());
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppTheme.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: GoogleFonts.nunito(
                    color: isSelected ? color : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppTheme.primary,
                  surface: AppTheme.surface,
                ),
                dialogBackgroundColor: AppTheme.surface,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppTheme.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dateFormat.format(_selectedDate),
                style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppTheme.primary,
                  surface: AppTheme.surface,
                ),
                dialogBackgroundColor: AppTheme.surface,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => _selectedTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                color: AppTheme.primary, size: 16),
            const SizedBox(width: 8),
            Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.nunito(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm(
      BuildContext context, EventProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    if (isEditing) {
      final updated = widget.existingEvent!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        date: _selectedDate,
        time: timeString,
        category: _selectedCategory,
        maxAttendees: int.parse(_maxAttendeesCtrl.text),
        organizer: _organizerCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        imageUrl: _imageUrlCtrl.text.trim().isEmpty
            ? null
            : _imageUrlCtrl.text.trim(),
      );

      await provider.updateEvent(updated);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.success),
                const SizedBox(width: 8),
                Text('Event berhasil diperbarui!',
                    style: GoogleFonts.nunito()),
              ],
            ),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      final newEvent = EventModel(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        date: _selectedDate,
        time: timeString,
        category: _selectedCategory,
        maxAttendees: int.parse(_maxAttendeesCtrl.text),
        organizer: _organizerCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        imageUrl: _imageUrlCtrl.text.trim().isEmpty
            ? null
            : _imageUrlCtrl.text.trim(),
      );

      await provider.addEvent(newEvent);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.success),
                const SizedBox(width: 8),
                Text('Event baru berhasil ditambahkan!',
                    style: GoogleFonts.nunito()),
              ],
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
