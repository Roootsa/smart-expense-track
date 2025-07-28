import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint; // Menyimpan code point dari IconData
  final int colorValue; // Menyimpan value dari Color

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'],
      iconCodePoint: data['iconCodePoint'],
      colorValue: data['colorValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }
}