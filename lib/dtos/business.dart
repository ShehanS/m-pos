import 'business_type.dart';

class Business {
  final String uid;
  final String businessName;
  final BusinessType businessType;
  final String? address;
  final String? contact;
  final String? email;
  final String? location;
  final String? logoUrl;

  const Business({
    required this.uid,
    required this.businessName,
    required this.businessType,
    this.address,
    this.contact,
    this.email,
    this.location,
    this.logoUrl,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      uid: json['uid'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      businessType: BusinessType.fromJson(
        json['businessType'] as Map<String, dynamic>? ?? {},
      ),
      address: json['address'] as String?,
      contact: json['contact'] as String?,
      email: json['email'] as String?,
      location: json['location'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  factory Business.fromFirestore(Map<String, dynamic> data) =>
      Business.fromJson(data);

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'businessName': businessName,
      'businessType': businessType.toJson(),
      if (address != null) 'address': address,
      if (contact != null) 'contact': contact,
      if (email != null) 'email': email,
      if (location != null) 'location': location,
      if (logoUrl != null) 'logoUrl': logoUrl,
    };
  }
}