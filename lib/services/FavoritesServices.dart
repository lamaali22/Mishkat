import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteLocationsService {
  final CollectionReference membersCollection =
      FirebaseFirestore.instance.collection('Member');

// this mathod is used for testing purpoes until an authenticated user exists
// add a new location to  the list of favorites
  Future<void> saveLocationToFavorites(
    LatLng coord,
    String rID,
    String locName,
    String discp,
  ) async {
    try {
      DocumentSnapshot documentSnapshot =
          await membersCollection.doc('g4molU09kwr4Xz3gX563').get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('listOfFavorites')) {
          List<Map<String, dynamic>> listOfFavorites =
              List<Map<String, dynamic>>.from(data['listOfFavorites']);

          // Check if a map with 'roomID' equals 'rID' already exists
          if (listOfFavorites.any((element) => element['roomID'] == rID)) {
            print("Already exists");
          } else {
            // Add the new map to the 'listOfFavorites' field in Firestore
            await membersCollection
                .doc('g4molU09kwr4Xz3gX563')
                .update({
                  'listOfFavorites': FieldValue.arrayUnion([
                    {
                      'coordinates': GeoPoint(coord.latitude, coord.longitude),
                      'roomID': rID,
                      'locationName': locName,
                      'description': discp,
                    }
                  ])
                })
                .then((value) => print("Location added to favorites"))
                .catchError((error) => print("Failed to add location: $error"));
          }
        } else {
          print('Error: listOfFavorites not found in data.');
        }
      } else {
        print('Error: Document does not exist.');
      }
    } catch (e) {
      print('Error saving location to favorites: $e');
      throw e;
    }
  }

  // this mathod is used for testing purpoes until an authenticated user exists
  // Fetch the list of favorites
  Future<List<Map<String, dynamic>>> fetchListOfFavorites() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Member')
          .doc('g4molU09kwr4Xz3gX563')
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('listOfFavorites')) {
          List<Map<String, dynamic>> listOfFavorites =
              List<Map<String, dynamic>>.from(data['listOfFavorites']);

          return listOfFavorites;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  // this mathod is used for testing purposes until an authenticated user exists
  // Update the location information
  Future<void> saveChanges(String rID, String locName, String descrip) async {
    try {
      DocumentSnapshot documentSnapshot =
          await membersCollection.doc('g4molU09kwr4Xz3gX563').get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('listOfFavorites')) {
          List<Map<String, dynamic>> listOfFavorites =
              List<Map<String, dynamic>>.from(data['listOfFavorites']);

          int indexToUpdate =
              listOfFavorites.indexWhere((element) => element['roomID'] == rID);

          if (indexToUpdate != -1) {
            listOfFavorites[indexToUpdate]['locationName'] = locName;
            listOfFavorites[indexToUpdate]['description'] = descrip;

            await membersCollection
                .doc('g4molU09kwr4Xz3gX563')
                .update({'listOfFavorites': listOfFavorites})
                .then((value) => print("Changes saved successfully"))
                .catchError((error) => print("Failed to save changes: $error"));
          } else {
            print('Error: Map with roomID $rID not found.');
          }
        } else {
          print('Error: listOfFavorites not found in data.');
        }
      } else {
        print('Error: Document does not exist.');
      }
    } catch (e) {
      print('Error saving changes: $e');
      throw e;
    }
  }

// this mathod is used for testing purposes until an authenticated user exists
  // Dlete the location information
  Future<void> deleteLocation(String rID) async {
    try {
      // Assuming 'membersCollection' is the reference to the 'Member' collection
      DocumentSnapshot documentSnapshot =
          await membersCollection.doc('g4molU09kwr4Xz3gX563').get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('listOfFavorites')) {
          List<Map<String, dynamic>> listOfFavorites =
              List<Map<String, dynamic>>.from(data['listOfFavorites']);

          // Remove the map where 'roomID' equals 'rID'
          listOfFavorites.removeWhere((element) => element['roomID'] == rID);

          // Update the 'listOfFavorites' field in Firestore
          await membersCollection
              .doc('g4molU09kwr4Xz3gX563')
              .update({'listOfFavorites': listOfFavorites})
              .then((value) => print("Location deleted successfully"))
              .catchError(
                  (error) => print("Failed to delete location: $error"));
        } else {
          print('Error: listOfFavorites not found in data.');
        }
      } else {
        print('Error: Document does not exist.');
      }
    } catch (e) {
      print('Error deleting location: $e');
      throw e;
    }
  }

// The real method that will be used        <<<--------------------------------------------<<<<<       ****IMPORTANT ***
// add a new location to  the list of favorites
// Future<void> saveLocationToFavorites(
//   LatLng coord,
//   String rID,
//   String locName,
//   String discp,
// ) async {
//   try {
//     // Get the current authenticated user
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       DocumentSnapshot documentSnapshot =
//           await membersCollection.doc(user.uid).get();

//       if (documentSnapshot.exists) {
//         Map<String, dynamic>? data =
//             documentSnapshot.data() as Map<String, dynamic>?;

//         if (data != null && data.containsKey('listOfFavorites')) {
//           List<Map<String, dynamic>> listOfFavorites =
//               List<Map<String, dynamic>>.from(data['listOfFavorites']);

