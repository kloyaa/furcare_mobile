import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/payment/preview.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/dialog_confirm.dart';
import 'package:furcare_app/widgets/dropdown_pets.dart';
import 'package:furcare_app/widgets/snackbar_animated.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class HomeServiceScreen extends StatefulWidget {
  const HomeServiceScreen({super.key});

  @override
  State<HomeServiceScreen> createState() => _HomeServiceScreenState();
}

class _HomeServiceScreenState extends State<HomeServiceScreen>
    with SingleTickerProviderStateMixin {
  // State Management
  final ValueNotifier<DateTime?> _selectedDateTimeNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<String> _selectedPetNotifier = ValueNotifier<String>('');

  late AnimationController _animationController;
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

  Future<void> _handleBookHomeService() async {
    final selectedDateTime = _selectedDateTimeNotifier.value;
    final selectedPetId = _selectedPetNotifier.value;

    if (selectedDateTime == null) {
      _showErrorSnackbar('Please select a schedule');
      return;
    }

    if (selectedPetId.isEmpty) {
      _showErrorSnackbar('Please select a pet');
      return;
    }

    try {
      final BookingApi bookingApi = BookingApi(_accessToken);
      final Response<dynamic> response = await bookingApi.transitBooking(
        TransitgPayload(
          pet: selectedPetId,
          schedule: selectedDateTime.toIso8601String(),
        ),
      );

      if (context.mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => PaymentPreview(
                  serviceName: "home service",
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

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.primary,
              ),
            ),
            child: child!,
          ),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder:
            (context, child) => Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.primary,
                ),
              ),
              child: child!,
            ),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _selectedDateTimeNotifier.value = selectedDateTime;
      }
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
          "Home Service",
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
              _buildSectionTitle('Select Pet'),
              const SizedBox(height: 10),
              PetDropdown(
                pets: _pets,
                onPetSelected: (petId) {
                  _selectedPetNotifier.value = petId;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Select Schedule'),
              const SizedBox(height: 10),
              _buildSchedulePicker(),
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

  Widget _buildSchedulePicker() {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: _selectedDateTimeNotifier,
      builder: (context, selectedDateTime, child) {
        return GestureDetector(
          onTap: () => _selectDateTime(context),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                selectedDateTime != null
                    ? formatDate(selectedDateTime)
                    : 'Select Date and Time',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ).animate().slideX(begin: 0.5, duration: 300.ms, curve: Curves.easeOut);
      },
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
                  message: 'Proceed with home service appointment?',
                  onConfirm: _handleBookHomeService,
                ),
          );
        },
        child: Text(
          'Book Home Service',
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
    _selectedDateTimeNotifier.dispose();
    _selectedPetNotifier.dispose();
    super.dispose();
  }
}
