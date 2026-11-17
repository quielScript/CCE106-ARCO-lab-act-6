import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_feed/demo_auth.dart';
import 'package:social_media_feed/main.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  setUp(() {
    HttpOverrides.global = _TestHttpOverrides();
    DemoAuth.logout();
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
  });

  testWidgets('App starts at LoginScreen and allows admin login to MainScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentApp());

    // Expect Login screen elements
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Enter admin credentials
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'admin123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Expect Home screen on MainScreen
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Welcome, Student!'), findsOneWidget);
    expect(DemoAuth.currentUsername, 'admin');
  });

  testWidgets('Navigate to Social Media tab and verify sample posts and like',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentApp());

    // Login
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Tap Social Media navigation destination via its icon
    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    // Verify sample posts
    expect(find.text('Enjoying the sunny weather!'), findsOneWidget);
    expect(find.text('Just finished a great book!'), findsOneWidget);
    expect(find.text('JohnDoe'), findsOneWidget);
    expect(find.text('JaneSmith'), findsOneWidget);

    // Like first post
    final firstLikeButton = find.widgetWithText(TextButton, 'Like').first;
    await tester.tap(firstLikeButton);
    await tester.pumpAndSettle();

    expect(find.text('Liked'), findsOneWidget);

    // Unlike
    final likedButton = find.widgetWithText(TextButton, 'Liked').first;
    await tester.tap(likedButton);
    await tester.pumpAndSettle();

    expect(find.text('Liked'), findsNothing);
  });

  testWidgets('Add a comment to a post', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentApp());

    // Login
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Switch to Social Media
    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    expect(find.text('0 Comments'), findsWidgets);

    // Add comment to the first post
    final commentField =
        find.widgetWithText(TextField, 'Add a comment...').first;
    await tester.enterText(commentField, 'Awesome photo!');
    final sendButton = find.byTooltip('Send comment').first;
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text('Awesome photo!'), findsOneWidget);
    expect(find.text('1 Comments'), findsOneWidget);
  });

  testWidgets('Switch tabs without losing feed state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentApp());

    // Login
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Switch to Social Media
    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    // Like a post
    await tester.tap(find.widgetWithText(TextButton, 'Like').first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    // Switch back to Home
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Student!'), findsOneWidget);

    // Switch back to Social Media
    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    // Verify liked state persisted
    expect(find.text('Liked'), findsOneWidget);
  });

  testWidgets('Create a new post through the bottom sheet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentApp());

    // Login
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Switch to Social Media
    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    // Tap FAB '+'
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    // Check Create Post sheet appears
    expect(find.text('Create Post'), findsOneWidget);

    // Enter caption and image URL
    await tester.enterText(find.widgetWithText(TextField, 'Caption'),
        'My first Flutter social media post!');
    await tester.enterText(find.widgetWithText(TextField, 'Image URL'),
        'https://picsum.photos/id/20/600/400');

    // Submit post
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify post appears at top with username admin
    expect(find.text('My first Flutter social media post!'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);
  });

  testWidgets('Register new user and verify login and logout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentApp());

    // Go to Register
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    // Fill registration
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'johndoe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'secret123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Back at Login
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Login with new credentials
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'johndoe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(DemoAuth.currentUsername, 'johndoe');

    // Navigate to Profile
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('johndoe'), findsOneWidget);

    // Tap Logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Back at LoginScreen
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(DemoAuth.currentUsername, isNull);
  });
}
