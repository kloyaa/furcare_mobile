import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dio/dio.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/widgets/dialog_confirm.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Import necessary local packages
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/payment/preview.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/snackbar.dart';

class BookBoarding extends StatefulWidget {
  const BookBoarding({super.key});

  @override
  State<BookBoarding> createState() => _BookBoardingState();
}

class _BookBoardingState extends State<BookBoarding>
    with SingleTickerProviderStateMixin {
  // State variables
  late TimeOfDay _selectedTime;
  late int _selectedDay;
  String _accessToken = "";
  String _selectedCageId = "";
  String _selectedDate = "";
  String _selectedPet = "";
  String _selectedPetId = "";
  List _pets = [];
  List _cages = [];

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Provider setup
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    // Initialize state
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
    _selectedTime = const TimeOfDay(hour: 7, minute: 0);
    _selectedDay = 1;
    _pets = clientProvider.pets ?? [];

    // Load cages
    _loadCages();

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Load cages from API
  Future<void> _loadCages() async {
    try {
      ClientApi clientApi = ClientApi(_accessToken);
      Response<dynamic> response = await clientApi.getCages();
      setState(() {
        _cages = response.data;
      });
    } catch (e) {
      showSafeSnackBar("Failed to load cages", color: AppColors.danger);
    }
  }

  // Submit booking method
  Future<void> handleSubmitBooking() async {
    // Validation checks remain the same as in the original code
    BookingApi booking = BookingApi(_accessToken);

    if (_selectedCageId.isEmpty) {
      return showSafeSnackBar("Please select a cage", color: AppColors.danger);
    }

    if (_selectedDate.isEmpty) {
      return showSafeSnackBar(
        "Please select a schedule",
        color: AppColors.danger,
      );
    }

    if (_selectedPet.isEmpty) {
      return showSnackBar(
        context,
        "Please select a pet",
        color: AppColors.danger,
        fontSize: 10.0,
      );
    }

    final formattedDate = DateTime.parse(_selectedDate);
    DateTime schedule = DateTime(
      formattedDate.year,
      formattedDate.month,
      formattedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      Response<dynamic> response = await booking.boardBooking(
        BoardingPayload(
          cage: _selectedCageId,
          pet: _selectedPetId,
          schedule: schedule.toUtc().toIso8601String(),
          daysOfStay: _selectedDay,
        ),
      );

      if (context.mounted) {
        showSafeSnackBar("Booked successfully!", color: Colors.green);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PaymentPreview(
                  serviceName: "boarding",
                  date: response.data['date'],
                  referenceNo: response.data['referenceNo'],
                ),
          ),
        );
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSnackBar(
          context,
          errorResponse.message,
          color: AppColors.danger,
          fontSize: 10.0,
        );
      }
    }
  }

  // Build method with improved UI and animations
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Pet Boarding",
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar Section
                _buildSectionTitle("Select Date"),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CalendarDatePicker2(
                    config: CalendarDatePicker2Config(
                      calendarType: CalendarDatePicker2Type.single,
                      selectedDayHighlightColor: AppColors.primary,
                      dayTextStyle: GoogleFonts.urbanist(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      controlsTextStyle: GoogleFonts.urbanist(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      weekdayLabelTextStyle: GoogleFonts.urbanist(
                        color: AppColors.primary.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      nextMonthIcon: Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                      ),
                      currentDate: DateTime.now(),
                      firstDate: DateTime.now(), // Prevent selecting past dates
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ), // Allow booking up to a year ahead
                    ),
                    value:
                        _selectedDate.isNotEmpty
                            ? [DateTime.parse(_selectedDate)]
                            : [DateTime.now()],
                    onValueChanged: (dates) {
                      if (dates.isNotEmpty) {
                        setState(() {
                          _selectedDate = dates[0].toIso8601String().substring(
                            0,
                            10,
                          );
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20.0),

                // Dropdowns Section
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownContainer(
                        child: DropdownButton<TimeOfDay>(
                          value: _selectedTime,
                          underline: const SizedBox(),
                          onChanged: (TimeOfDay? newValue) {
                            setState(() {
                              _selectedTime = newValue!;
                            });
                          },
                          items: List<DropdownMenuItem<TimeOfDay>>.generate(
                            15,
                            (int index) {
                              final hour = index + 7;
                              return DropdownMenuItem<TimeOfDay>(
                                value: TimeOfDay(hour: hour % 24, minute: 0),
                                child: Text(
                                  _formatTime(hour),
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _buildDropdownContainer(
                        child: DropdownButton<int>(
                          value: _selectedDay,
                          underline: const SizedBox(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedDay = newValue!;
                            });
                          },
                          items: List<DropdownMenuItem<int>>.generate(31, (
                            int index,
                          ) {
                            final day = index + 1;
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text(
                                "$day day(s)",
                                style: GoogleFonts.urbanist(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _buildDropdownContainer(
                        child: DropdownButton<dynamic>(
                          value: _selectedPet.isNotEmpty ? _selectedPet : null,
                          underline: const SizedBox(),
                          hint: Text(
                            "Select Pet",
                            style: GoogleFonts.urbanist(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onChanged: (dynamic newValue) {
                            setState(() {
                              _selectedPet = newValue!;
                              _selectedPetId = newValue;
                            });
                          },
                          items:
                              _pets.map<DropdownMenuItem<dynamic>>((pet) {
                                return DropdownMenuItem(
                                  value: pet['_id'],
                                  child: Text(
                                    pet['name'],
                                    style: GoogleFonts.urbanist(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                // Cage Selection Section
                _buildSectionTitle("Select Cage"),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _cages.length,
                  itemBuilder: (context, index) {
                    final cage = _cages[index];
                    return GestureDetector(
                      onTap:
                          cage['available']
                              ? () {
                                setState(() {
                                  _selectedCageId = cage['_id'];
                                });
                              }
                              : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color:
                              _selectedCageId == cage['_id']
                                  ? AppColors.primary
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Opacity(
                          opacity: cage['available'] ? 1 : 0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cage['title'],
                                style: GoogleFonts.urbanist(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedCageId == cage['_id']
                                          ? Colors.white
                                          : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${cage['used']}/${cage['limit']} occupied",
                                style: GoogleFonts.urbanist(
                                  fontSize: 12.0,
                                  color:
                                      _selectedCageId == cage['_id']
                                          ? Colors.white70
                                          : AppColors.primary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20.0),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => ConfirmationDialog(
                            title: 'Confirm Booking',
                            message: 'Proceed with boarding appointment?',
                            onConfirm: () => handleSubmitBooking(),
                          ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Book Boarding',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slide(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: GoogleFonts.urbanist(
          color: AppColors.primary,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper method to build dropdown containers
  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // Time formatting method remains the same
  String _formatTime(int hour) {
    final isPM = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displaySuffix = isPM ? ' PM' : ' AM';
    return '$displayHour:00$displaySuffix';
  }
}
