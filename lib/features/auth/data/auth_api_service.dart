import 'package:construction_app/core/networks/api_constants.dart';
import 'package:construction_app/core/networks/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthApiService {
  final Dio _dio = DioClient.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Track initialization state
  static bool _isGoogleInitialized = false;

  /// Create or return existing user
  Future<Map<String, dynamic>> loginWithEmail({
    required String name,
    required String email,
  }) async {
    debugPrint(
      "AuthApiService: Attempting login for $email at ${ApiConstants.baseUrl}${ApiConstants.createUser}",
    );
    try {
      final response = await _dio.post(
        ApiConstants.createUser,
        data: {"name": name, "email": email},
      );
      debugPrint("AuthApiService: Response received: ${response.statusCode}");

      if (response.data["status"] == true) {
        final isNew =
            response.statusCode == 201 || (response.data["isNewUser"] ?? false);

        return {
          "userId": response.data["userId"],
          "name": response.data["name"] ?? name,
          "isNewUser": isNew,
          "email": email, // Ensure email is passed back
        };
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      debugPrint(
        "AuthApiService: DioException caught: ${e.type} - ${e.message}",
      );
      String errorMessage = "Login failed";

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Connection timed out. Is the server running?";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Unable to connect to server. Check your connection.";
      } else if (e.response != null) {
        debugPrint("AuthApiService: Server Error Data: ${e.response?.data}");
        errorMessage =
            e.response?.data["message"] ??
            "Server error: ${e.response?.statusCode}";
      } else {
        errorMessage = e.message ?? "Unknown error occurred";
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("AuthApiService: Unexpected error: $e");
      rethrow;
    }
  }

  /// Login with Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      if (!_isGoogleInitialized) {
        try {
          await GoogleSignIn.instance.initialize(
            clientId:
                "549281312315-kulke0e9bev4va46mppugkjuva5cg80i.apps.googleusercontent.com",
          );
          _isGoogleInitialized = true;
        } catch (e) {
          debugPrint("Google Sign In Initialization Error: $e");
          // Proceeding as it might be already initialized
        }
      }

      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      // Note: accessToken is no longer available in GoogleSignInAuthentication in v7+.
      // Firebase Auth works with just idToken for Identity.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Now sync with your backend
        return await loginWithEmail(
          name: user.displayName ?? "Google User",
          email: user.email!,
        );
      } else {
        throw Exception("Failed to retrieve user details from Google");
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.message}");
      throw Exception(e.message ?? "Google Sign-In failed");
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      // If the user canceled, GoogleSignIn just throws.
      // We might want to humanize that message if possible, or just rethrow.
      if (e.toString().contains("canceled") ||
          e.toString().contains("aborted")) {
        throw Exception("Sign in cancelled");
      }
      rethrow;
    }
  }

  /// Update user name
  Future<void> updateUserName({
    required String userId,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateName,
        data: {"userId": userId, "name": name},
      );

      if (response.statusCode != 200) {
        throw Exception(response.data["message"] ?? "Failed to update name");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Update failed");
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      if (_isGoogleInitialized) {
        try {
          await GoogleSignIn.instance.disconnect();
        } catch (e) {
          debugPrint("Google disconnect error: $e");
        }
      } else {
        // Attempt just sign out if initialized state is unknown or just to be safe
        try {
          await GoogleSignIn.instance.signOut();
        } catch (e) {
          // Ignore if not initialized
        }
      }

      await _firebaseAuth.signOut();
      final response = await _dio.post(ApiConstants.logout);

      if (response.statusCode != 200) {
        // Best effort logout
      }
    } on DioException catch (e) {
      // Log error but generally we want to proceed with client-side logout
      debugPrint("Logout API error: ${e.message}");
    }
  }
}
