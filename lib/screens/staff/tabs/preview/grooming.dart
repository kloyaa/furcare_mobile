import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/apis/staff_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/pet_info.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/screens/others/success.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/utils/const/colors.dart';

class PreviewGrooming extends StatefulWidget {
  const PreviewGrooming({super.key});

  @override
  State<PreviewGrooming> createState() => _PreviewGroomingState();
}

class _PreviewGroomingState extends State<PreviewGrooming>
    with SingleTickerProviderStateMixin {
  // State variables
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Data from arguments
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _pet;
  String? _application;
  String? _booking;

  // Store the future for booking details
  late Future<Map<String, dynamic>?> _bookingDetailsFuture;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start animation after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    _bookingDetailsFuture = getBookingDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments only when dependencies change
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    // Only recreate the future if needed data has changed
    if (_application != arguments['application']) {
      _application = arguments['application'];
      _bookingDetailsFuture = getBookingDetails();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Fetch grooming booking details from API
  Future<Map<String, dynamic>?> getBookingDetails() async {
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    final String accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    if (accessToken.isEmpty || _application == null) {
      return null;
    }

    setState(() => _isLoading = true);

    try {
      BookingApi bookingApi = BookingApi(accessToken);
      Response<dynamic> response = await bookingApi.getGroomingDetails(
        _application!,
      );

      if (response.data == null) {
        throw Exception('No booking data received');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          context,
          'Failed to load grooming details: ${e.toString()}',
          color: AppColors.danger,
          fontSize: 12.0,
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Determine the next state based on current status
  String moveToNextState() {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    final currentStatus = arguments['currentStatus'];

    if (currentStatus == "confirmed") {
      return 'done';
    }

    if (currentStatus == "declined") {
      return 'declined';
    }

    if (currentStatus == "pending") {
      return 'confirmed';
    }

    return 'pending';
  }

  /// Render different action buttons based on booking status
  Widget actionsBasedOnCurrentStatus(Map booking) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    final currentStatus = arguments['currentStatus'];

    if (currentStatus == "confirmed") {
      return _buildAcceptedActionButtons(booking);
    }

    if (currentStatus == "declined") {
      return const SizedBox();
    }

    if (currentStatus == "pending") {
      return _buildActionButtons(booking);
    }

    return const SizedBox();
  }

  /// Update booking status (confirm, decline, or mark as done)
  Future<void> updateBookingStatus(String status, String id) async {
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    final String accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    setState(() => _isLoading = true);

    try {
      StaffApi staffApi = StaffApi(accessToken);
      UpdateBookingStatusPayload payload = UpdateBookingStatusPayload(
        status: status == 'declined' ? 'declined' : moveToNextState(),
        booking: id,
      );

      await staffApi.updateBookingStatus(payload);

      if (context.mounted) {
        // Success animation
        _animationController.reverse().then((_) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      SuccessScreen(redirectPath: "/s/main"),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        });
      }
    } on DioException catch (e) {
      if (context.mounted) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(
          e.response?.data ?? {'message': 'Unknown error occurred'},
        );
        showSnackBar(
          context,
          errorResponse.message,
          color: AppColors.danger,
          fontSize: 12.0,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          context,
          'An unexpected error occurred',
          color: AppColors.danger,
          fontSize: 12.0,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Confirmation dialog before updating booking status
  void confirmAction({
    required String message,
    required VoidCallback onConfirm,
  }) {
    execOnConfirm(message: message, method: onConfirm, context);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final owner = Profile.fromJson(arguments['profile']);
    final pet = Pet.infomrationJson(arguments['pet']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Grooming Preview",
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.secondary,
      body:
          _isLoading && _animationController.isDismissed
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        children: [
                          _buildOwnerInfoCard(owner),
                          const SizedBox(height: 16.0),
                          _buildPetInfoCard(pet),
                          const SizedBox(height: 16.0),
                          _buildGroomingDetailsCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  /// Owner information card widget
  Widget _buildOwnerInfoCard(Profile basicInfo) {
    return _AnimatedCard(
      delay: 100,
      child: CardContainer(
        title: "Owner Information",
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoField(
                    label: "Name",
                    value: basicInfo.basicInfo.fullName,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoField(
                    label: "Contact No.",
                    value: basicInfo.contact.number,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pet information card widget
  Widget _buildPetInfoCard(Pet pet) {
    return _AnimatedCard(
      delay: 200,
      child: CardContainer(
        title: "Pet Information",
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoField(label: "Name", value: pet.name),
                      const SizedBox(height: 8.0),
                      _InfoField(label: "Specie", value: pet.specie),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Grooming details card with actions widget
  Widget _buildGroomingDetailsCard() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _bookingDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return _AnimatedCard(
            delay: 300,
            child: CardContainer(
              title: "Error",
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading grooming details',
                    style: GoogleFonts.urbanist(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}), // Refresh
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Retry', style: GoogleFonts.urbanist()),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return _AnimatedCard(
            delay: 300,
            child: CardContainer(
              title: "Grooming",
              child: Text(
                'No grooming details available',
                style: GoogleFonts.urbanist(color: Colors.grey),
              ),
            ),
          );
        }

        // Extract grooming data safely
        final data = snapshot.data!;

        final scheduleTitle = data['schedule']?['title'] ?? 'Unknown Schedule';
        final additionalNotes = data['additionalNotes'] ?? 'None';

        return _AnimatedCard(
          delay: 300,
          child: CardContainer(
            title: "Grooming",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Grooming Request",
                  style: GoogleFonts.urbanist(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16.0),
                _GroomingDetailItem(
                  icon: Icons.schedule,
                  label: "Schedule Type",
                  value: scheduleTitle,
                ),
                if (additionalNotes != null)
                  _GroomingDetailItem(
                    icon: Icons.notes_outlined,
                    label: "Notes",
                    value: additionalNotes,
                  ),

                const SizedBox(height: 24.0),

                actionsBasedOnCurrentStatus(data),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Action buttons for accepting/declining booking
  Widget _buildActionButtons(Map booking) {
    String bookingId = booking['_id'];
    return Column(
      children: [
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () => confirmAction(
                    message: "Are you sure you want to accept this booking?",
                    onConfirm:
                        () => updateBookingStatus('confirmed', bookingId),
                  ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.greenAccent,
            disabledBackgroundColor: Colors.greenAccent.withOpacity(0.5),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : GestureDetector(
                        onTap:
                            () => updateBookingStatus('confirmed', bookingId),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Accept Booking',
                              style: GoogleFonts.urbanist(
                                color: AppColors.secondary,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        OutlinedButton(
          onPressed:
              _isLoading
                  ? null
                  : () => confirmAction(
                    message: "Are you sure you want to decline this booking?",
                    onConfirm: () => updateBookingStatus('declined', bookingId),
                  ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(
              color: AppColors.danger.withOpacity(0.7),
              width: 1.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Decline Booking",
                    style: GoogleFonts.urbanist(
                      color: AppColors.danger,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Action buttons for completed bookings
  Widget _buildAcceptedActionButtons(Map booking) {
    String bookingId = booking['_id'];
    return Column(
      children: [
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () => confirmAction(
                    message: "Are you sure you want to complete this booking?",
                    onConfirm: () => updateBookingStatus('done', bookingId),
                  ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.greenAccent,
            disabledBackgroundColor: Colors.greenAccent.withOpacity(0.5),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : GestureDetector(
                        onTap: () => updateBookingStatus('done', bookingId),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Done',
                              style: GoogleFonts.urbanist(
                                color: AppColors.secondary,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated card with slide and fade transition
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedCard({required this.child, this.delay = 0});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Container for information cards
class CardContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const CardContainer({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Field label and value pair
class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

/// Grooming detail item with icon
class _GroomingDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GroomingDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.urbanist(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.urbanist(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
