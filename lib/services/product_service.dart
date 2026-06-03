import 'package:flutter/material.dart';

class ProductService {
  static final ValueNotifier<List<Map<String, dynamic>>> _productsNotifier = ValueNotifier([
    {
      'id': '1',
      'name': 'Nugget Lele',
      'price': 25000,
      'stock': 50,
      'category': 'Makanan',
      'active': true,
      'image': 'assets/Nugget_Lele.jpeg',
      'description': 'Nugget lele olahan alami tanpa pengawet',
      'isFile': false,
    },
    {
      'id': '2',
      'name': 'Sempol Jamur',
      'price': 15000,
      'stock': 30,
      'category': 'Snack',
      'active': true,
      'image': 'assets/Sempol_Jamur.jpeg',
      'description': 'Sempol jamur tiram renyah dan gurih',
      'isFile': false,
    },
    {
      'id': '3',
      'name': 'Tahu Walik',
      'price': 20000,
      'stock': 20,
      'category': 'Makanan',
      'active': true,
      'image': 'assets/Tahu_Walik.jpeg',
      'description': 'Tahu walik isi ayam homemade',
      'isFile': false,
    },
    {
      'id': '4',
      'name': 'Jangkrik Krispi',
      'price': 18000,
      'stock': 15,
      'category': 'Snack',
      'active': true,
      'image': 'assets/Jangkrik_Crispi.jpeg',
      'description': 'Jangkrik krispi gurih dan bergizi',
      'isFile': false,
    },
    {
      'id': '5',
      'name': 'Sinom',
      'price': 12000,
      'stock': 40,
      'category': 'Minuman',
      'active': true,
      'image': 'assets/Sinom.jpeg',
      'description': 'Minuman sinom segar dari bahan alami',
      'isFile': false,
    },
    {
      'id': '6',
      'name': 'Sate Jamur',
      'price': 22000,
      'stock': 25,
      'category': 'Makanan',
      'active': true,
      'image': 'assets/Sate_Jamur.jpeg',
      'description': 'Sate jamur tiram dengan bumbu spesial',
      'isFile': false,
    },
  ]);

  static ValueNotifier<List<Map<String, dynamic>>> get productsNotifier => _productsNotifier;

  static List<Map<String, dynamic>> get products => _productsNotifier.value;

  static void addProduct(Map<String, dynamic> product) {
    final newList = List<Map<String, dynamic>>.from(_productsNotifier.value);
    newList.add(product);
    _productsNotifier.value = newList;
  }

  static void updateProduct(int index, Map<String, dynamic> product) {
    if (index >= 0 && index < _productsNotifier.value.length) {
      final newList = List<Map<String, dynamic>>.from(_productsNotifier.value);
      newList[index] = product;
      _productsNotifier.value = newList;
    }
  }

  static void deleteProduct(int index) {
    if (index >= 0 && index < _productsNotifier.value.length) {
      final newList = List<Map<String, dynamic>>.from(_productsNotifier.value);
      newList.removeAt(index);
      _productsNotifier.value = newList;
    }
  }

  static List<Map<String, dynamic>> getActiveProducts() {
    return _productsNotifier.value.where((p) => p['active'] == true).toList();
  }
}
