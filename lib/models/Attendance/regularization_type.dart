/// Regularization type model
class RegularizationType {
  final String value;
  final String label;

  RegularizationType({
    required this.value,
    required this.label,
  });

  factory RegularizationType.fromJson(Map<String, dynamic> json) {
    return RegularizationType(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}
