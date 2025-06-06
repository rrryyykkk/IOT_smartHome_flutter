import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LampHistoryList extends StatelessWidget {
  const LampHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lamp_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['message'] ?? 'Log'),
                subtitle: Text(data['timestamp']?.toDate().toString() ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
