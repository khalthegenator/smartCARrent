import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import 'payment_test_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> car;

  const CarDetailsScreen({
    super.key,
    required this.car,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  bool _isProcessing = false;
  DateTimeRange? _selectedRentalRange;
  double _rentalTotal = 0;
  final TextEditingController _phoneController = TextEditingController();
  String _selectedProvider = 'Airtel';
  String _paymentNote = '';
  Map<String, dynamic>? _dealerContact;

  @override
  void initState() {
    super.initState();
    _loadDealerContact();
  }

  bool get _isRental =>
      widget.car['listing_type']?.toString().toLowerCase() == 'rental';

  Future<void> _loadDealerContact() async {
    final dealerUserId = widget.car['user_id']?.toString();
    if (dealerUserId == null || dealerUserId.isEmpty) return;

    try {
      final dealer = await DatabaseService.getUserById(dealerUserId);
      if (!mounted) return;
      setState(() {
        _dealerContact = dealer;
      });
    } catch (_) {
      // Keep using fallback values from vehicle metadata.
    }
  }

  double get _price {
    return double.tryParse(widget.car['price']?.toString() ?? '0') ?? 0;
  }

  double get _dailyRate {
    return _price > 0 ? _price : 0;
  }

  double get _commissionRate => _isRental ? 0.05 : 0.08;

  String get _commissionLabel => _isRental ? '5%' : '8%';

  double get _commissionAmount {
    final amount = _isRental ? _rentalTotal : _price;
    return amount * _commissionRate;
  }

  double get _dealerShare {
    final amount = _isRental ? _rentalTotal : _price;
    return amount - _commissionAmount;
  }

  Future<void> _selectRentalDates() async {
    final today = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      initialDateRange: _selectedRentalRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range == null) return;

    setState(() {
      _selectedRentalRange = range;
      final days = range.duration.inDays + 1;
      _rentalTotal = _dailyRate * days;
    });

    _showPaymentDialog();
  }

  Future<void> _showContactOwnerSheet() async {
    final contactSource = _dealerContact ?? widget.car;
    final dealerName = contactSource['dealer_name']
                ?.toString()
                .trim()
                .isNotEmpty ==
            true
        ? contactSource['dealer_name'].toString()
        : contactSource['dealer_full_name']?.toString().trim().isNotEmpty ==
                true
            ? contactSource['dealer_full_name'].toString()
            : contactSource['full_name']?.toString().trim().isNotEmpty == true
                ? contactSource['full_name'].toString()
                : 'Dealer';
    final dealerPhone = contactSource['business_phone']
                ?.toString()
                .trim()
                .isNotEmpty ==
            true
        ? contactSource['business_phone'].toString()
        : contactSource['phone_number']?.toString().trim().isNotEmpty == true
            ? contactSource['phone_number'].toString()
            : 'Not provided';
    final dealerEmail =
        contactSource['business_email']?.toString().trim().isNotEmpty == true
            ? contactSource['business_email'].toString()
            : contactSource['email']?.toString().trim().isNotEmpty == true
                ? contactSource['email'].toString()
                : 'Not provided';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact dealer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Reach out to $dealerName about this ${_isRental ? 'rental' : 'vehicle'}.',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.phone, color: AppTheme.primaryColor),
                  title: const Text('Phone'),
                  subtitle: Text(dealerPhone),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling $dealerPhone')),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.email, color: AppTheme.primaryColor),
                  title: const Text('Email'),
                  subtitle: Text(dealerEmail),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email: $dealerEmail')),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'You can also use the dealer details above to confirm the vehicle, arrange pickup, or discuss pricing.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPaymentDialog() async {
    final amount = _isRental ? _rentalTotal : _price;
    final title =
        _isRental ? 'Rental payment details' : 'Purchase payment details';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isRental && _selectedRentalRange != null) ...[
                  Text(
                    'Rental period: ${_selectedRentalRange!.start.toLocal().toString().split(' ')[0]} - ${_selectedRentalRange!.end.toLocal().toString().split(' ')[0]}',
                  ),
                  const SizedBox(height: 8),
                  Text('Days: ${_selectedRentalRange!.duration.inDays + 1}'),
                  const SizedBox(height: 8),
                ],
                Text(
                    'Vehicle price: TSh ${_dailyRate.toStringAsFixed(0)} per day'),
                const SizedBox(height: 8),
                Text(
                    'Admin commission ($_commissionLabel): TSh ${_commissionAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Text('Dealer share: TSh ${_dealerShare.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Text('Total payable: TSh ${amount.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                const Text('Choose payment provider'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  items: const [
                    DropdownMenuItem(value: 'Airtel', child: Text('Airtel')),
                    DropdownMenuItem(value: 'Vodacom', child: Text('Vodacom')),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedProvider = value ?? 'Airtel'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mobile money provider',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone number',
                    hintText: 'e.g. 0755123456',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Payment note (optional)',
                  ),
                  onChanged: (value) => _paymentNote = value,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmPayment(amount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirm payment via Azam Pay'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmPayment(double amount) async {
    if (_phoneController.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final currentUser = await AuthService.getCurrentUser();
      final customerId = currentUser?['id']?.toString() ?? 'customer1';
      final transactionId = 'tx_${DateTime.now().millisecondsSinceEpoch}';
      final receipt = buildReceiptSummary(
        amount: amount,
        provider: _selectedProvider,
        phoneNumber: _phoneController.text.trim(),
        listingType: _isRental ? 'rental' : 'purchase',
        transactionId: transactionId,
      );

      await DatabaseService.createBooking(
        carId: widget.car['id']?.toString() ?? transactionId,
        userId: customerId,
        startDate: _isRental && _selectedRentalRange != null
            ? _selectedRentalRange!.start.toIso8601String()
            : DateTime.now().toIso8601String(),
        endDate: _isRental && _selectedRentalRange != null
            ? _selectedRentalRange!.end.toIso8601String()
            : DateTime.now().toIso8601String(),
        totalPrice: amount,
        carTitle: widget.car['title']?.toString(),
        carModel: widget.car['model']?.toString(),
        dealerId: widget.car['user_id']?.toString(),
        customerPhone: _phoneController.text.trim(),
        paymentProvider: _selectedProvider,
        paymentNote: _paymentNote,
      );

      await DatabaseService.updateCar(
        carId: widget.car['id']?.toString() ?? transactionId,
        updates: {
          'status': 'booked',
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Payment confirmed'),
          content: Text(receipt),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment confirmation failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image)),
        ),
      );
    }
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService().isDarkMode
          ? AppTheme.darkScaffoldBackground
          : AppTheme.lightScaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.car['images'] != null &&
                          (widget.car['images'] as List).isNotEmpty
                      ? _buildImageWidget(
                          widget.car['images'][0].toString(),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_car,
                                    size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('No Image',
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color.fromRGBO(0, 0, 0, 0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Add to favorites
                },
                icon: const Icon(Icons.favorite_border),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  // TODO: Share car
                },
                icon: const Icon(Icons.share),
                color: Colors.white,
              ),
            ],
          ),

          // Car Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.car['title'] ?? 'Unknown Car',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.car['model'] ?? 'Unknown Model'} • ${widget.car['year'] ?? 'Unknown Year'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'TSh ${widget.car['price'] ?? '0'}/day',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Availability Status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (widget.car['available'] == true)
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (widget.car['available'] == true)
                              ? Colors.green
                              : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (widget.car['available'] == true)
                                ? Icons.check_circle
                                : Icons.hourglass_top,
                            color: (widget.car['available'] == true)
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (widget.car['available'] == true)
                                  ? 'Available for ${_isRental ? 'rent' : 'purchase'}'
                                  : 'Pending availability update from the dealer',
                              style: TextStyle(
                                color: (widget.car['available'] == true)
                                    ? Colors.green
                                    : Colors.orange[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Car Features
                    const Text(
                      'Car Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      children: [
                        _buildFeatureItem(Icons.directions_car, 'Type',
                            widget.car['type'] ?? 'Unknown'),
                        _buildFeatureItem(Icons.settings, 'Transmission',
                            widget.car['transmission'] ?? 'Unknown'),
                        _buildFeatureItem(Icons.local_gas_station, 'Fuel',
                            widget.car['fuel'] ?? 'Unknown'),
                        _buildFeatureItem(Icons.people, 'Seats',
                            '${widget.car['seats'] ?? '5'}'),
                        _buildFeatureItem(Icons.colorize, 'Color',
                            widget.car['color'] ?? 'Unknown'),
                        _buildFeatureItem(Icons.speed, 'Mileage',
                            '${widget.car['mileage'] ?? '0'} km'),
                        _buildFeatureItem(Icons.category, 'Condition',
                            widget.car['condition'] ?? 'Unknown'),
                        _buildFeatureItem(Icons.location_on, 'Location',
                            widget.car['location'] ?? 'Unknown'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.car['description'] ??
                          'No description available for this car.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showContactOwnerSheet,
                            icon: const Icon(Icons.phone),
                            label: const Text('Contact Dealer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : _isRental
                                    ? _selectRentalDates
                                    : () => _showPaymentDialog(),
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : Icon(_isRental
                                    ? Icons.calendar_today
                                    : Icons.shopping_cart),
                            label: Text(_isProcessing
                                ? 'Processing...'
                                : _isRental
                                    ? 'Select Rental Dates'
                                    : 'Buy Now'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(
                                  color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    (widget.car['images'] as List).length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildImageWidget(
                                        widget.car['images'][index].toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
