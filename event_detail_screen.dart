// lib/screens/event_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../widgets/shimmer_loading.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _hasJoined = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.getEventById(widget.eventId);

        if (event == null) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              backgroundColor: AppTheme.background,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            body: const Center(
              child: Text(
                'Event tidak ditemukan',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppTheme.background,
              body: _buildBody(context, event, provider),
              bottomNavigationBar: _buildBottomBar(context, event, provider),
            ),
            if (provider.isLoading)
              const LoadingOverlay(message: 'Memproses...'),
          ],
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, EventModel event, EventProvider provider) {
    final categoryColor =
    AppTheme.getCategoryColor(event.category.name.toLowerCase());

    return CustomScrollView(
      slivers: [
        // Hero image header
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppTheme.background,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => provider.toggleFavorite(event.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: event.isFavorite
                            ? AppTheme.secondary.withOpacity(0.9)
                            : Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        event.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _navigateToEdit(context, event),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                event.imageUrl != null
                    ? Image.network(
                  event.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildPlaceholderHero(event, categoryColor),
                )
                    : _buildPlaceholderHero(event, categoryColor),
                // Gradient overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 1],
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(event.category.emoji,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          event.category.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: GoogleFonts.nunito(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Info cards grid
                    _buildInfoGrid(event, categoryColor),
                    const SizedBox(height: 20),
                    // Occupancy
                    _buildOccupancySection(event, categoryColor),
                    const SizedBox(height: 20),
                    // Description
                    _buildSection(
                      title: 'Tentang Event',
                      icon: Icons.info_outline_rounded,
                      color: categoryColor,
                      child: Text(
                        event.description,
                        style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Organizer
                    _buildSection(
                      title: 'Penyelenggara',
                      icon: Icons.business_rounded,
                      color: categoryColor,
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                event.organizer[0].toUpperCase(),
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              event.organizer,
                              style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(EventModel event, Color color) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat('#,###', 'id_ID');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _InfoTile(
          icon: Icons.calendar_today_rounded,
          label: 'Tanggal',
          value: dateFormat.format(event.date),
          color: color,
        ),
        _InfoTile(
          icon: Icons.access_time_rounded,
          label: 'Waktu',
          value: event.time + ' WIB',
          color: color,
        ),
        _InfoTile(
          icon: Icons.location_on_rounded,
          label: 'Lokasi',
          value: event.location,
          color: color,
        ),
        _InfoTile(
          icon: Icons.attach_money_rounded,
          label: 'Harga',
          value: event.price == 0
              ? 'GRATIS'
              : 'Rp ${currencyFormat.format(event.price)}',
          color: color,
        ),
      ],
    );
  }

  Widget _buildOccupancySection(EventModel event, Color color) {
    final occupancy = event.occupancyRate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kapasitas Peserta',
                style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: event.isFull
                      ? AppTheme.error.withOpacity(0.15)
                      : AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.isFull ? 'PENUH' : 'TERSEDIA',
                  style: TextStyle(
                    color: event.isFull ? AppTheme.error : AppTheme.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedProgressBar(
            value: occupancy,
            color: _occupancyColor(occupancy),
            height: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${event.currentAttendees} orang mendaftar',
                style: GoogleFonts.nunito(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                'Maks. ${event.maxAttendees}',
                style: GoogleFonts.nunito(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, EventModel event, EventProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Delete button
          GestureDetector(
            onTap: () => _confirmAndDelete(context, event, provider),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.error.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.error,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Join button
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: event.isFull
                  ? Container(
                key: const ValueKey('full'),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Event Penuh',
                    style: GoogleFonts.nunito(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
                  : _hasJoined
                  ? Container(
                key: const ValueKey('joined'),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sudah Daftar!',
                        style: GoogleFonts.nunito(
                          color: AppTheme.success,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : ElevatedButton(
                key: const ValueKey('join'),
                onPressed: () {
                  provider.joinEvent(event.id);
                  setState(() => _hasJoined = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppTheme.success),
                          const SizedBox(width: 8),
                          Text(
                            'Berhasil mendaftar ke ${event.title}!',
                            style: GoogleFonts.nunito(),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Daftar Sekarang',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderHero(EventModel event, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Text(
          event.category.emoji,
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context, EventModel event) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            EventFormScreen(existingEvent: event),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _confirmAndDelete(
      BuildContext context, EventModel event, EventProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Event',
          style: GoogleFonts.nunito(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${event.title}"?\nTindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.nunito(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Hapus',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteEvent(event.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Color _occupancyColor(double value) {
    if (value >= 0.9) return AppTheme.error;
    if (value >= 0.7) return AppTheme.warning;
    return AppTheme.success;
  }
}

// ─── Info Tile Widget ──────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
