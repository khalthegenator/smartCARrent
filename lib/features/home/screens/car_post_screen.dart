import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';

class CarPostScreen extends StatefulWidget {
  const CarPostScreen({super.key});

  @override
  State<CarPostScreen> createState() => _CarPostScreenState();
}

class _CarPostScreenState extends State<CarPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _titleController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  final _colorController = TextEditingController();

  String _selectedType = 'Sedan';
  String _selectedTransmission = 'Manual';
  String _selectedFuel = 'Petrol';
  String _selectedCondition = 'Used';
  String _selectedLocation = 'Dar es Salaam';
  final List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _statusLoading = true;
  String _dealerStatus = 'pending';
  String _authorizationMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDealerAuthorizationStatus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      setState(() {
        _selectedImages.addAll(images.take(5 - _selectedImages.length));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _loadDealerAuthorizationStatus() async {
    final result = await AuthService.getDealerAuthorizationStatus();
    if (!mounted) return;
    setState(() {
      _dealerStatus =
          (result['dealerStatus'] ?? 'pending').toString().toLowerCase();
      _authorizationMessage = result['message']?.toString() ?? '';
      _statusLoading = false;
    });
  }

  Future<void> _submitCar() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = await AuthService.getCurrentUser();
      final role = (currentUser?['role'] ?? '').toString().toLowerCase();
      final dealerStatus =
          (currentUser?['dealer_status'] ?? 'pending').toString().toLowerCase();

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again to post a vehicle.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (role == 'dealer' && dealerStatus != 'approved') {
        await _showAuthorizationDialog();
        return;
      }

      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload images (mock) and collect URLs
        final uploadedUrls = <String>[];
        for (final file in _selectedImages) {
          final res = await DatabaseService.uploadImage(file.path);
          if (res['status'] == 'success' && res['image_url'] != null) {
            uploadedUrls.add(res['image_url'] as String);
          }
        }

        // Post car using current authenticated user
        await AuthService.postCar(
          title: _titleController.text.trim(),
          model: _modelController.text.trim(),
          year: _yearController.text.trim(),
          price: _priceController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          transmission: _selectedTransmission,
          fuel: _selectedFuel,
          condition: _selectedCondition,
          location: _selectedLocation,
          color: _colorController.text.trim(),
          mileage: _mileageController.text.trim(),
          images: uploadedUrls,
          listingType: 'rental',
          rentalDuration: 'daily',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Car posted successfully!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        setState(() {
          _selectedImages.clear();
        });

        // Navigate back
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post car: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAuthorizationDialog() async {
    final businessNameController = TextEditingController();
    final licenseController = TextEditingController();
    final taxIdController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final notesController = TextEditingController();
    bool isSubmitting = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Dealer authorization required'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'You must be approved by the admin before posting vehicles. Submit your business details below.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: businessNameController,
                      decoration:
                          const InputDecoration(labelText: 'Business name *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: licenseController,
                      decoration:
                          const InputDecoration(labelText: 'License number *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: taxIdController,
                      decoration: const InputDecoration(labelText: 'Tax ID'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                          labelText: 'Business address *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Phone number *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration:
                          const InputDecoration(labelText: 'Additional notes'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (businessNameController.text.trim().isEmpty ||
                              licenseController.text.trim().isEmpty ||
                              addressController.text.trim().isEmpty ||
                              phoneController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please fill in the required fields.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          final currentUser =
                              await AuthService.getCurrentUser();
                          final result =
                              await DatabaseService.submitDealerAuthorization(
                            userId: currentUser?['id']?.toString() ?? '',
                            businessName: businessNameController.text.trim(),
                            licenseNumber: licenseController.text.trim(),
                            taxId: taxIdController.text.trim(),
                            address: addressController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                            notes: notesController.text.trim(),
                          );
                          if (!mounted) return;
                          Navigator.of(dialogContext).pop(result);
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit request'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(result['message']?.toString() ?? 'Request submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService().isDarkMode
          ? AppTheme.darkScaffoldBackground
          : AppTheme.lightScaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Post Your Car',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: TextButton(
                onPressed: _isLoading ? null : _submitCar,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(0, 0),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildProgressStep(
                          'Images', _selectedImages.isNotEmpty, 1),
                    ),
                    Expanded(
                      child: _buildProgressStep(
                          'Details', _titleController.text.isNotEmpty, 2),
                    ),
                    Expanded(
                      child: _buildProgressStep(
                          'Pricing', _priceController.text.isNotEmpty, 3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: _dealerStatus == 'approved'
                    ? AppTheme.successColor.withAlpha(20)
                    : _dealerStatus == 'rejected'
                        ? Colors.redAccent.withAlpha(20)
                        : AppTheme.primaryColor.withAlpha(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLoading
                            ? 'Checking authorization status...'
                            : _dealerStatus == 'approved'
                                ? 'Dealer approved'
                                : _dealerStatus == 'rejected'
                                    ? 'Authorization rejected'
                                    : 'Authorization pending',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _dealerStatus == 'approved'
                              ? Colors.green.shade700
                              : _dealerStatus == 'rejected'
                                  ? Colors.red.shade700
                                  : AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusLoading
                            ? 'Loading your dealer approval state.'
                            : _dealerStatus == 'approved'
                                ? 'You are authorized and may publish cars.'
                                : _dealerStatus == 'rejected'
                                    ? 'Your application was rejected. Update your documents and resubmit.'
                                    : 'Your request is under review by the admin.',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      if (_authorizationMessage.isNotEmpty &&
                          !_statusLoading) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Admin note: $_authorizationMessage',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                      if (!_statusLoading && _dealerStatus != 'approved')
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ElevatedButton(
                            onPressed: _showAuthorizationDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                            child: Text(
                              _dealerStatus == 'pending'
                                  ? 'Update request'
                                  : 'Submit request',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Image Upload Section
              _buildSectionCard(
                title: 'Car Images',
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _selectedImages.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add car photos',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Add up to 5 photos',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _pickImages,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Choose Photos'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.secondaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _selectedImages[0].path,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Row(
                                    children: [
                                      if (_selectedImages.length < 5)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.add,
                                                color: Colors.white, size: 20),
                                            onPressed: _pickImages,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.white, size: 20),
                                          onPressed: () => _removeImage(0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_selectedImages.length}/5',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (_selectedImages.length > 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _selectedImages[index].path,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image,
                                            size: 24,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (index > 0)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(12),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Basic Information
              _buildSectionCard(
                title: 'Basic Information',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _titleController,
                            label: 'Car Title*',
                            hint: 'e.g., Toyota Land Cruiser 2022',
                            icon: Icons.title,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _yearController,
                            label: 'Year*',
                            hint: 'e.g., 2022',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _modelController,
                            label: 'Model*',
                            hint: 'e.g., Land Cruiser',
                            icon: Icons.directions_car,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _colorController,
                            label: 'Color*',
                            hint: 'e.g., Silver',
                            icon: Icons.palette,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Car Type*',
                            value: _selectedType,
                            items: AppConstants.carTypes,
                            icon: Icons.category,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Condition*',
                            value: _selectedCondition,
                            items: ['New', 'Used', 'Refurbished'],
                            icon: Icons.info,
                            onChanged: (value) {
                              setState(() {
                                _selectedCondition = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Technical Details
              _buildSectionCard(
                title: 'Technical Details',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Transmission*',
                            value: _selectedTransmission,
                            items: ['Manual', 'Automatic'],
                            icon: Icons.settings,
                            onChanged: (value) {
                              setState(() {
                                _selectedTransmission = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Fuel Type*',
                            value: _selectedFuel,
                            items: ['Petrol', 'Diesel', 'Hybrid', 'Electric'],
                            icon: Icons.local_gas_station,
                            onChanged: (value) {
                              setState(() {
                                _selectedFuel = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _mileageController,
                            label: 'Mileage (km)',
                            hint: 'e.g., 50000',
                            icon: Icons.speed,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Location*',
                            value: _selectedLocation,
                            items: AppConstants.tanzanianCities,
                            icon: Icons.location_on,
                            onChanged: (value) {
                              setState(() {
                                _selectedLocation = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pricing
              _buildSectionCard(
                title: 'Pricing',
                child: _buildTextField(
                  controller: _priceController,
                  label: 'Price (TZS)*',
                  hint: 'e.g., 120000',
                  icon: Icons.money,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 20),

              // Description
              _buildSectionCard(
                title: 'Description',
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Car Description*',
                    hintText:
                        'Describe your car, features, condition, maintenance history, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    if (value.length < 20) {
                      return 'Description must be at least 20 characters';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Posting...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.post_add),
                            SizedBox(width: 8),
                            Text(
                              'Post Car',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(String title, bool completed, int step) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    step.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: completed ? const Color(0xFF2E7D32) : Colors.grey,
            fontWeight: completed ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
    );
  }
}