//           // Check if a map with 'roomID' equals 'rID' already exists
//           if (listOfFavorites.any((element) => element['roomID'] == rID)) {
//             print("Already exists");
//           } else {
//             // Add the new map to the 'listOfFavorites' field in Firestore
//             await membersCollection
//                 .doc(user.uid)
//                 .update({
//                   'listOfFavorites': FieldValue.arrayUnion([
//                     {
//                       'coordinates': GeoPoint(coord.latitude, coord.longitude),
//                       'roomID': rID,
//                       'locationName': locName,
//                       'description': discp,
//                     }
//                   ])
//                 })
//                 .then((value) => print("Location added to favorites"))
//                 .catchError((error) => print("Failed to add location: $error"));
//           }
//         } else {
//           print('Error: listOfFavorites not found in data.');
//         }
//       } else {
//         print('Error: Document does not exist.');
//       }
//     } else {
//       print('Error: User not authenticated.');
//     }
//   } catch (e) {
//     print('Error saving location to favorites: $e');
//     throw e;
//   }
// }

// The real method that will be used     <<<--------------------------------------------<<<<<   ****IMPORTANT ***
// Fetch the list of favorites
// Future<List<Map<String, dynamic>>> fetchListOfFavorites() async {
//   try {
//     // Get the current user
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       // Use the user's UID to fetch data
//       DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
//           .collection('Member')
//           .doc(user.uid) // Use user's UID
//           .get();

//       if (documentSnapshot.exists) {
//         Map<String, dynamic>? data =
//             documentSnapshot.data() as Map<String, dynamic>?;

//         if (data != null && data.containsKey('listOfFavorites')) {
//           List<Map<String, dynamic>> listOfFavorites =
//               List<Map<String, dynamic>>.from(data['listOfFavorites']);

//           return listOfFavorites;
//         } else {
//           return [];
//         }
//       } else {
//         return [];
//       }
//     } else {
//       return []; // No authenticated user found
//     }
//   } catch (e) {
//     print('Error fetching data: $e');
//     return [];
//   }
// }

// The real method that will be used     <<<--------------------------------------------<<<<<   ****IMPORTANT ***
// Update the location information
// Future<void> saveChanges(String rID, String locName, String descrip) async {
//   try {
//     // Get the current user ID
//     String? userId = FirebaseAuth.instance.currentUser?.uid;

//     if (userId != null) {
//       DocumentSnapshot documentSnapshot =
//           await membersCollection.doc(userId).get();

//       if (documentSnapshot.exists) {
//         Map<String, dynamic>? data =
//             documentSnapshot.data() as Map<String, dynamic>?;

//         if (data != null && data.containsKey('listOfFavorites')) {
//           List<Map<String, dynamic>> listOfFavorites =
//               List<Map<String, dynamic>>.from(data['listOfFavorites']);

//           int indexToUpdate =
//               listOfFavorites.indexWhere((element) => element['roomID'] == rID);

//           if (indexToUpdate != -1) {
//             listOfFavorites[indexToUpdate]['locationName'] = locName;
//             listOfFavorites[indexToUpdate]['description'] = descrip;

//             await membersCollection
//                 .doc(userId)
//                 .update({'listOfFavorites': listOfFavorites})
//                 .then((value) => print("Changes saved successfully"))
//                 .catchError((error) => print("Failed to save changes: $error"));
//           } else {
//             print('Error: Map with roomID $rID not found.');
//           }
//         } else {
//           print('Error: listOfFavorites not found in data.');
//         }
//       } else {
//         print('Error: Document does not exist.');
//       }
//     } else {
//       print('Error: User not authenticated.');
//     }
//   } catch (e) {
//     print('Error saving changes: $e');
//     throw e;
//   }
// }

// The real method that will be used     <<<--------------------------------------------<<<<<   ****IMPORTANT ***
// Delete the location information
  // Future<void> deleteLocation(String rID) async {
  //   try {
  //     FirebaseAuth _auth = FirebaseAuth.instance;
  //     User? user = _auth.currentUser;

  //     if (user == null) {
  //       print('Error: User not authenticated.');
  //       // Handle the case when the user is not authenticated
  //       return;
  //     }

  //     String authenticatedUserID = user.uid;

  //     // Assuming 'membersCollection' is the reference to the 'Member' collection
  //     DocumentSnapshot documentSnapshot =
  //         await membersCollection.doc(authenticatedUserID).get();

  //     if (documentSnapshot.exists) {
  //       Map<String, dynamic>? data =
  //           documentSnapshot.data() as Map<String, dynamic>?;

  //       if (data != null && data.containsKey('listOfFavorites')) {
  //         List<Map<String, dynamic>> listOfFavorites =
  //             List<Map<String, dynamic>>.from(data['listOfFavorites']);

  //         // Remove the map where 'roomID' equals 'rID'
  //         listOfFavorites.removeWhere((element) => element['roomID'] == rID);

  //         // Update the 'listOfFavorites' field in Firestore
  //         await membersCollection
  //             .doc(authenticatedUserID)
  //             .update({'listOfFavorites': listOfFavorites})
  //             .then((value) => print("Location deleted successfully"))
  //             .catchError(
  //                 (error) => print("Failed to delete location: $error"));
  //       } else {
  //         print('Error: listOfFavorites not found in data.');
  //       }
  //     } else {
  //       print('Error: Document does not exist.');
  //     }
  //   } catch (e) {
  //     print('Error deleting location: $e');
  //     throw e;
  //   }
  // }
}
