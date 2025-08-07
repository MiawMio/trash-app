import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    final user = currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      // Try to get from Firestore first
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return doc.data() ?? {};
      } else {
        // If no Firestore document, create one with default values
        final defaultData = {
          'name': user.displayName ?? 'Masukan Nama',
          'email': user.email ?? '',
          'photoUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(user.uid).set(defaultData);
        return defaultData;
      }
    } catch (e) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      return {
        'name': prefs.getString('user_name') ?? user.displayName ?? 'Masukan Nama',
        'email': user.email ?? '',
        'photoUrl': prefs.getString('user_photo_url'),
      };
    }
  }

  // Update user name
  Future<void> updateUserName(String name) async {
    final user = currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update in local storage as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);

      // Update Firebase Auth display name
      await user.updateDisplayName(name);
    } catch (e) {
      throw 'Failed to update name: $e';
    }
  }

  // Update user password
  Future<void> updateUserPassword(String newPassword) async {
    final user = currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      throw 'Failed to update password: $e';
    }
  }

  // Update profile photo (for now, we'll store the local path)
  Future<void> updateProfilePhoto(String photoPath) async {
    final user = currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoPath,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update in local storage as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_photo_url', photoPath);

      // Update Firebase Auth photo URL
      await user.updatePhotoURL(photoPath);
    } catch (e) {
      throw 'Failed to update profile photo: $e';
    }
  }

  // Get real-time profile updates
  Stream<Map<String, dynamic>> getProfileStream() {
    final user = currentUser;
    if (user == null) {
      return Stream.value({});
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() ?? {};
      } else {
        return {
          'name': user.displayName ?? 'Masukan Nama',
          'email': user.email ?? '',
          'photoUrl': null,
        };
      }
    });
  }
}