class HolidayModel {
  final int id;
  final String name;
  final String? code;
  final String date;
  final int year;
  final String day;
  final String? type;
  final String? category;
  final bool? isOptional;
  final bool? isRestricted;
  final bool? isRecurring;
  final bool? isHalfDay;
  final bool? isActive;
  final bool? isVisibleToEmployees;
  final String? color;
  final String? description;
  final String? notes;
  final String? image;
  final String createdAt;
  final String updatedAt;

  HolidayModel({
    required this.id,
    required this.name,
    this.code,
    required this.date,
    required this.year,
    required this.day,
    this.type,
    this.category,
    this.isOptional,
    this.isRestricted,
    this.isRecurring,
    this.isHalfDay,
    this.isActive,
    this.isVisibleToEmployees,
    this.color,
    this.description,
    this.notes,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    // Handle year as both String and int
    int parsedYear = DateTime.now().year;
    if (json['year'] != null) {
      if (json['year'] is int) {
        parsedYear = json['year'];
      } else if (json['year'] is String) {
        parsedYear = int.tryParse(json['year']) ?? DateTime.now().year;
      }
    }

    return HolidayModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      date: json['date'],
      year: parsedYear,
      day: json['day'] ?? '',
      type: json['type'],
      category: json['category'],
      isOptional: json['isOptional'] ?? json['is_optional'],
      isRestricted: json['isRestricted'] ?? json['is_restricted'],
      isRecurring: json['isRecurring'] ?? json['is_recurring'],
      isHalfDay: json['isHalfDay'] ?? json['is_half_day'],
      isActive: json['isActive'] ?? json['is_active'],
      isVisibleToEmployees: json['isVisibleToEmployees'] ?? json['is_visible_to_employees'],
      color: json['color'],
      description: json['description'],
      notes: json['notes'],
      image: json['image'],
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? '',
    );
  }
}

class HolidayModelResponse {
  final int totalCount;
  final List<HolidayModel> values;

  HolidayModelResponse({
    required this.totalCount,
    required this.values,
  });

  factory HolidayModelResponse.fromJson(Map<String, dynamic> json) =>
      HolidayModelResponse(
        totalCount: json['totalCount'],
        values: (json['values'] as List)
            .map((item) => HolidayModel.fromJson(item))
            .toList(),
      );
}
