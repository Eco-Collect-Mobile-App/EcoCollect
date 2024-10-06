import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:eco_collect/user_management/models/UserModel.dart';
import 'package:intl/intl.dart';
import 'package:eco_collect/pages/preferences.dart';

class WastePlans extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user == null) {
      return Center(child: Text('No user logged in.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Saved Plans',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF27AE60),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('savedPlans')
            .where('userId', isEqualTo: user.uid)
            .orderBy('dateGenerated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No saved plans found.'));
          }

          var savedPlans = snapshot.data!.docs;

          return ListView.builder(
            itemCount: savedPlans.length,
            itemBuilder: (context, index) {
              var planData = savedPlans[index];
              String plan = planData['plan'];
              DateTime date = planData['dateGenerated'].toDate();

              return ListTile(
                title: Text(
                    'Plan Generated on ${DateFormat.yMMMd().format(date)}'),
                subtitle:
                    Text(plan, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeneratedPlanScreen(plan: plan),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
