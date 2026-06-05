// lib/models/event_model.dart

enum EventCategory {
  music,
  sports,
  technology,
  food,
  art,
  business,
  education,
  health,
}

extension EventCategoryExtension on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.music:
        return 'Musik';
      case EventCategory.sports:
        return 'Olahraga';
      case EventCategory.technology:
        return 'Teknologi';
      case EventCategory.food:
        return 'Kuliner';
      case EventCategory.art:
        return 'Seni';
      case EventCategory.business:
        return 'Bisnis';
      case EventCategory.education:
        return 'Edukasi';
      case EventCategory.health:
        return 'Kesehatan';
    }
  }

  String get emoji {
    switch (this) {
      case EventCategory.music:
        return '🎵';
      case EventCategory.sports:
        return '⚽';
      case EventCategory.technology:
        return '💻';
      case EventCategory.food:
        return '🍔';
      case EventCategory.art:
        return '🎨';
      case EventCategory.business:
        return '💼';
      case EventCategory.education:
        return '📚';
      case EventCategory.health:
        return '🏥';
    }
  }
}

class EventModel {
  final String id;
  String title;
  String description;
  String location;
  DateTime date;
  String time;
  EventCategory category;
  int maxAttendees;
  int currentAttendees;
  String organizer;
  double price;
  bool isFavorite;
  String? imageUrl;
  DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.category,
    required this.maxAttendees,
    this.currentAttendees = 0,
    required this.organizer,
    this.price = 0.0,
    this.isFavorite = false,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? date,
    String? time,
    EventCategory? category,
    int? maxAttendees,
    int? currentAttendees,
    String? organizer,
    double? price,
    bool? isFavorite,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      organizer: organizer ?? this.organizer,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'time': time,
      'category': category.index,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'organizer': organizer,
      'price': price,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      category: EventCategory.values[map['category']],
      maxAttendees: map['maxAttendees'],
      currentAttendees: map['currentAttendees'] ?? 0,
      organizer: map['organizer'],
      price: (map['price'] as num).toDouble(),
      isFavorite: map['isFavorite'] ?? false,
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isFull => currentAttendees >= maxAttendees;
  double get occupancyRate =>
      maxAttendees > 0 ? currentAttendees / maxAttendees : 0;
}
