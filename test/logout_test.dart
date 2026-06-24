import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  // Mock FirebaseAuth for testing
  late MockFirebaseAuth mockAuth;

  setUpAll(() {
    // Initialise MockFirebaseAuth
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        email: 'james@gmail.com',
        displayName: 'James',
        uid: '12345',
      ),
    );
  });

  // Test Firebase Initialisation (Mocked)
  test('Test Firebase Initialisation (Mocked)', () {
    // Assert: This is mocked but it is similar to Firebase being initialised
    expect(mockAuth.app != null, true);
  });

  // Test Logout functionality
  test('Logout functionality', () async {
    // Arrange: Ensure user is logged in
    await mockAuth.signInWithEmailAndPassword(
      email: 'james@gmail.com',
      password: 'password123',
    );

    // Act: Log out the user
    await mockAuth.signOut();

    // Assert: Verify the user is logged out
    expect(mockAuth.currentUser, isNull);
  });
}
