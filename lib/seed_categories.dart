import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:unimarket/features/product/model/product_category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final col = FirebaseFirestore.instance.collection('categories');
  for (var cat in ProductCategory.values) {
    await col.doc(cat.id).set(cat.toMap());
    print('Seeded: ${cat.id}');
  }
  print('SEED COMPLETE');
}
