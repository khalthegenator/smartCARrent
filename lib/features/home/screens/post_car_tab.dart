import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/theme_service.dart';

class PostCarTab extends StatefulWidget {
  const PostCarTab({super.key});

  @override
  State<PostCarTab> createState() => _PostCarTabState();
}

class _PostCarTabState extends State<PostCarTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker(); // Temporarily disabled
  String _selectedListingType = 'Rental'; // Default to Rental

  String _selectedType = 'Sedan';
  String _selectedTransmission = 'Manual';
  String _selectedFuel = 'Petrol';
  String _selectedCondition = 'Excellent';
  String _selectedLocation = 'Dar es Salaam';
  String _selectedRentalDuration = 'Daily'; // New: Rental duration option
  List<String> _images = [];
  bool _isLoading = false;
  bool _formSubmitted = false;
  bool _isEditMode = false; // New: Track if we're editing
  String? _editingCarId; // New: ID of car being edited

  @override
  void initState() {
    super.initState();
    ThemeService().addListener(_onThemeChanged);
    _checkForEditMode();
  }

  void _checkForEditMode() async {
    // Check if we're in edit mode - simplified for now
    // TODO: Implement proper URL parameter parsing using GoRouter
    print('PostCarTab: Checking edit mode...');

    // For now, we'll just check if there are any query parameters
    // This is a temporary fix - the full implementation would use GoRouter's state
    setState(() {
      _isEditMode = false; // Default to create mode
      _editingCarId = null;
    });
  }

  @override
  void dispose() {
    ThemeService().removeListener(_onThemeChanged);
    _titleController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  String _getPriceLabel() {
    if (_selectedListingType == 'Sell') {
      return 'Selling Price (TSh) *';
    }

    switch (_selectedRentalDuration) {
      case 'Daily':
        return 'Daily Rental Price (TSh) *';
      case 'Weekly':
        return 'Weekly Rental Price (TSh) *';
      case 'Monthly':
        return 'Monthly Rental Price (TSh) *';
      case 'Custom':
        return 'Base Rental Price (TSh) *';
      default:
        return 'Daily Rental Price (TSh) *';
    }
  }

  String _getPriceHint() {
    if (_selectedListingType == 'Sell') {
      return 'e.g., 5000000';
    }

    switch (_selectedRentalDuration) {
      case 'Daily':
        return 'e.g., 50000 per day';
      case 'Weekly':
        return 'e.g., 300000 per week';
      case 'Monthly':
        return 'e.g., 1000000 per month';
      case 'Custom':
        return 'e.g., 50000 (base price for custom duration)';
      default:
        return 'e.g., 50000 per day';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService().isDarkMode
          ? AppTheme.darkScaffoldBackground
          : AppTheme.lightScaffoldBackground,
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          print(
              '🔍 POST TAB DEBUG: BlocListener received state: ${state.runtimeType}');
          if (state is CarPosting) {
            print('✅ POST TAB DEBUG: Received CarPosting state');
            setState(() {
              _isLoading = true;
            });
          } else if (state is CarPosted) {
            print('✅ POST TAB DEBUG: Received CarPosted state');
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditMode
                    ? 'Car updated successfully!'
                    : 'Car posted successfully!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _clearForm();
            setState(() {
              _formSubmitted = false;
            });
            // Navigate to My Cars tab
            print('🚀 POST TAB DEBUG: Navigating to My Cars tab');
            context.go('/dashboard?tab=1');
          } else if (state is HomeError) {
            print(
                '❌ POST TAB DEBUG: Received HomeError state: ${state.message}');
            setState(() {
              _isLoading = false;
              _formSubmitted = false;
            });
            // Completely remove error notifications
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Your Car' : 'Post Your Car',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details below to list your car',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildCarDetailsSection(),
                const SizedBox(height: 24),
                _buildPricingSection(),
                const SizedBox(height: 24),
                _buildImagesSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Car Title *',
              labelStyle: TextStyle(color: ThemeService().textColor),
              hintStyle: TextStyle(color: ThemeService().secondaryTextColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().primaryColor),
              ),
              hintText: 'e.g., Toyota Corolla 2020',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a car title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _modelController,
            decoration: InputDecoration(
              labelText: 'Car Model *',
              labelStyle: TextStyle(color: ThemeService().textColor),
              hintStyle: TextStyle(color: ThemeService().secondaryTextColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().primaryColor),
              ),
              hintText: 'e.g., Toyota Corolla',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the car model';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(
                    labelText: 'Year *',
                    hintText: 'e.g., 2020',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the year';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Car Type *',
                    labelStyle: TextStyle(color: ThemeService().textColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ThemeService().borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ThemeService().borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: ThemeService().primaryColor),
                    ),
                  ),
                  dropdownColor: ThemeService().cardColor,
                  style: TextStyle(color: ThemeService().textColor),
                  items: [
                    'Sedan',
                    'SUV',
                    'Hatchback',
                    'Truck',
                    'Van',
                    'Coupe',
                    'Convertible'
                  ].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Car Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description *',
              hintText: 'Describe your car\'s features, condition, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTransmission,
                  decoration: InputDecoration(
                    labelText: 'Transmission *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Manual', 'Automatic'].map((transmission) {
                    return DropdownMenuItem(
                        value: transmission, child: Text(transmission));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTransmission = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFuel,
                  decoration: InputDecoration(
                    labelText: 'Fuel Type *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Petrol', 'Diesel', 'Hybrid', 'Electric'].map((fuel) {
                    return DropdownMenuItem(value: fuel, child: Text(fuel));
                  }).toList(),
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
                child: DropdownButtonFormField<String>(
                  value: _selectedCondition,
                  decoration: InputDecoration(
                    labelText: 'Condition *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Excellent', 'Good', 'Fair', 'Poor'].map((condition) {
                    return DropdownMenuItem(
                        value: condition, child: Text(condition));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCondition = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: 'Location *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    'Dar es Salaam',
                    'Arusha',
                    'Mwanza',
                    'Dodoma',
                    'Mbeya',
                    'Tanga',
                    'Morogoro'
                  ].map((location) {
                    return DropdownMenuItem(
                        value: location, child: Text(location));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value!;
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
                child: TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: 'Color *',
                    hintText: 'e.g., Silver',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the color';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _mileageController,
                  decoration: InputDecoration(
                    labelText: 'Mileage (km) *',
                    hintText: 'e.g., 50000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the mileage';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid mileage';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeService().textColor,
            ),
          ),
          const SizedBox(height: 16),
          // Listing Type Selection
          DropdownButtonFormField<String>(
            value: _selectedListingType,
            decoration: InputDecoration(
              labelText: 'Listing Type *',
              labelStyle: TextStyle(color: ThemeService().textColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().primaryColor),
              ),
            ),
            dropdownColor: ThemeService().cardColor,
            style: TextStyle(color: ThemeService().textColor),
            items: ['Rental', 'Sell'].map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedListingType = value!;
              });
            },
          ),
          // Rental Duration Options (only show for rental)
          if (_selectedListingType == 'Rental') ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRentalDuration,
              decoration: InputDecoration(
                labelText: 'Rental Duration Options *',
                labelStyle: TextStyle(color: ThemeService().textColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ThemeService().borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ThemeService().borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ThemeService().primaryColor),
                ),
              ),
              dropdownColor: ThemeService().cardColor,
              style: TextStyle(color: ThemeService().textColor),
              items: ['Daily', 'Weekly', 'Monthly', 'Custom'].map((duration) {
                return DropdownMenuItem(value: duration, child: Text(duration));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRentalDuration = value!;
                });
              },
            ),
            if (_selectedRentalDuration == 'Custom') ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Custom Duration Description *',
                  labelStyle: TextStyle(color: ThemeService().textColor),
                  hintStyle:
                      TextStyle(color: ThemeService().secondaryTextColor),
                  hintText: 'e.g., 3 days, 2 weeks, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: ThemeService().borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: ThemeService().borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: ThemeService().primaryColor),
                  ),
                ),
                style: TextStyle(color: ThemeService().textColor),
                validator: (value) {
                  if (_selectedRentalDuration == 'Custom' &&
                      (value == null || value.isEmpty)) {
                    return 'Please specify custom duration';
                  }
                  return null;
                },
              ),
            ],
          ],
          const SizedBox(height: 16),
          // Price field based on listing type
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: _getPriceLabel(),
              labelStyle: TextStyle(color: ThemeService().textColor),
              hintStyle: TextStyle(color: ThemeService().secondaryTextColor),
              hintText: _getPriceHint(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeService().primaryColor),
              ),
              prefixText: 'TSh ',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _selectedListingType == 'Rental'
                    ? 'Please enter the rental price'
                    : 'Please enter the selling price';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Car Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add photos of your car (minimum 1, maximum 10)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: Hero(
                      tag: 'add_image_btn',
                      child: IconButton(
                        onPressed: _addImage,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImageWidget(_images[index]),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitCar,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeService().primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            minimumSize: const Size(0, 56),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_isEditMode ? 'Updating Car...' : 'Posting Car...'),
                  ],
                )
              : Text(
                  _isEditMode ? 'Update Car' : 'Post Car',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: ThemeService().surfaceColor,
            child: Icon(
              Icons.broken_image,
              color: ThemeService().secondaryTextColor,
            ),
          );
        },
      );
    } else if (imagePath.startsWith('blob:')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: ThemeService().surfaceColor,
            child: Icon(
              Icons.broken_image,
              color: ThemeService().secondaryTextColor,
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: ThemeService().surfaceColor,
            child: Icon(
              Icons.broken_image,
              color: ThemeService().secondaryTextColor,
            ),
          );
        },
      );
    }
  }

  void _addImage() async {
    try {
      // Show options to user
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeService().cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt,
                      color: ThemeService().primaryColor),
                  title: Text('Camera',
                      style: TextStyle(color: ThemeService().textColor)),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library,
                      color: ThemeService().primaryColor),
                  title: Text('Gallery',
                      style: TextStyle(color: ThemeService().textColor)),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 768,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _images.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _submitCar() async {
    print('🔍 POST BUTTON DEBUG: Post car button pressed');
    print('🔍 POST BUTTON DEBUG: Form key state: ${_formKey.currentState}');
    print('🔍 POST BUTTON DEBUG: Is loading: $_isLoading');
    print('🔍 POST BUTTON DEBUG: Form submitted: $_formSubmitted');

    if (!_formKey.currentState!.validate()) {
      print('❌ POST BUTTON DEBUG: Form validation failed');
      return;
    }

    final currentUser = await AuthService.getCurrentUser();
    final role = (currentUser?['role'] ?? '').toString().toLowerCase();
    final dealerStatus =
        (currentUser?['dealer_status'] ?? 'pending').toString().toLowerCase();

    if (role == 'dealer' && dealerStatus != 'approved') {
      if (!mounted) return;
      await _showAuthorizationDialog();
      return;
    }

    print('✅ POST BUTTON DEBUG: Form validation passed');
    setState(() {
      _isLoading = true;
      _formSubmitted = true;
    });
    print(
        '🔍 POST BUTTON DEBUG: State updated - Loading: $_isLoading, Submitted: $_formSubmitted');

    print('PostCarTab: About to add event to HomeBloc');
    print('PostCarTab: Is edit mode: $_isEditMode');

    if (_isEditMode && _editingCarId != null) {
      context.read<HomeBloc>().add(UpdateCarEvent(
            carId: _editingCarId!,
            carData: {
              'title': _titleController.text.trim(),
              'model': _modelController.text.trim(),
              'year': _yearController.text.trim(),
              'price': _priceController.text.trim(),
              'description': _descriptionController.text.trim(),
              'type': _selectedType,
              'transmission': _selectedTransmission,
              'fuel': _selectedFuel,
              'condition': _selectedCondition,
              'location': _selectedLocation,
              'color': _colorController.text.trim(),
              'mileage': _mileageController.text.trim(),
              'images': _images,
              'listing_type': _selectedListingType,
              'rental_duration': _selectedRentalDuration,
            },
          ));
      print('PostCarTab: UpdateCarEvent added');
    } else {
      context.read<HomeBloc>().add(PostCarEvent(
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
            images: _images,
            listingType: _selectedListingType,
            rentalDuration: _selectedRentalDuration,
          ));
      print('PostCarTab: PostCarEvent added');
    }
    print('✅ POST BUTTON DEBUG: PostCarEvent added to HomeBloc successfully');
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
                        'You must be approved by the admin before posting vehicles.'),
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
                                  content: Text(
                                      'Please fill in the required fields.')),
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

  void _clearForm() {
    _titleController.clear();
    _modelController.clear();
    _yearController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _colorController.clear();
    _mileageController.clear();
    setState(() {
      _selectedType = 'Sedan';
      _selectedTransmission = 'Manual';
      _selectedFuel = 'Petrol';
      _selectedCondition = 'Excellent';
      _selectedLocation = 'Dar es Salaam';
      _images = [];
    });
  }
}
