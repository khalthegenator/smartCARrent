import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/theme_service.dart';

class MyCarsTab extends StatefulWidget {
  const MyCarsTab({super.key});

  @override
  State<MyCarsTab> createState() => _MyCarsTabState();
}

class _MyCarsTabState extends State<MyCarsTab> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _localCars =
      []; // Local cache for immediate UI updates

  @override
  void initState() {
    super.initState();
    ThemeService().addListener(_onThemeChanged);
    _loadMyCars();
  }

  @override
  void dispose() {
    ThemeService().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  String? _deletedCarId; // Track which car is being deleted

  void _loadMyCars() {
    context.read<HomeBloc>().add(const LoadUserCarsEvent());
  }

  String _getDeletedCarId() {
    return _deletedCarId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService().isDarkMode
          ? AppTheme.darkScaffoldBackground
          : AppTheme.lightScaffoldBackground,
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          print('MyCarsTab: BlocListener received state: ${state.runtimeType}');
          if (state is HomeLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is UserCarsLoaded) {
            print(
                'MyCarsTab: BlocListener - UserCarsLoaded with ${state.cars.length} cars');
            setState(() {
              _isLoading = false;
              _localCars = state.cars; // Update local cache
            });
            // Force a complete rebuild
            if (mounted) {
              setState(() {});
            }
          } else if (state is CarDeleted) {
            print('MyCarsTab: BlocListener - CarDeleted state received');
            // Show success message and force refresh
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Car deleted successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Force immediate UI refresh by removing from local cache
            if (mounted) {
              setState(() {
                print('MyCarsTab: Forcing UI refresh after delete');
                // Remove car from local cache immediately
                _localCars.removeWhere(
                    (car) => car['id'].toString() == _getDeletedCarId());
                print(
                    'MyCarsTab: Local cars count after removal: ${_localCars.length}');
              });
            }
            // Reload cars to get updated list
            _loadMyCars();
          } else if (state is HomeError) {
            setState(() {
              _isLoading = false;
            });
            // Completely remove error notifications
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'My Cars',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ThemeService().textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your car listings',
                style: TextStyle(
                  fontSize: 16,
                  color: ThemeService().secondaryTextColor,
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  print(
                      'MyCarsTab: BlocBuilder building with state: ${state.runtimeType}');

                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Use local cache for immediate UI updates
                  final carsToDisplay = _localCars.isNotEmpty
                      ? _localCars
                      : (state is UserCarsLoaded ? state.cars : []);

                  if (carsToDisplay.isEmpty) {
                    return Center(
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
                              Icons.directions_car_outlined,
                              size: 100,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'No cars posted yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ThemeService().textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start by posting your first car for rent or sale',
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemeService().secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.go('/dashboard?tab=2');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Post Your First Car'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Summary cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Cars',
                              '${carsToDisplay.length}',
                              Icons.directions_car,
                              AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Active Listings',
                              '${carsToDisplay.length}',
                              Icons.check_circle,
                              AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Car listings
                      ...carsToDisplay.map((car) {
                        print(
                            'MyCarsTab: Mapping car: ${car['title']} (ID: ${car['id']})');
                        return _buildCarCard(car);
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Navigate to Post tab to add a car'),
              backgroundColor: AppTheme.infoColor,
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeService().textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: ThemeService().secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    final carId = car['id']?.toString() ?? 'unknown';
    final carTitle = car['title']?.toString() ?? 'Unknown';
    print('MyCarsTab: Building car card for: $carTitle (ID: $carId)');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car['title'] ?? 'Unknown Car',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeService().textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            car['model'] ?? 'Unknown Model',
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeService().secondaryTextColor,
                            ),
                          ),
                        ],
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
                        '\$${car['price'] ?? '0'}/day',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildCarDetail(
                      Icons.calendar_today,
                      car['year']?.toString() ?? 'Unknown',
                    ),
                    const SizedBox(width: 16),
                    _buildCarDetail(
                      Icons.local_gas_station,
                      car['fuel'] ?? 'Unknown',
                    ),
                    const SizedBox(width: 16),
                    _buildCarDetail(
                      Icons.settings,
                      car['transmission'] ?? 'Unknown',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildCarDetail(
                      Icons.location_on,
                      car['location'] ?? 'Unknown',
                    ),
                    const SizedBox(width: 16),
                    _buildCarDetail(
                      Icons.category,
                      car['type'] ?? 'Unknown',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to post tab with car data for editing
                          context.go(
                              '/dashboard?tab=2&edit=true&carId=${car['id']}');
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final carId = car['id']?.toString() ?? '';
                          final carTitle =
                              car['title']?.toString() ?? 'Unknown';
                          final carModel =
                              car['model']?.toString() ?? 'Unknown';

                          print(
                              'MyCarsTab: Delete button pressed for car: $carTitle $carModel (ID: $carId)');
                          print(
                              'MyCarsTab: Car data keys: ${car.keys.toList()}');
                          print('MyCarsTab: Car data: $car');

                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: Text(
                                    'Are you sure you want to delete "$carTitle $carModel"?\n\nCar ID: $carId'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      print(
                                          'MyCarsTab: User confirmed delete for car ID: $carId');

                                      // Track which car is being deleted
                                      _deletedCarId = carId;

                                      context
                                          .read<HomeBloc>()
                                          .add(DeleteCarEvent(carId));
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
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

  Widget _buildCarDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: ThemeService().secondaryTextColor,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: ThemeService().secondaryTextColor,
          ),
        ),
      ],
    );
  }
}
