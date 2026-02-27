import 'package:hive/hive.dart';
import 'form_option_model.dart';

part 'form_field_model.g.dart';

/// Enum for all supported field types
enum FormFieldType {
  text,
  textarea,
  email,
  number,
  tel,
  url,
  password,
  date,
  time,
  datetimeLocal,
  select,
  radio,
  checkbox,
  file,
  range,
  color,
  hidden,
  html,
  heading,
  divider,
  rating,
}

@HiveType(typeId: 101)
class FormFieldModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String? label;

  @HiveField(4)
  final bool required;

  @HiveField(5)
  final String? placeholder;

  // Options for select, radio, checkbox fields
  @HiveField(6)
  final List<FormOptionModel>? options;

  // Textarea specific
  @HiveField(7)
  final int? rows;

  // Number and range specific
  @HiveField(8)
  final double? min;

  @HiveField(9)
  final double? max;

  @HiveField(10)
  final double? step;

  // File specific
  @HiveField(11)
  final String? accept;

  @HiveField(12)
  final int? maxSize; // in bytes

  @HiveField(13)
  final bool? multiple;

  // HTML content specific
  @HiveField(14)
  final String? content;

  // Heading specific
  @HiveField(15)
  final String? level; // h1, h2, h3, h4, h5, h6

  @HiveField(16)
  final String? text;

  // Rating specific
  @HiveField(17)
  final int? maxRating;

  // Additional validation properties
  @HiveField(18)
  final String? pattern;

  @HiveField(19)
  final int? minLength;

  @HiveField(20)
  final int? maxLength;

  // Default value
  @HiveField(21)
  final String? defaultValue;

  // Help text
  @HiveField(22)
  final String? helpText;

  // Conditional display
  @HiveField(23)
  final Map<String, dynamic>? conditionalDisplay;

  FormFieldModel({
    required this.id,
    required this.name,
    required this.type,
    this.label,
    this.required = false,
    this.placeholder,
    this.options,
    this.rows,
    this.min,
    this.max,
    this.step,
    this.accept,
    this.maxSize,
    this.multiple,
    this.content,
    this.level,
    this.text,
    this.maxRating,
    this.pattern,
    this.minLength,
    this.maxLength,
    this.defaultValue,
    this.helpText,
    this.conditionalDisplay,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      label: json['label'] as String?,
      required: json['required'] as bool? ?? false,
      placeholder: json['placeholder'] as String?,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((option) => FormOptionModel.fromJson(option as Map<String, dynamic>))
              .toList()
          : null,
      rows: json['rows'] as int?,
      min: _parseDouble(json['min']),
      max: _parseDouble(json['max']),
      step: _parseDouble(json['step']),
      accept: json['accept'] as String?,
      maxSize: json['maxSize'] as int?,
      multiple: json['multiple'] as bool?,
      content: json['content'] as String?,
      level: json['level'] as String?,
      text: json['text'] as String?,
      maxRating: json['max'] as int?,
      pattern: json['pattern'] as String?,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      defaultValue: json['defaultValue']?.toString(),
      helpText: json['helpText'] as String?,
      conditionalDisplay: json['conditionalDisplay'] as Map<String, dynamic>?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'label': label,
      'required': required,
      'placeholder': placeholder,
      'options': options?.map((option) => option.toJson()).toList(),
      'rows': rows,
      'min': min,
      'max': max,
      'step': step,
      'accept': accept,
      'maxSize': maxSize,
      'multiple': multiple,
      'content': content,
      'level': level,
      'text': text,
      'maxRating': maxRating,
      'pattern': pattern,
      'minLength': minLength,
      'maxLength': maxLength,
      'defaultValue': defaultValue,
      'helpText': helpText,
      'conditionalDisplay': conditionalDisplay,
    };
  }

  FormFieldModel copyWith({
    String? id,
    String? name,
    String? type,
    String? label,
    bool? required,
    String? placeholder,
    List<FormOptionModel>? options,
    int? rows,
    double? min,
    double? max,
    double? step,
    String? accept,
    int? maxSize,
    bool? multiple,
    String? content,
    String? level,
    String? text,
    int? maxRating,
    String? pattern,
    int? minLength,
    int? maxLength,
    String? defaultValue,
    String? helpText,
    Map<String, dynamic>? conditionalDisplay,
  }) {
    return FormFieldModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      label: label ?? this.label,
      required: required ?? this.required,
      placeholder: placeholder ?? this.placeholder,
      options: options ?? this.options,
      rows: rows ?? this.rows,
      min: min ?? this.min,
      max: max ?? this.max,
      step: step ?? this.step,
      accept: accept ?? this.accept,
      maxSize: maxSize ?? this.maxSize,
      multiple: multiple ?? this.multiple,
      content: content ?? this.content,
      level: level ?? this.level,
      text: text ?? this.text,
      maxRating: maxRating ?? this.maxRating,
      pattern: pattern ?? this.pattern,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      defaultValue: defaultValue ?? this.defaultValue,
      helpText: helpText ?? this.helpText,
      conditionalDisplay: conditionalDisplay ?? this.conditionalDisplay,
    );
  }

  /// Get the field type as enum
  FormFieldType get fieldType {
    switch (type.toLowerCase()) {
      case 'text':
        return FormFieldType.text;
      case 'textarea':
        return FormFieldType.textarea;
      case 'email':
        return FormFieldType.email;
      case 'number':
        return FormFieldType.number;
      case 'tel':
        return FormFieldType.tel;
      case 'url':
        return FormFieldType.url;
      case 'password':
        return FormFieldType.password;
      case 'date':
        return FormFieldType.date;
      case 'time':
        return FormFieldType.time;
      case 'datetime-local':
        return FormFieldType.datetimeLocal;
      case 'select':
        return FormFieldType.select;
      case 'radio':
        return FormFieldType.radio;
      case 'checkbox':
        return FormFieldType.checkbox;
      case 'file':
        return FormFieldType.file;
      case 'range':
        return FormFieldType.range;
      case 'color':
        return FormFieldType.color;
      case 'hidden':
        return FormFieldType.hidden;
      case 'html':
        return FormFieldType.html;
      case 'heading':
        return FormFieldType.heading;
      case 'divider':
        return FormFieldType.divider;
      case 'rating':
        return FormFieldType.rating;
      default:
        return FormFieldType.text;
    }
  }

  /// Check if this field requires options (select, radio, checkbox)
  bool get requiresOptions {
    return fieldType == FormFieldType.select ||
        fieldType == FormFieldType.radio ||
        fieldType == FormFieldType.checkbox;
  }

  /// Check if this field is a display-only field (html, heading, divider)
  bool get isDisplayOnly {
    return fieldType == FormFieldType.html ||
        fieldType == FormFieldType.heading ||
        fieldType == FormFieldType.divider;
  }

  /// Check if this field accepts user input
  bool get acceptsInput {
    return !isDisplayOnly;
  }

  /// Check if this field can have validation
  bool get canHaveValidation {
    return acceptsInput && fieldType != FormFieldType.hidden;
  }

  @override
  String toString() {
    return 'FormFieldModel(id: $id, name: $name, type: $type, label: $label, required: $required)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FormFieldModel &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.label == label &&
        other.required == required;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        label.hashCode ^
        required.hashCode;
  }
}
