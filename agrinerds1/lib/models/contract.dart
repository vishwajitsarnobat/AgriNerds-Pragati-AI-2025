import 'dart:convert';

class Contract {
  final String id;
  final String title;
  final String description;
  final String cropType;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String createdBy;
  final DateTime createdAt;
  final List<String> applicants;
  final String? selectedApplicant;
  final bool isActive;

  Contract({
    required this.id,
    required this.title,
    required this.description,
    required this.cropType,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.createdBy,
    required this.createdAt,
    this.applicants = const [],
    this.selectedApplicant,
    this.isActive = true,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'].toString(),
      title: json['title'].toString(),
      description: json['description'].toString(),
      cropType: json['cropType'].toString(),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'].toString(),
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'].toString()),
      endDate: DateTime.parse(json['endDate'].toString()),
      location: json['location'].toString(),
      createdBy: json['createdBy'].toString(),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      applicants: json['applicants'] != null 
          ? List<String>.from(jsonDecode(json['applicants'].toString()))
          : [],
      selectedApplicant: json['selectedApplicant']?.toString(),
      isActive: (json['isActive'] as int?) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cropType': cropType,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'applicants': jsonEncode(applicants),
      'selectedApplicant': selectedApplicant,
      'isActive': isActive ? 1 : 0,
    };
  }

  Contract copyWith({
    String? id,
    String? title,
    String? description,
    String? cropType,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? createdBy,
    DateTime? createdAt,
    List<String>? applicants,
    String? selectedApplicant,
    bool? isActive,
  }) {
    return Contract(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cropType: cropType ?? this.cropType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      applicants: applicants ?? this.applicants,
      selectedApplicant: selectedApplicant ?? this.selectedApplicant,
      isActive: isActive ?? this.isActive,
    );
  }
} 