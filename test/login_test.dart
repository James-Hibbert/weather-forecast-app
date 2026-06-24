import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  //Mocks the firebase
  late MockFirebaseAuth mockAuth;

  setUpAll(() {
    //Initialises the Firebase mock
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        email: 'james@gmail.com',
        displayName: 'James',
        uid: '12345',
      ),
    );
  });

  test('Login with correct credentials', () async {
    // Arrange: Mock login details
    final email = 'james@gmail.com';
    final password = 'password123';

    // Act: Attempt to sign in with email and password
    final userCredential = await mockAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Assert: Check if the user is logged in
    expect(userCredential.user?.email, equals(email));
  });

  test('Test Firebase Initialisation (Mocked)', () {
    // Assert: This is mocked but it is similar to Firebase being initialised
    expect(mockAuth.app != null, true);
  });
}
