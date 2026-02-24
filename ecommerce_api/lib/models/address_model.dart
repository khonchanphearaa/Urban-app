class AddressModel {
  final String? id;
  final String recipientName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  AddressModel({
    this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      recipientName: json['recipientName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zipCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty)
        'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? recipientName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      city,
      state,
      zipCode,
      country,
    ];
    return parts.join(', ');
  }
}
