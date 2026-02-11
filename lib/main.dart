import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ============================================================================
// ABSTRACT CLASSES - Define contracts for authentication and validation
// ============================================================================

/// Abstract class defining the contract for authentication services
abstract class AuthenticationService {
  /// Authenticates a user with given credentials
  /// Returns true if authentication is successful, false otherwise
  Future<bool> authenticate(String username, String password);

  /// Logs out the current user
  Future<void> logout();
}

/// Abstract class defining the contract for input validation
abstract class Validator {
  /// Validates the input and returns an error message if invalid
  /// Returns null if the input is valid
  String? validate(String? value);
}

// ============================================================================
// CONCRETE IMPLEMENTATIONS - Implement the abstract contracts
// ============================================================================

/// Concrete implementation of AuthenticationService
/// Simulates authentication using a fake Future delay
class FakeAuthenticationService extends AuthenticationService {
  // Simulated delay duration in seconds
  final int delaySeconds;

  FakeAuthenticationService({this.delaySeconds = 2});

  @override
  Future<bool> authenticate(String username, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: delaySeconds));

    // For demonstration purposes, accept any non-empty credentials
    // In a real app, this would make an API call
    return username.isNotEmpty && password.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    // Simulate logout process
    await Future.delayed(const Duration(seconds: 1));
  }
}

/// Base validator class that implements the Validator interface
abstract class BaseValidator implements Validator {
  final String errorMessage;

  BaseValidator(this.errorMessage);
}

/// Validator for username field - demonstrates inheritance
class UsernameValidator extends BaseValidator {
  UsernameValidator() : super('Please enter your username');

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }
}

/// Validator for password field - demonstrates inheritance
class PasswordValidator extends BaseValidator {
  PasswordValidator() : super('Please enter your password');

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

// ============================================================================
// MODELS - Data classes to represent application entities
// ============================================================================

/// Model class representing user credentials
class UserCredentials {
  final String username;
  final String password;

  UserCredentials({required this.username, required this.password});

  /// Factory method to create credentials from text controllers
  factory UserCredentials.fromControllers({
    required TextEditingController usernameController,
    required TextEditingController passwordController,
  }) {
    return UserCredentials(
      username: usernameController.text,
      password: passwordController.text,
    );
  }

  @override
  String toString() => 'UserCredentials(username: $username)';
}

// ============================================================================
// UI SCREENS
// ============================================================================

/// Login Screen - First page of the application
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for input fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Validators - demonstrating use of inheritance and abstract classes
  final UsernameValidator _usernameValidator = UsernameValidator();
  final PasswordValidator _passwordValidator = PasswordValidator();

  // Authentication service - demonstrating use of abstract class
  final AuthenticationService _authService = FakeAuthenticationService();

  // Loading state
  bool _isLoading = false;

  // Password visibility toggle
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the login button press
  Future<void> _handleLogin() async {
    // Validate form inputs
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Create credentials object from input
    final credentials = UserCredentials.fromControllers(
      usernameController: _usernameController,
      passwordController: _passwordController,
    );

    // Show loading indicator
    setState(() => _isLoading = true);

    try {
      // Attempt authentication using the abstract service
      final isAuthenticated = await _authService.authenticate(
        credentials.username,
        credentials.password,
      );

      // Hide loading indicator
      setState(() => _isLoading = false);

      if (isAuthenticated && mounted) {
        // Navigate to second screen on successful authentication
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecondScreen(username: credentials.username),
          ),
        );
      } else {
        // Show error message on failed authentication
        _showErrorMessage('Login failed. Please try again.');
      }
    } catch (e) {
      // Handle any errors during authentication
      setState(() => _isLoading = false);
      _showErrorMessage('An error occurred: $e');
    }
  }

  /// Shows an error message using SnackBar
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo/icon
                  const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),

                  // Welcome text
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to continue',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Username input field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: _usernameValidator.validate,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password input field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: _passwordValidator.validate,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Login button with loading indicator
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Second Screen - Displayed after successful login
class SecondScreen extends StatelessWidget {
  final String username;

  const SecondScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),

            // Page title
            Text(
              'Second Page',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Welcome message with username
            Text(
              'Welcome, $username!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            // Success message
            Text(
              'You have successfully logged in',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
