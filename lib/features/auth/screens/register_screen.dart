import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dealerNameController = TextEditingController();
  String _selectedLocation = 'Dar es Salaam';
  String _selectedRole = 'customer';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _dealerNameController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      context.read<AuthBloc>().add(RegisterUserEvent(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber:
                '+255${_phoneNumberController.text.replaceAll(RegExp(r'[^\d]'), '')}',
            location: _selectedLocation,
            role: _selectedRole,
            dealerName: _selectedRole == 'dealer'
                ? _dealerNameController.text.trim()
                : null,
          ));
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryLight,
              Color(0xFFF8FAFB),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthRegistered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registration successful! Please login.'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                context.go('/login');
              } else if (state is AuthError) {
                final message = state.message
                    .replaceFirst('Exception: ', '')
                    .replaceFirst('Registration failed: ', '')
                    .trim();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      message.toLowerCase().contains('already registered') ||
                              message.toLowerCase().contains('already used') ||
                              message.toLowerCase().contains('already exists')
                          ? 'This email or phone number is already registered. Please use a different one.'
                          : 'Registration failed: $message',
                    ),
                    backgroundColor: AppTheme.errorColor,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // Logo and Title
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const AppLogo(size: 90, showText: true),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Create Your SmartCARrent Account',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Create a customer account to rent vehicles, buy vehicles, contact dealers, leave reviews and manage your transactions.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textPrimary,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Registration Form
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Personal Information',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Full Name Field
                                    const Text(
                                      'Full Name',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _fullNameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your full name',
                                        prefixIcon: Icon(Icons.person_outline),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your full name';
                                        }
                                        if (value.length < 3) {
                                          return 'Name must be at least 3 characters';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Email Field
                                    const Text(
                                      'Email Address',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your email',
                                        prefixIcon: Icon(Icons.email_outlined),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Phone Number Field
                                    const Text(
                                      'Phone Number',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _phoneNumberController,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        hintText: '07xxxxxxxx',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                        prefixText: '+255 ',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        final cleanNumber = value.replaceAll(
                                            RegExp(r'[^\d]'), '');
                                        if (cleanNumber.length != 9) {
                                          return 'Please enter a valid Tanzanian phone number';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Role Selection
                                    Text(
                                      'Account type',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ChoiceChip(
                                            label: const Text('Customer'),
                                            selected:
                                                _selectedRole == 'customer',
                                            onSelected: (_) {
                                              setState(() {
                                                _selectedRole = 'customer';
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ChoiceChip(
                                            label: const Text('Dealer'),
                                            selected: _selectedRole == 'dealer',
                                            onSelected: (_) {
                                              setState(() {
                                                _selectedRole = 'dealer';
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    if (_selectedRole == 'dealer') ...[
                                      const Text(
                                        'Dealership Name',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _dealerNameController,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Enter your dealership name',
                                          prefixIcon:
                                              Icon(Icons.business_outlined),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                        ),
                                        validator: (value) {
                                          if (_selectedRole == 'dealer' &&
                                              (value == null ||
                                                  value.isEmpty)) {
                                            return 'Please enter your dealership name';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Location Dropdown
                                    const Text(
                                      'Location',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedLocation,
                                      decoration: const InputDecoration(
                                        hintText: 'Select your location',
                                        prefixIcon:
                                            Icon(Icons.location_on_outlined),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Dar es Salaam',
                                            child: Text('Dar es Salaam')),
                                        DropdownMenuItem(
                                            value: 'Arusha',
                                            child: Text('Arusha')),
                                        DropdownMenuItem(
                                            value: 'Mwanza',
                                            child: Text('Mwanza')),
                                        DropdownMenuItem(
                                            value: 'Dodoma',
                                            child: Text('Dodoma')),
                                        DropdownMenuItem(
                                            value: 'Tanga',
                                            child: Text('Tanga')),
                                        DropdownMenuItem(
                                            value: 'Mbeya',
                                            child: Text('Mbeya')),
                                        DropdownMenuItem(
                                            value: 'Morogoro',
                                            child: Text('Morogoro')),
                                        DropdownMenuItem(
                                            value: 'Tabora',
                                            child: Text('Tabora')),
                                        DropdownMenuItem(
                                            value: 'Iringa',
                                            child: Text('Iringa')),
                                        DropdownMenuItem(
                                            value: 'Kigoma',
                                            child: Text('Kigoma')),
                                        DropdownMenuItem(
                                            value: 'Moshi',
                                            child: Text('Moshi')),
                                        DropdownMenuItem(
                                            value: 'Songea',
                                            child: Text('Songea')),
                                        DropdownMenuItem(
                                            value: 'Sumbawanga',
                                            child: Text('Sumbawanga')),
                                        DropdownMenuItem(
                                            value: 'Bukoba',
                                            child: Text('Bukoba')),
                                        DropdownMenuItem(
                                            value: 'Kagera',
                                            child: Text('Kagera')),
                                        DropdownMenuItem(
                                            value: 'Manyara',
                                            child: Text('Manyara')),
                                        DropdownMenuItem(
                                            value: 'Lindi',
                                            child: Text('Lindi')),
                                        DropdownMenuItem(
                                            value: 'Mara', child: Text('Mara')),
                                        DropdownMenuItem(
                                            value: 'Pwani',
                                            child: Text('Pwani')),
                                        DropdownMenuItem(
                                            value: 'Ruvuma',
                                            child: Text('Ruvuma')),
                                        DropdownMenuItem(
                                            value: 'Zanzibar',
                                            child: Text('Zanzibar')),
                                      ],
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedLocation = newValue!;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select your location';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    Text(
                                      'Security',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Password Field
                                    const Text(
                                      'Password',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        hintText: 'Create a strong password',
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() => _obscurePassword =
                                                !_obscurePassword);
                                          },
                                        ),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Confirm Password Field
                                    const Text(
                                      'Confirm Password',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      decoration: InputDecoration(
                                        hintText: 'Re-enter your password',
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() =>
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword);
                                          },
                                        ),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Terms and Conditions
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _agreeToTerms,
                                          onChanged: (value) {
                                            setState(() {
                                              _agreeToTerms = value!;
                                            });
                                          },
                                          activeColor: AppTheme.primaryColor,
                                        ),
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'I agree to the ',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.textSecondary),
                                              children: const [
                                                TextSpan(
                                                  text: 'Terms and Conditions',
                                                  style: TextStyle(
                                                    color:
                                                        AppTheme.primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                TextSpan(text: ' and '),
                                                TextSpan(
                                                  text: 'Privacy Policy',
                                                  style: TextStyle(
                                                    color:
                                                        AppTheme.primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // Register Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _register,
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'Create Account',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Login Link
                                    Row(
                                      children: [
                                        Text(
                                          'Already have an account? ',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.go('/login');
                                          },
                                          child: const Text(
                                            'Login',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
