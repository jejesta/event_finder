// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../widgets/event_card.dart';
import '../widgets/shimmer_loading.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeTab(),
          _buildFavoritesTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentNavIndex == 0 ? _buildFAB() : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentNavIndex == 0
                  ? Icons.explore_rounded
                  : Icons.explore_outlined,
            ),
            label: 'Temukan',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentNavIndex == 1
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToForm(context),
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Tambah Event',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevation: 0,
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(),
        _buildSearchAndFilter(),
        _buildEventList(),
      ],
    );
  }

  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: Consumer<EventProvider>(
        builder: (context, provider, _) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.background, AppTheme.surface],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Finder',
                          style: GoogleFonts.nunito(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'Temukan Eventmu',
                          style: GoogleFonts.nunito(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border:
                        Border.all(color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats row
                provider.isLoading
                    ? Row(
                  children: List.generate(
                    3,
                        (i) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: const ShimmerStatCard(),
                    ),
                  ),
                )
                    : _buildStatsRow(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(EventProvider provider) {
    return Row(
      children: [
        _StatCard(
          label: 'Total Event',
          value: '${provider.totalEvents}',
          icon: Icons.event_rounded,
          color: AppTheme.primary,
          index: 0,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Upcoming',
          value: '${provider.upcomingCount}',
          icon: Icons.upcoming_rounded,
          color: AppTheme.success,
          index: 1,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Favorit',
          value: '${provider.favoriteCount}',
          icon: Icons.favorite_rounded,
          color: AppTheme.secondary,
          index: 2,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return SliverToBoxAdapter(
      child: Consumer<EventProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    onChanged: provider.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Cari event, lokasi, atau penyelenggara...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Sort & Filter row
                Row(
                  children: [
                    const Text(
                      'Kategori:',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _CategoryChip(
                              label: 'Semua',
                              isSelected: provider.selectedCategory == null,
                              onTap: () => provider.setCategory(null),
                            ),
                            ...EventCategory.values.map(
                                  (cat) => _CategoryChip(
                                label: cat.label,
                                emoji: cat.emoji,
                                isSelected:
                                provider.selectedCategory == cat,
                                onTap: () => provider.setCategory(cat),
                                color: AppTheme.getCategoryColor(cat.name),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Sort options
                Row(
                  children: [
                    const Text(
                      'Urutkan:',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SortChip(
                      label: 'Tanggal',
                      isSelected: provider.sortBy == 'date',
                      onTap: () => provider.setSortBy('date'),
                    ),
                    const SizedBox(width: 6),
                    _SortChip(
                      label: 'Nama',
                      isSelected: provider.sortBy == 'name',
                      onTap: () => provider.setSortBy('name'),
                    ),
                    const SizedBox(width: 6),
                    _SortChip(
                      label: 'Harga',
                      isSelected: provider.sortBy == 'price',
                      onTap: () => provider.setSortBy('price'),
                    ),
                    if (provider.searchQuery.isNotEmpty ||
                        provider.selectedCategory != null) ...[
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          provider.clearFilters();
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear_rounded, size: 14),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.secondary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          textStyle: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => const ShimmerEventCard(),
                childCount: 4,
              ),
            ),
          );
        }

        final events = provider.events;

        if (events.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final event = events[index];
                return Dismissible(
                  key: Key(event.id),
                  direction: DismissDirection.endToStart,
                  background: _buildDismissBackground(),
                  confirmDismiss: (_) => _confirmDelete(context, event.title),
                  onDismissed: (_) => provider.deleteEvent(event.id),
                  child: EventCard(
                    event: event,
                    animationIndex: index,
                    onTap: () => _navigateToDetail(context, event.id),
                    onFavorite: () => provider.toggleFavorite(event.id),
                  ),
                );
              },
              childCount: events.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_rounded, color: AppTheme.error, size: 28),
          const SizedBox(height: 4),
          Text(
            'Hapus',
            style: TextStyle(
              color: AppTheme.error,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: AppTheme.primary,
              size: 56,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Event',
            style: GoogleFonts.nunito(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau tambahkan event baru',
            style: GoogleFonts.nunito(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final favorites = provider.favoriteEvents;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                child: Text(
                  'Event Favorit',
                  style: GoogleFonts.nunito(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (provider.isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => const ShimmerEventCard(),
                    childCount: 3,
                  ),
                ),
              )
            else if (favorites.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        color: AppTheme.textSecondary,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Favorit',
                        style: GoogleFonts.nunito(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap ikon ❤️ pada event untuk\nmenambahkan ke favorit',
                        style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final event = favorites[index];
                      return EventCard(
                        event: event,
                        animationIndex: index,
                        onTap: () => _navigateToDetail(context, event.id),
                        onFavorite: () =>
                            provider.toggleFavorite(event.id),
                      );
                    },
                    childCount: favorites.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToDetail(BuildContext context, String id) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            EventDetailScreen(eventId: id),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<void> _navigateToForm(BuildContext context) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
        const EventFormScreen(),
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

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return await showDialog<bool>(
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
          'Apakah kamu yakin ingin menghapus "$title"?',
          style:
          GoogleFonts.nunito(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.nunito(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int index;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    Future.delayed(Duration(milliseconds: 100 + widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              widget.value,
              style: GoogleFonts.nunito(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              widget.label,
              style: GoogleFonts.nunito(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.emoji,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? chipColor.withOpacity(0.2)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? chipColor : AppTheme.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (emoji != null) ...[
                  Text(emoji!, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: isSelected ? chipColor : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color:
            isSelected ? AppTheme.primary : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight:
            isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
