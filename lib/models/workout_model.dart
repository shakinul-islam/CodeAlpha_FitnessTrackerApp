class Workout {
  final int? id;
  final String title;
  final int duration;
  final int calories;
  final DateTime date;

  final String intensity;
  final double? distance;
  final String? notes;

  const Workout({
    this.id,
    required this.title,
    required this.duration,
    required this.calories,
    required this.date,
    this.intensity = 'Moderate',
    this.distance,
    this.notes,
  });

  Workout copyWith({
    int? id,
    String? title,
    int? duration,
    int? calories,
    DateTime? date,
    String? intensity,
    double? distance,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      date: date ?? this.date,
      intensity: intensity ?? this.intensity,
      distance: distance ?? this.distance,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'calories': calories,
      'date': date.toIso8601String(),
      'intensity': intensity,
      'distance': distance,
      'notes': notes,
    };
  }

  factory Workout.fromMap(
    Map<String, dynamic> map,
  ) {
    return Workout(
      id: map['id'] as int?,
      title: map['title'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] as int,

      date: DateTime.parse(
        map['date'] as String,
      ),

      intensity:
          (map['intensity'] as String?) ??
              'Moderate',

      distance:
          (map['distance'] as num?)
              ?.toDouble(),

      notes: map['notes'] as String?,
    );
  }
}