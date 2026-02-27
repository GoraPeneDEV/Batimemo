import 'package:hive/hive.dart';

part 'form_option_model.g.dart';

@HiveType(typeId: 100)
class FormOptionModel {
  @HiveField(0)
  final String label;

  @HiveField(1)
  final String value;

  FormOptionModel({
    required this.label,
    required this.value,
  });

  factory FormOptionModel.fromJson(Map<String, dynamic> json) {
    return FormOptionModel(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }

  FormOptionModel copyWith({
    String? label,
    String? value,
  }) {
    return FormOptionModel(
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  @override
  String toString() {
    return 'FormOptionModel(label: $label, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FormOptionModel &&
        other.label == label &&
        other.value == value;
  }

  @override
  int get hashCode => label.hashCode ^ value.hashCode;
}
