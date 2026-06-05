// lib/widgets/event_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import 'shimmer_loading.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final int animationIndex;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavorite,
    this.animationIndex = 0,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.animationIndex * 60)),
    );

    _slideAnim = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.animationIndex * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _categoryColor {
    return AppTheme.getCategoryColor(
        widget.event.category.name.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: Opacity(
            opacity: _fadeAnim.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.divider, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                _buildInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
          child: widget.event.imageUrl != null
              ? Image.network(
            widget.event.imageUrl!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const ShimmerEventCard();
            },
          )
              : _buildPlaceholderImage(),
        ),
        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        // Category badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _categoryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _categoryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.event.category.emoji,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.event.category.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Favorite button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.onFavorite,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.event.isFavorite
                    ? AppTheme.secondary.withOpacity(0.9)
                    : Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.event.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(widget.event.isFavorite),
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        // Upcoming / Full badge
        if (widget.event.isFull)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PENUH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _categoryColor.withOpacity(0.3),
            _categoryColor.withOpacity(0.1),
          ],
        ),
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Text(
          widget.event.category.emoji,
          style: const TextStyle(fontSize: 60),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    final occupancy = widget.event.occupancyRate;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Date & Time
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: _categoryColor),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(widget.event.date),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time_rounded,
                  size: 14, color: _categoryColor),
              const SizedBox(width: 6),
              Text(
                widget.event.time,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Location
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: _categoryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.event.location,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Occupancy bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.event.currentAttendees} / ${widget.event.maxAttendees} peserta',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(occupancy * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _occupancyColor(occupancy),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedProgressBar(
                value: occupancy,
                color: _occupancyColor(occupancy),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Price & Organizer
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.event.organizer,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.event.price == 0
                      ? 'GRATIS'
                      : 'Rp ${NumberFormat('#,###', 'id_ID').format(widget.event.price)}',
                  style: TextStyle(
                    color: _categoryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _occupancyColor(double value) {
    if (value >= 0.9) return AppTheme.error;
    if (value >= 0.7) return AppTheme.warning;
    return AppTheme.success;
  }
}
