import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<String> getUserRole(String uid) async {
  DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(uid).get();

  if (snapshot.exists && snapshot.data() != null) {
    return snapshot.data()!['role']; 
  } else {
    throw Exception('User role not found');
  }
}

// Made changes to user profile data schema
Future<Map<String, dynamic>> getUserData(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(uid).get();

    if (snapshot.exists && snapshot.data() != null) {
      return snapshot.data()!; // Return full user data
    } else {
      throw Exception('User data not found');
    }
  }

    // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(uid).update(updatedData);
    } catch (e) {
      throw Exception('Error updating user data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVenues() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('venues').get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, 
          'name': doc['name'],
          'venue_desc': doc['venue_desc'],
          'service_included': doc['service_included'],
          'rating': doc['rating'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching venues: $e');
    }
  }

  // Fetch venue details by ID
  Future<Map<String, dynamic>?> fetchVenueById(String venueId) async {
    try {
      DocumentSnapshot snapshot = 
          await _firestore.collection('venues').doc(venueId).get();

      if (snapshot.exists) {
        return {
          'id': snapshot.id,
          'name': snapshot['name'],
          'venue_desc': snapshot['venue_desc'],
          'service_included': snapshot['service_included'],
          'rating': snapshot['rating'],
        };
      } else {
        throw Exception('Venue not found');
      }
    } catch (e) {
      throw Exception('Error fetching venue details: $e');
    }
  }

  

  // Add Venue Method
  Future<void> addVenue({
    required String name,
    required String venueDesc,
    required String serviceIncluded,
  }) async {
    try {
      await _firestore.collection('venues').add({
        'name': name,
        'venue_desc': venueDesc,
        'service_included': serviceIncluded,
        'rating': '0.0', // Default rating when a new venue is added
      });
    } catch (e) {
      throw Exception('Error adding venue: $e');
    }
  }

  Future<void> updateVenue(String venueId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('venues').doc(venueId).update(updatedData);
      print('Venue updated successfully');
    } catch (e) {
      throw Exception('Error updating venue: $e');
    }
  }

  Future<void> deleteVenue(String venueId) async {
  try {
    await _firestore.collection('venues').doc(venueId).delete();
    print('Venue deleted successfully');
  } catch (e) {
    throw Exception('Error deleting venue: $e');
  }
}


   Future<void> addBooking({
    required String bookingDate,
    required String clientId,
    required String venueId,
    required String venueName,
    required DateTime requestDate,
    required String status,
  }) async {
    try {
      await _firestore.collection('bookings').add({
        'booking_date': bookingDate,
        'client_id': clientId,
        'venue_id': venueId,
        'venue_name': venueName,
        'request_date': requestDate,
        'status': status,
      });
    } catch (e) {
      throw Exception('Error adding booking: $e');
    }
  }

    /// Fetch all bookings for a specific client
  Future<List<Map<String, dynamic>>> getClientBookings(String clientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('client_id', isEqualTo: clientId)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, 
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching client bookings: $e');
    }
  }

   Future<List<Map<String, dynamic>>> fetchAllBookings() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('bookings').get();

      // Map each document to a Map<String, dynamic> for easy usage.
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Document ID for reference
          'booking_date': doc['booking_date'],
          'client_id': doc['client_id'],
          'request_date': doc['request_date'],
          'status': doc['status'],
          'venue_id': doc['venue_id'],
          'venue_name': doc['venue_name'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
  try {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': newStatus,
    });
  } catch (e) {
    throw Exception('Error updating booking status: $e');
  }
}

  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }


  Future<String?> fetchClientNameById(String clientId) async {
    try {
      DocumentSnapshot clientSnapshot =
          await _firestore.collection('users').doc(clientId).get();

      if (clientSnapshot.exists) {
        return clientSnapshot['name']; // Assuming the field is 'name'
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching client name: $e');
      return null;
    }
  }

  Future<void> saveWeddingCountdown({
  required String clientId,
  required DateTime countdownDate,
}) async {
  try {
    // Generate an invitation code based on clientId
    final invitationCode = 'INV-${clientId.substring(0, 6).toUpperCase()}';

    // Save countdown and invitation code
    await _firestore.collection('weddingPlans').doc(clientId).set({
      'client_id': clientId,
      'countdown_date': Timestamp.fromDate(countdownDate),
      'invitation_code': invitationCode,
    });
  } catch (e) {
    throw Exception('Error saving wedding countdown: $e');
  }
}


  Future<DateTime?> fetchWeddingCountdown(String clientId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('weddingPlans').doc(clientId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final Timestamp? countdownTimestamp = data['countdown_date'];
        return countdownTimestamp?.toDate();
      }
      return null; // If no countdown date exists
    } catch (e) {
      throw Exception('Error fetching wedding countdown: $e');
    }
  }

   Future<void> updateWeddingPlan({
    required String clientId,
    required String weddingCouple,
    required String weddingVenue,
    required DateTime countdownDate,
  }) async {
    try {
      // Generate an invitation code based on clientId
    final invitationCode = 'WED-${clientId.substring(0, 6).toUpperCase()}';
      await _firestore.collection('weddingPlans').doc(clientId).set({
        'wedding_couple': weddingCouple,
        'wedding_venue': weddingVenue,
        'countdown_date': countdownDate,
        'invitation_code': invitationCode,
      }, SetOptions(merge: true)); // Merge to update existing fields
    } catch (e) {
      throw Exception('Error updating wedding plan: $e');
    }
  }

  Future<Map<String, dynamic>> getWeddingPlan(String clientId) async {
  try {
    final snapshot =
        await _firestore.collection('weddingPlans').doc(clientId).get();

    if (snapshot.exists) {
      return snapshot.data()!;
    } else {
      return {};
    }
  } catch (e) {
    throw Exception('Error fetching wedding plan: $e');
  }
}

 Future<String> addTaskToChecklist({
    required String clientId,
    required String taskName,
    required bool taskStatus,
  }) async {
    try {
      final checklistRef = _firestore
          .collection('weddingPlans')
          .doc(clientId)
          .collection('checklist');

      final taskDoc = await checklistRef.add({
      'task_name': taskName,
      'task_status': taskStatus,
    });

    return taskDoc.id;
    } catch (e) {
      throw Exception('Error adding task to checklist: $e');
    }
  }

