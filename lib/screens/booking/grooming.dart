import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/apis/fees_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/branch_info.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/servcefee_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/branch.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/payment/preview.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/card_schedule.dart';
import 'package:furcare_app/widgets/dialog_confirm.dart';
import 'package:furcare_app/widgets/dropdown_pets.dart';
import 'package:furcare_app/widgets/snackbar_animated.dart';
import 'package:furcare_app/widgets/total_animated.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class BookGroomingScreen extends StatefulWidget {
  const BookGroomingScreen({super.key});

  @override
  State<BookGroomingScreen> createState() => _BookGroomingScreenState();
}

class _BookGroomingScreenState extends State<BookGroomingScreen>
    with SingleTickerProviderStateMixin {
  // State Management
  final ValueNotifier<String> _selectedScheduleNotifier = ValueNotifier<String>(
    '',
  );
  final ValueNotifier<String> _selectedPetNotifier = ValueNotifier<String>('');
  final ValueNotifier<double> _totalAmountNotifier = ValueNotifier<double>(0);

  // Map to track selected services
  final Map<String, bool> _selectedServices = {};

  // Anti-rabbies radio button state
  String _antiRabbiesValue = 'No'; // Default value is No

  late AnimationController _animationController;
  late List<dynamic> _availableSchedules = [];
  late List<dynamic> _pets = [];
  String _accessToken = '';
  late Branch _selectedBranch;

  // Renamed for clarity and consistency
  List<ServiceFee> _groomingServices = [];
  List<ServiceFee> _vaccinationServices = [];
  final double _baseGroomingFee = 0;

  // Scroll controller for the main content
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
      _fetchSchedules();
      _fetchServiceFees();
      _fetchAllServices();

      if (DateTime.now().weekday == DateTime.sunday) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => ConfirmationDialog(
                title: 'Grooming Unavailable',
                message:
                    'Grooming is unavailable on Sundays. Please select another day for your pet grooming appointment.',
                onConfirm: () {
                  // No additional action needed when user confirms
                },
              ),
        );
      }
    });

    _selectedBranch =
        Provider.of<BranchProvider>(context, listen: false).branch;
  }

  void _initializeProviders() {
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    setState(() {
      _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
      _pets = clientProvider.pets ?? [];
    });
  }

  Future<void> _fetchServiceFees() async {
    try {
      // Create the API client
      FeesApi appApi = FeesApi(_accessToken);

      // Get the response from the API
      Response<dynamic> response = await appApi.getServiceFees(
        queryParameters: {'title': 'grooming'},
      );

      // Transform the response data into a list of ServiceFee objects
      List<ServiceFee> serviceFees =
          (response.data as List)
              .map(
                (feeJson) =>
                    ServiceFee.fromJson(feeJson as Map<String, dynamic>),
              )
              .toList();

      // _baseGroomingFee = serviceFees.isNotEmpty ? serviceFees[0].fee : 0;
      _updateTotalAmount();
    } catch (e) {
      _showErrorSnackbar('Failed to fetch service fees');
    }
  }

  Future<void> _fetchAllServices() async {
    try {
      // Create the API client
      FeesApi appApi = FeesApi(_accessToken);

      // Get responses from both APIs
      final groomingFuture = appApi.getGroomingServiceFees();
      final vaccinationFuture = appApi.getVaccinationServiceFees();

      // Wait for both API calls to complete
      final results = await Future.wait([groomingFuture, vaccinationFuture]);

      // Extract responses
      final groomingResponse = results[0];
      final vaccinationResponse = results[1];

      // Transform the response data into lists of ServiceFee objects
      List<ServiceFee> groomingFees =
          (groomingResponse.data as List)
              .map(
                (feeJson) =>
                    ServiceFee.fromJson(feeJson as Map<String, dynamic>),
              )
              .toList();

      List<ServiceFee> vaccinationFees =
          (vaccinationResponse.data as List)
              .map(
                (feeJson) =>
                    ServiceFee.fromJson(feeJson as Map<String, dynamic>),
              )
              .toList();

      if (mounted) {
        setState(() {
          _groomingServices = groomingFees;
          _vaccinationServices = vaccinationFees;

          // Initialize all services as unselected
          for (var service in _groomingServices) {
            _selectedServices[service.id] = false;
          }

          // Initialize all vaccination services as unselected
          for (var service in _vaccinationServices) {
            _selectedServices[service.id] = false;
          }

          // Update total after services are loaded
          _updateTotalAmount();
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to fetch services');
      }
    }
  }

  void _updateTotalAmount() {
    double total = _baseGroomingFee;

    // Add costs for selected grooming services
    _selectedServices.forEach((serviceId, isSelected) {
      if (isSelected) {
        // First check if it's a grooming service
        ServiceFee? service = _groomingServices.firstWhere(
          (s) => s.id == serviceId,
          orElse:
              () => ServiceFee(
                id: '',
                title: '',
                fee: 0,
                version: 1,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        );

        // If not found in grooming services, check vaccination services
        if (service.id.isEmpty) {
          service = _vaccinationServices.firstWhere(
            (s) => s.id == serviceId,
            orElse:
                () => ServiceFee(
                  id: '',
                  title: '',
                  fee: 0,
                  version: 1,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
          );
        }

        // Add the fee to the total
        if (service.id.isNotEmpty) {
          total += service.fee;
        }
      }
    });

    _totalAmountNotifier.value = total;
  }

  void _toggleService(String serviceId, bool value) {
    setState(() {
      _selectedServices[serviceId] = value;
      _updateTotalAmount();
    });
  }

  Future<void> _fetchSchedules() async {
    try {
      setState(() {
        // Clear schedules and set loading state
        _availableSchedules = [];
      });

      final ClientApi clientApi = ClientApi(_accessToken);
      final Response<dynamic> response = await clientApi.getSchedules();

      if (mounted) {
        setState(() {
          _availableSchedules = response.data;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to fetch schedules');
      }
    }
  }

  Future<void> _handleBookGrooming() async {
    final scheduleId = _selectedScheduleNotifier.value;
    final petId = _selectedPetNotifier.value;

    if (scheduleId.isEmpty || petId.isEmpty) {
      _showErrorSnackbar('Please select both schedule and pet');
      return;
    }

    // Get list of selected service IDs
    final List<String> selectedServiceIds =
        _selectedServices.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    try {
      final BookingApi bookingApi = BookingApi(_accessToken);
      final Response<dynamic> response = await bookingApi.groomingBooking(
        GroomingPayload(
          pet: petId,
          schedule: scheduleId,
          branch: _selectedBranch.id ?? '',
          services: selectedServiceIds,
          // antiRabbies: _antiRabbiesValue, // Include the anti-rabbies value
        ),
      );

      if (context.mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => PaymentPreview(
                  amount: _totalAmountNotifier.value,
                  daysOfStay: 1,
                  serviceName: "grooming",
                  date: response.data['date'],
                  referenceNo: response.data['referenceNo'],
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      }
    } on DioException catch (e) {
      final ErrorResponse errorResponse = ErrorResponse.fromJson(
        e.response?.data,
      );
      _showErrorSnackbar(errorResponse.message);
    } catch (e) {
      _showErrorSnackbar('An error occurred while booking. Please try again.');
    }
  }

  void _showErrorSnackbar(String message) {
    AnimatedSnackBar.show(context, message: message, type: SnackBarType.error);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pet Grooming",
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _totalAmountNotifier,
              builder: (context, amount, _) {
                return AnimatedTotal(amount: amount);
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Select Schedule'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: screenHeight * 0.1, // 10% of screen height
                        child: _buildScheduleList(),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Select Pet'),
                      const SizedBox(height: 10),
                      _pets.isEmpty
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                          : PetDropdown(
                            pets: _pets,
                            onPetSelected: (petId) {
                              _selectedPetNotifier.value = petId;
                            },
                          ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Anti-rabbies'),
                      const SizedBox(height: 10),
                      _buildAntiRabbiesRadioSection(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Select Grooming Services'),
                      const SizedBox(height: 10),
                      // Grooming services section
                      SizedBox(
                        height:
                            screenHeight * 0.3, // Adjusted for better layout
                        child: _buildGroomingServicesList(),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Select Vaccination Services'),
                      const SizedBox(height: 10),
                      // Vaccination services section
                      SizedBox(
                        height:
                            screenHeight * 0.3, // Adjusted for better layout
                        child: _buildVaccinationServicesList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed bottom button
            Container(
              padding: const EdgeInsets.all(20.0),
              width: double.infinity,
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // New method to build the Anti-rabbies radio section
  Widget _buildAntiRabbiesRadioSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anti-rabbies Vaccination',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'Yes',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    value: 'Yes',
                    groupValue: _antiRabbiesValue,
                    onChanged: (value) {
                      setState(() {
                        _antiRabbiesValue = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'No',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    value: 'No',
                    groupValue: _antiRabbiesValue,
                    onChanged: (value) {
                      setState(() {
                        _antiRabbiesValue = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: GoogleFonts.urbanist(
          color: AppColors.primary.withAlpha(200),
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_availableSchedules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _availableSchedules.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final schedule = _availableSchedules[index];
        return ValueListenableBuilder<String>(
          valueListenable: _selectedScheduleNotifier,
          builder: (context, selectedSchedule, child) {
            return Container(
              width: 200, // Fixed width for horizontal schedule cards
              margin: const EdgeInsets.only(right: 10),
              child: ScheduleCard(
                schedule: schedule,
                isSelected: selectedSchedule == schedule['_id'],
                onTap: () {
                  _selectedScheduleNotifier.value = schedule['_id'];
                },
              ).animate().slideX(
                begin: 0.5,
                duration: 300.ms,
                curve: Curves.easeOut,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroomingServicesList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Grooming Services',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Base grooming fee: PHP ${_baseGroomingFee.toStringAsFixed(2)}',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _groomingServices.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: _groomingServices.length,
                        itemBuilder: (context, index) {
                          final service = _groomingServices[index];
                          return ServiceCheckboxTile(
                            service: service,
                            isSelected: _selectedServices[service.id] ?? false,
                            onChanged: (bool? value) {
                              _toggleService(service.id, value ?? false);
                            },
                          ).animate().fadeIn(
                            delay: Duration(milliseconds: 50 * index),
                            duration: 300.ms,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationServicesList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vaccination Services',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _vaccinationServices.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: _vaccinationServices.length,
                        itemBuilder: (context, index) {
                          final service = _vaccinationServices[index];
                          return ServiceCheckboxTile(
                            service: service,
                            isSelected: _selectedServices[service.id] ?? false,
                            onChanged: (bool? value) {
                              _toggleService(service.id, value ?? false);
                            },
                          ).animate().fadeIn(
                            delay: Duration(milliseconds: 50 * index),
                            duration: 300.ms,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    // Check if today is Sunday
    bool isSunday = DateTime.now().weekday == DateTime.sunday;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Disable button if it's Sunday
        onPressed:
            isSunday
                ? null
                : () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => ConfirmationDialog(
                          title: 'Confirm Booking',
                          message: 'Proceed with pet grooming appointment?',
                          onConfirm: _handleBookGrooming,
                        ),
                  );
                },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          isSunday ? 'Closed' : 'Book Grooming',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _selectedScheduleNotifier.dispose();
    _selectedPetNotifier.dispose();
    _totalAmountNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Widget for displaying service checkboxes
class ServiceCheckboxTile extends StatelessWidget {
  final ServiceFee service;
  final bool isSelected;
  final Function(bool?) onChanged;

  const ServiceCheckboxTile({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? AppColors.primary.withAlpha(50) : Colors.grey[100],
      ),
      child: CheckboxListTile(
        title: Text(
          service.title,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          'PHP ${service.fee.toStringAsFixed(2)}',
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: isSelected,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        dense: true,
      ),
    );
  }
}
