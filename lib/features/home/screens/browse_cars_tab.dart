import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car_rent/core/services/theme_service.dart';
import 'package:smart_car_rent/theme/app_theme.dart';
import 'package:smart_car_rent/features/home/bloc/home_bloc.dart';
import 'package:smart_car_rent/features/home/bloc/home_state.dart';
import 'package:smart_car_rent/features/home/bloc/home_event.dart';

class BrowseCarsTab extends StatefulWidget {
  const BrowseCarsTab({super.key});

  @override
  State<BrowseCarsTab> createState() => _BrowseCarsTabState();
}

class _BrowseCarsTabState extends State<BrowseCarsTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedCarType = 'All';
  String _selectedPriceRange = 'All';
  String _selectedLocation = 'All';
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    ThemeService().addListener(_onThemeChanged);
    // Load all cars when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeBloc>().add(const LoadAllCarsEvent());
      }
    });
  }

  @override
  void dispose() {
    ThemeService().removeListener(_onThemeChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _performSearch() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search term'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Search cars with filters
    context.read<HomeBloc>().add(LoadAllCarsEvent(
          search: _searchController.text,
          type: _selectedCarType == 'All' ? null : _selectedCarType,
          location: _selectedLocation == 'All' ? null : _selectedLocation,
        ));

    setState(() {
      _isSearching = false;
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService().cardColor,
        title: Text(
          'Search Cars',
          style: TextStyle(
            color: ThemeService().textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter car name, model, or brand...',
                hintStyle: TextStyle(
                  color: ThemeService().secondaryTextColor,
                ),
                filled: true,
                fillColor: ThemeService().backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeService().secondaryTextColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: ThemeService().secondaryTextColor,
                ),
              ),
              style: TextStyle(
                color: ThemeService().textColor,
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16),
            Text(
              'Try searching for: Toyota, Honda, SUV, Sedan...',
              style: TextStyle(
                color: ThemeService().secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemeService().secondaryTextColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ThemeService().cardColor,
          title: Text(
            'Filter Cars',
            style: TextStyle(
              color: ThemeService().textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Car Type',
                  style: TextStyle(
                    color: ThemeService().textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedCarType,
                  isExpanded: true,
                  dropdownColor: ThemeService().cardColor,
                  style: TextStyle(
                    color: ThemeService().textColor,
                  ),
                  items: ['All', 'Sedan', 'SUV', 'Hatchback', 'Truck', 'Van']
                      .map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedCarType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Price Range',
                  style: TextStyle(
                    color: ThemeService().textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedPriceRange,
                  isExpanded: true,
                  dropdownColor: ThemeService().cardColor,
                  style: TextStyle(
                    color: ThemeService().textColor,
                  ),
                  items: ['All', 'Under \$50', '\$50-\$80', 'Over \$80']
                      .map((range) {
                    return DropdownMenuItem(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedPriceRange = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Location',
                  style: TextStyle(
                    color: ThemeService().textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  dropdownColor: ThemeService().cardColor,
                  style: TextStyle(
                    color: ThemeService().textColor,
                  ),
                  items: [
                    'All',
                    'Dar es Salaam',
                    'Arusha',
                    'Mwanza',
                    'Dodoma',
                    'Tanga'
                  ].map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedLocation = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ThemeService().secondaryTextColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applyFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _isSearching = true;
    });

    // Apply filters to search results
    context.read<HomeBloc>().add(LoadAllCarsEvent(
          type: _selectedCarType == 'All' ? null : _selectedCarType,
          location: _selectedLocation == 'All' ? null : _selectedLocation,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Filters applied: $_selectedCarType, $_selectedPriceRange, $_selectedLocation'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService().isDarkMode
          ? AppTheme.darkScaffoldBackground
          : AppTheme.lightScaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Browse Cars',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is CarsLoaded) {
            setState(() {
              _searchResults = state.cars;
            });
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final cars = state is CarsLoaded ? state.cars : _searchResults;

            return cars.isEmpty ? _buildEmptyState() : _buildCarList(cars);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeService().cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.search,
              size: 100,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Browse Cars',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: ThemeService().textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Find your perfect rental car',
            style: TextStyle(
              fontSize: 18,
              color: ThemeService().secondaryTextColor,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _showSearchDialog,
                  icon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isSearching ? 'Searching...' : 'Search Cars'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter Results'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(
                        color: AppTheme.primaryColor, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ThemeService().backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ThemeService().secondaryTextColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pro Tip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeService().textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use search and filters to find exactly what you\'re looking for!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeService().secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarList(List<Map<String, dynamic>> cars) {
    return Column(
      children: [
        // Search bar at top
        Container(
          padding: const EdgeInsets.all(16),
          color: ThemeService().cardColor,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search cars...',
                    hintStyle: TextStyle(
                      color: ThemeService().secondaryTextColor,
                    ),
                    filled: true,
                    fillColor: ThemeService().backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            ThemeService().secondaryTextColor.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.primaryColor),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: ThemeService().secondaryTextColor,
                    ),
                  ),
                  style: TextStyle(
                    color: ThemeService().textColor,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _showFilterDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.filter_list),
              ),
            ],
          ),
        ),
        // Results count
        Container(
          padding: const EdgeInsets.all(16),
          color: ThemeService().backgroundColor,
          child: Row(
            children: [
              Text(
                '${cars.length} Cars Available',
                style: TextStyle(
                  color: ThemeService().textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchResults.clear();
                    _searchController.clear();
                    // Reload all cars
                    context.read<HomeBloc>().add(const LoadAllCarsEvent());
                  });
                },
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Search results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return _buildCarCard(car);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car image placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: ThemeService().backgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(
                Icons.directions_car,
                size: 60,
                color: ThemeService().secondaryTextColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        car['title'] ?? 'Unknown Car',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeService().textColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        car['type'] ?? 'Unknown',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: ThemeService().secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      car['model'] ?? 'Unknown',
                      style: TextStyle(
                        color: ThemeService().secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: ThemeService().secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      car['location'] ?? 'Unknown',
                      style: TextStyle(
                        color: ThemeService().secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '\$${car['price'] ?? '0'}/day',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Viewing details for ${car['title']}'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
