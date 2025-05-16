/*
// lib/services/favorites_service.dart
import 'package:flutter/foundation.dart';

class FavoritesService {
  /// Notifica cada vez que cambie el set de favoritos.
  static final ValueNotifier<Set<String>> favorites = ValueNotifier({});

  /// ¿Es favorito el producto [id]?
  static bool isFavorite(String id) => favorites.value.contains(id);

  /// Alterna el estado de favorito para [id].
  static void toggleFavorite(String id) {
    final current = Set<String>.from(favorites.value);
    if (current.contains(id)) current.remove(id);
    else current.add(id);
    favorites.value = current;
  }
}
*/

// lib/services/favorites_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class FavoritesService {
  static final ValueNotifier<Set<String>> favorites = ValueNotifier({});
  static final _firestore = FirebaseFirestore.instance;

  /// Cargar favoritos del usuario desde Firestore
  static Future<void> loadFavorites() async {
    final userId = AuthService.userId;
    if (userId == null) return;

    final snapshot =
        await _firestore
            .collection('usuario')
            .doc(userId)
            .collection('favoritos')
            .get();

    final favIds = snapshot.docs.map((doc) => doc.id).toSet();
    favorites.value = favIds;
  }

  /// ¿Es favorito el producto [id]?
  static bool isFavorite(String id) => favorites.value.contains(id);

  /// Alternar el estado de favorito en local y Firestore
  static Future<void> toggleFavorite(String id) async {
    final userId = AuthService.userId;
    if (userId == null) return;

    final favs = Set<String>.from(favorites.value);
    final docRef = _firestore
        .collection('usuario')
        .doc(userId)
        .collection('favoritos')
        .doc(id);

    if (favs.contains(id)) {
      favs.remove(id);
      await docRef.delete();
    } else {
      favs.add(id);
      await docRef.set({'added_at': FieldValue.serverTimestamp()});
    }

    favorites.value = favs;
  }
}
