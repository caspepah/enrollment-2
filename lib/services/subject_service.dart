import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';

class SubjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all subjects
  Stream<List<Subject>> getSubjects() {
    return _firestore.collection('subjects').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Subject.fromMap(doc.data())).toList());
  }

  // Add a subject
  Future<void> addSubject(Subject subject) {
    return _firestore.collection('subjects').add({
      'name': subject.name,
      'credits': subject.credits,
    });
  }

  // Initialize default subjects if none exist
  Future<void> initializeDefaultSubjects() async {
    final snapshot = await _firestore.collection('subjects').get();

    if (snapshot.docs.isEmpty) {
      final defaultSubjects = [
        {'name': 'Microcontroller', 'credits': 3},
        {'name': 'IoT Programming', 'credits': 3},
        {'name': 'Embedded System', 'credits': 3},
        {'name': 'Robotics', 'credits': 4},
        {'name': 'Automatics Navigation System', 'credits': 3},
        {'name': 'IoT Project', 'credits': 4},
        {'name': 'Cyber Security Fundamentals', 'credits': 3},
        {'name': 'Security Risk Management', 'credits': 3},
        {'name': 'Security Compliance and Audit', 'credits': 3},
        {'name': 'Ethical Hacking', 'credits': 4},
        {'name': 'Digital Forensics', 'credits': 3},
        {'name': 'Cyber Security Project', 'credits': 4},
        {'name': 'Image Processing and Recognition', 'credits': 3},
        {'name': 'Computer Vision', 'credits': 4},
        {'name': 'Natural Language Processing', 'credits': 3},
        {'name': 'Natural Language Understanding and Generation', 'credits': 3},
        {'name': 'Intelligent Robotics', 'credits': 4},
        {'name': 'Deep Learning', 'credits': 4},
      ];

      final batch = _firestore.batch();

      for (var subject in defaultSubjects) {
        final docRef = _firestore.collection('subjects').doc();
        batch.set(docRef, subject);
      }

      await batch.commit();
    }
  }
}
