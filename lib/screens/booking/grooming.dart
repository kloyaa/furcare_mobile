import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/payment/preview.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/card_schedule.dart';
import 'package:furcare_app/widgets/dialog_confirm.dart';
import 'package:furcare_app/widgets/dropdown_pets.dart';
import 'package:furcare_app/widgets/snackbar_animated.dart';
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

  late AnimationController _animationController;
  late List<dynamic> _availableSchedules = [];
  late List<dynamic> _pets = [];
  String _accessToken = '';

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
    });
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

  Future<void> _fetchSchedules() async {
    try {
      final ClientApi clientApi = ClientApi(_accessToken);
      final Response<dynamic> response = await clientApi.getSchedules();

      setState(() {
        _availableSchedules = response.data;
      });
    } catch (e) {
      _showErrorSnackbar('Failed to fetch schedules');
    }
  }

  Future<void> _handleBookGrooming() async {
    final scheduleId = _selectedScheduleNotifier.value;
    final petId = _selectedPetNotifier.value;

    if (scheduleId.isEmpty || petId.isEmpty) {
      _showErrorSnackbar('Please select both schedule and pet');
      return;
    }

    try {
      final BookingApi bookingApi = BookingApi(_accessToken);
      final Response<dynamic> response = await bookingApi.groomingBooking(
        GroomingPayload(pet: petId, schedule: scheduleId),
      );

      if (context.mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => PaymentPreview(
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
    }
  }

  void _showErrorSnackbar(String message) {
    AnimatedSnackBar.show(context, message: message, type: SnackBarType.error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Pet Grooming",
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Select Schedule'),
              const SizedBox(height: 10),
              _buildScheduleList(),
              const SizedBox(height: 20),
              _buildSectionTitle('Select Pet'),
              const SizedBox(height: 10),
              PetDropdown(
                pets: _pets,
                onPetSelected: (petId) {
                  _selectedPetNotifier.value = petId;
                },
              ),
              const Spacer(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.urbanist(
        color: AppColors.primary.withOpacity(0.7),
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      ),
    );
  }

  Widget _buildScheduleList() {
    return Expanded(
      flex: 2,
      child: ListView.builder(
        itemCount: _availableSchedules.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final schedule = _availableSchedules[index];
          return ValueListenableBuilder<String>(
            valueListenable: _selectedScheduleNotifier,
            builder: (context, selectedSchedule, child) {
              return ScheduleCard(
                schedule: schedule,
                isSelected: selectedSchedule == schedule['_id'],
                onTap: () {
                  _selectedScheduleNotifier.value = schedule['_id'];
                },
              ).animate().slideX(
                begin: 0.5,
                duration: 300.ms,
                curve: Curves.easeOut,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        onPressed: () {
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
        child: Text(
          'Book Grooming',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
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
    super.dispose();
  }
}
