// lib/screens/movies_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoviesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Movies")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final data = movies[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: data['imageUrl'] != null
                      ? Image.network(
                          data['imageUrl'],
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.movie, size: 40, color: Colors.redAccent),
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Text("${data['genre'] ?? 'Unknown Genre'}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
