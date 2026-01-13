import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// AUDIT LOG MODEL - Track Admin Actions
// ============================================================================
class AuditLog {
  final String id;
  final String action;
  final String adminName;
  final String details;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.action,
    required this.adminName,
    required this.details,
    required this.timestamp,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'adminName': adminName,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create from Map
  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] ?? '',
      action: map['action'] ?? '',
      adminName: map['adminName'] ?? '',
      details: map['details'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Firestore Document
  factory AuditLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLog.fromMap(data);
  }
}
