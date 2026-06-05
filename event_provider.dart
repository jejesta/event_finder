// lib/providers/event_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  bool _isLoading = false;
  String _searchQuery = '';
  EventCategory? _selectedCategory;
  String _sortBy = 'date'; // date, name, price

  static const String _storageKey = 'events_data';
  final Uuid _uuid = const Uuid();

  List<EventModel> get events => _filteredEvents;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  EventCategory? get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;

  List<EventModel> get _filteredEvents {
    List<EventModel> result = List.from(_events);

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      result = result.where((e) {
        return e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.organizer.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      result =
          result.where((e) => e.category == _selectedCategory).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'date':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'name':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'price':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
    }

    return result;
  }

  List<EventModel> get upcomingEvents =>
      _events.where((e) => e.isUpcoming).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<EventModel> get favoriteEvents =>
      _events.where((e) => e.isFavorite).toList();

  int get totalEvents => _events.length;
  int get upcomingCount => upcomingEvents.length;
  int get favoriteCount => favoriteEvents.length;

  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200)); // Simulate loading

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonData = prefs.getString(_storageKey);

      if (jsonData != null) {
        final List<dynamic> list = jsonDecode(jsonData);
        _events = list.map((e) => EventModel.fromMap(e)).toList();
      } else {
        _events = _generateSampleEvents();
        await _saveEvents();
      }
    } catch (e) {
      _events = _generateSampleEvents();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent(EventModel event) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final newEvent = event.copyWith(id: _uuid.v4());
    _events.insert(0, newEvent);
    await _saveEvents();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateEvent(EventModel updatedEvent) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      await _saveEvents();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isFavorite: !_events[index].isFavorite,
      );
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> joinEvent(String id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1 && !_events[index].isFull) {
      _events[index] = _events[index].copyWith(
        currentAttendees: _events[index].currentAttendees + 1,
      );
      await _saveEvents();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(EventCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _sortBy = 'date';
    notifyListeners();
  }

  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(_events.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, jsonData);
  }

  List<EventModel> _generateSampleEvents() {
    final now = DateTime.now();
    return [
      EventModel(
        id: _uuid.v4(),
        title: 'Java Jazz Festival 2025',
        description:
        'Festival jazz tahunan terbesar di Indonesia yang menghadirkan musisi kelas dunia dan lokal. Nikmati malam penuh harmoni dengan lantunan jazz dari berbagai genre dan era.',
        location: 'Jakarta Convention Center, Jakarta',
        date: now.add(const Duration(days: 15)),
        time: '18:00',
        category: EventCategory.music,
        maxAttendees: 5000,
        currentAttendees: 3421,
        organizer: 'Java Festival Production',
        price: 250000,
        isFavorite: true,
        imageUrl:
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Surabaya Tech Summit 2025',
        description:
        'Konferensi teknologi terkemuka di Surabaya yang mempertemukan para inovator, developer, dan pemimpin industri teknologi untuk berbagi wawasan dan tren terbaru di dunia tech.',
        location: 'Grand City Convention, Surabaya',
        date: now.add(const Duration(days: 8)),
        time: '09:00',
        category: EventCategory.technology,
        maxAttendees: 1000,
        currentAttendees: 750,
        organizer: 'SurabayaDev Community',
        price: 150000,
        isFavorite: false,
        imageUrl:
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Kuliner Nusantara Expo',
        description:
        'Pameran kuliner terlengkap yang menampilkan ragam masakan autentik dari seluruh penjuru nusantara. Temukan cita rasa baru dan nikmati pengalaman gastronomi yang tak terlupakan.',
        location: 'Tunjungan Plaza, Surabaya',
        date: now.add(const Duration(days: 3)),
        time: '10:00',
        category: EventCategory.food,
        maxAttendees: 2000,
        currentAttendees: 1850,
        organizer: 'Dinas Pariwisata Surabaya',
        price: 0,
        isFavorite: true,
        imageUrl:
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Liga Futsal Mahasiswa',
        description:
        'Turnamen futsal antar kampus se-Jawa Timur yang mempertemukan tim-tim terbaik dari berbagai universitas. Dukung tim favoritmu dan saksikan pertandingan seru.',
        location: 'GOR Universitas Airlangga, Surabaya',
        date: now.add(const Duration(days: 20)),
        time: '08:00',
        category: EventCategory.sports,
        maxAttendees: 500,
        currentAttendees: 120,
        organizer: 'BEM Universitas Airlangga',
        price: 25000,
        isFavorite: false,
        imageUrl:
        'https://images.unsplash.com/photo-1552667466-07770ae110d0?w=800',
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Pameran Seni Kontemporer',
        description:
        'Pameran seni rupa kontemporer yang menampilkan karya-karya seniman muda berbakat Indonesia. Eksplorasi berbagai medium seni dari lukisan, instalasi, hingga seni digital.',
        location: 'House of Sampoerna, Surabaya',
        date: now.add(const Duration(days: 5)),
        time: '11:00',
        category: EventCategory.art,
        maxAttendees: 300,
        currentAttendees: 89,
        organizer: 'Komunitas Seni Surabaya',
        price: 50000,
        isFavorite: false,
        imageUrl:
        'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800',
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Workshop Flutter Development',
        description:
        'Workshop intensif pengembangan aplikasi mobile menggunakan Flutter. Pelajari cara membuat UI yang indah, state management, dan integrasi API dalam 2 hari penuh bersama mentor berpengalaman.',
        location: 'Coworking Space Tokopedia, Surabaya',
        date: now.add(const Duration(days: 12)),
        time: '09:00',
        category: EventCategory.education,
        maxAttendees: 50,
        currentAttendees: 48,
        organizer: 'Flutter Indonesia',
        price: 500000,
        isFavorite: true,
        imageUrl:
        'https://images.unsplash.com/photo-1587620962725-abab7fe55159?w=800',
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Startup Pitch Competition',
        description:
        'Kompetisi pitch startup untuk para entrepreneur muda Indonesia. Presentasikan ide bisnismu di hadapan investor dan mentor berpengalaman, menangkan total hadiah senilai 500 juta rupiah.',
        location: 'Surabaya North Quay',
        date: now.add(const Duration(days: 30)),
        time: '13:00',
        category: EventCategory.business,
        maxAttendees: 200,
        currentAttendees: 67,
        organizer: 'Startup Surabaya',
        price: 100000,
        isFavorite: false,
        imageUrl:
        'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=800',
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Yoga & Wellness Festival',
        description:
        'Festival kesehatan dan kebugaran yang menghadirkan sesi yoga, meditasi, dan workshop wellness dari instruktur bersertifikat. Temukan keseimbangan jiwa dan raga.',
        location: 'Pantai Kenjeran, Surabaya',
        date: now.add(const Duration(days: 7)),
        time: '06:00',
        category: EventCategory.health,
        maxAttendees: 150,
        currentAttendees: 95,
        organizer: 'Yoga Indonesia Community',
        price: 75000,
        isFavorite: false,
        imageUrl:
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
      ),
    ];
  }
}