Future<Map<String, Map<String, dynamic>>> getChecklist(String clientId) async {
  try {
    final snapshot = await _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('checklist')
        .get();

    return {
      for (var doc in snapshot.docs)
        doc.id: {
          'task_name': doc['task_name'],
          'task_status': doc['task_status'],
        },
    };
  } catch (e) {
    throw Exception('Error fetching checklist: $e');
  }
}


Future<void> updateTaskName({
  required String clientId,
  required String taskId,
  required String newTaskName,
}) async {
  try {
    final checklistRef = _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('checklist');

    await checklistRef.doc(taskId).update({
      'task_name': newTaskName,
    });
  } catch (e) {
    throw Exception('Error updating task name: $e');
  }
}

Future<void> updateTaskStatus({
  required String clientId,
  required String taskId,
  required bool taskStatus,
}) async {
  try {
    final checklistRef = _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('checklist');

    await checklistRef.doc(taskId).update({
      'task_status': taskStatus,
    });
  } catch (e) {
    throw Exception('Error updating task status: $e');
  }
}

Future<void> deleteTaskFromChecklist({
  required String clientId,
  required String taskId,
}) async {
  try {
    await _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('checklist')
        .doc(taskId)
        .delete();
  } catch (e) {
    throw Exception('Error deleting task from checklist: $e');
  }
}

Future<String> addEventToTentative({
  required String clientId,
  required String eventName,
  required String startTime,
  String? description,
}) async {
  try {
    final docRef = _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('tentative');

    await docRef.add({
      'event_name': eventName,
      'start_time': startTime,
      'description': description ?? '',
    });
    return docRef.id;
  } catch (e) {
    throw Exception('Error adding event to tentative: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchTentative(String clientId) async {
  try {
    final snapshot = await _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('tentative')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id, // Firestore document ID
        'event_name': data['event_name'] ?? '',
        'start_time': data['start_time'] ?? '',
        'description': data['description'] ?? '',
      };
    }).toList();
  } catch (e) {
    throw Exception('Error fetching tentative: $e');
  }
}

Future<void> updateEvent({
  required String clientId,
  required String eventId,
  required String eventName,
  required String startTime,
  String? description,
}) async {
  try {
    await _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('tentative')
        .doc(eventId)
        .update({
      'event_name': eventName,
      'start_time': startTime,
      'description': description,
    });
  } catch (e) {
    throw Exception('Error updating event: $e');
  }
}



Future<void> deleteEvent({
  required String clientId,
  required String eventId,
}) async {
  try {
    await _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('tentative')
        .doc(eventId)
        .delete();
  } catch (e) {
    throw Exception('Error deleting event: $e');
  }
}

