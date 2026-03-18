class BusinessType {
  final String uid;
  final String name;
  final String description;

  const BusinessType({
    required this.uid,
    required this.name,
    required this.description,
  });

  factory BusinessType.fromJson(Map<String, dynamic> json) {
    return BusinessType(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
    };
  }
}