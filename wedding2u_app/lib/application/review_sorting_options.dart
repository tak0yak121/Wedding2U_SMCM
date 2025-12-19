// File: wedding2u_app/lib/application/add_review_sorting_options.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String reviewer;
  String comment;
  int rating; // 1-5
  DateTime date;

  Review({
    required this.reviewer,
    required this.comment,
    required this.rating,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewer': reviewer,
      'comment': comment,
      'rating': rating,
      'date': date.toIso8601String(),
    };
  }

  static Review fromMap(Map<String, dynamic> map) {
    return Review(
      reviewer: map['reviewer'],
      comment: map['comment'],
      rating: map['rating'],
      date: DateTime.parse(map['date']),
    );
  }
}

enum SortOption { dateNewest, dateOldest, ratingHighest, ratingLowest }

class ReviewService {
  final CollectionReference reviewsCollection = FirebaseFirestore.instance.collection('reviews');

  Future<void> addReview(Review review) async {
    await reviewsCollection.add(review.toMap());
  }

  Future<List<Review>> getReviews({SortOption option = SortOption.dateNewest}) async {
    Query query = reviewsCollection;

    switch (option) {
      case SortOption.dateNewest:
        query = query.orderBy('date', descending: true);
        break;
      case SortOption.dateOldest:
        query = query.orderBy('date', descending: false);
        break;
      case SortOption.ratingHighest:
        query = query.orderBy('rating', descending: true);
        break;
      case SortOption.ratingLowest:
        query = query.orderBy('rating', descending: false);
        break;
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}

// Example usage
void main() async {
  ReviewService service = ReviewService();

  // Add a review
  await service.addReview(Review(
    reviewer: "Alice",
    comment: "Great venue!",
    rating: 5,
    date: DateTime.now(),
  ));

  // Fetch sorted reviews
  List<Review> reviews = await service.getReviews(option: SortOption.ratingHighest);
  reviews.forEach((r) => print('${r.reviewer} (${r.rating}⭐): ${r.comment}'));
}