Future<void> addGuest(
  String clientId,
  String guestName,
  String guestPhone,
  String rsvpStatus,
) async {
  try {
    CollectionReference guests = _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('guests');

    await guests.add({
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'rsvp_status': rsvpStatus, 
    });

    print("Guest added successfully!");
  } catch (e) {
    throw Exception("Error adding guest: $e");
  }
}


Future<List<Map<String, dynamic>>> fetchGuests(String clientId) async {
  try {
    final snapshot = await _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('guests')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id, // Document ID
        'guest_name': data['guest_name'],
        'guest_phone': data['guest_phone'],
        'rsvp_status': data['rsvp_status'],
      };
    }).toList();
  } catch (e) {
    throw Exception("Error fetching guests: $e");
  }
}

Future<void> updateGuest({
  required String clientId,
  required String guestId,
  required String guestName,
  required String guestPhone,
  required String rsvpStatus,
}) async {
  try {
    await _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('guests')
        .doc(guestId)
        .update({
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'rsvp_status': rsvpStatus,
    });
  } catch (e) {
    throw Exception("Error updating guest: $e");
  }
}

Future<void> deleteGuest({
  required String clientId,
  required String guestId,
}) async {
  try {
    await _firestore
        .collection('weddingPlans')
        .doc(clientId)
        .collection('guests')
        .doc(guestId)
        .delete();
  } catch (e) {
    throw Exception("Error deleting guest: $e");
  }
}

Future<bool> validateGuestAndCode({
  required String invitationCode,
  required String phoneNumber,
}) async {
  try {
    // Find the wedding plan with the matching invitation code
    final query = await _firestore
        .collection('weddingPlans')
        .where('invitation_code', isEqualTo: invitationCode)
        .get();

    if (query.docs.isEmpty) {
      return false; // Invitation code does not exist
    }

    final weddingPlanId = query.docs.first.id;

    // Check if the phone number exists in the guest list of this wedding plan
    final guestQuery = await _firestore
        .collection('weddingPlans')
        .doc(weddingPlanId)
        .collection('guests')
        .where('guest_phone', isEqualTo: phoneNumber)
        .get();

    return guestQuery.docs.isNotEmpty; // Return true if guest exists
  } catch (e) {
    throw Exception('Error validating guest and code: $e');
  }
}

Future<Map<String, dynamic>> getWeddingPlanDetails(String invitationCode) async {
  try {
    // Query wedding plan based on the invitation code
    final query = await _firestore
        .collection('weddingPlans')
        .where('invitation_code', isEqualTo: invitationCode)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("Wedding plan not found.");
    }

    return query.docs.first.data();
  } catch (e) {
    throw Exception("Error fetching wedding plan details: $e");
  }
}

Future<void> updateGuestRsvpStatus({
  required String weddingPlanId,
  required String guestPhone,
  required String rsvpStatus,
}) async {
  try {
    final guestQuery = await _firestore
        .collection('weddingPlans')
        .doc(weddingPlanId)
        .collection('guests')
        .where('guest_phone', isEqualTo: guestPhone)
        .get();

    if (guestQuery.docs.isNotEmpty) {
      // Update the RSVP status of the guest
      await guestQuery.docs.first.reference.update({
        'rsvp_status': rsvpStatus,
      });
    } else {
      throw Exception('Guest not found in the wedding plan.');
    }
  } catch (e) {
    throw Exception('Error updating RSVP status: $e');
  }
}

Future<Map<String, dynamic>?> fetchGuestByPhone({
  required String weddingPlanId,
  required String guestPhone,
}) async {
  try {
    final snapshot = await _firestore
        .collection('weddingPlans')
        .doc(weddingPlanId)
        .collection('guests')
        .where('guest_phone', isEqualTo: guestPhone)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    } else {
      return null;
    }
  } catch (e) {
    throw Exception("Error fetching guest by phone: $e");
  }
}

Future<List<Map<String, dynamic>>> fetchVendorsByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection('vendors')
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'role': doc['role'],
          'location': doc['location'],
          'imageUrl': doc['imageUrl'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching vendors: $e');
    }
  }

  // Fetch vendor data
  Future<Map<String, dynamic>> fetchVendorData(String vendorId) async {
    final vendorDoc = await _firestore.collection('vendors').doc(vendorId).get();
    if (!vendorDoc.exists) throw Exception('Vendor not found');
    return vendorDoc.data()!;
  }

  // Fetch gallery images
  Future<List<String>> fetchGalleryImages(String vendorId) async {
    final gallerySnapshot = await _firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('gallery')
        .get();

    return gallerySnapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
  }


}
