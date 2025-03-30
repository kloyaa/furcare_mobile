import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:furcare_app/screens/customer/customer_main.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:furcare_app/utils/const/colors.dart';

class OverTheCounter extends StatefulWidget {
  const OverTheCounter({super.key});

  @override
  _OverTheCounterState createState() => _OverTheCounterState();
}

class _OverTheCounterState extends State<OverTheCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Decoration
            Positioned.fill(
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  'assets/veterinary_pattern.jpg',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Lottie Illustration
                  FadeInUp(
                    child: Lottie.asset(
                      'assets/lady_walking_with_dog.json',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Animated Text
                  FadeInDown(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Please proceed \nto the counter for \nyour payment \n\nThank you!',
                          style: GoogleFonts.lilitaOne(
                            color: AppColors.primary,
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                blurRadius: 6.0,
                                color: Colors.black.withAlpha(40),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Animated Button with Hover Effect
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Add a brief haptic feedback
                        HapticFeedback.lightImpact();

                        // Navigate with a fade transition
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const CustomerMain(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        elevation: 10,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      child: Text(
                        'Finish',
                        style: GoogleFonts.urbanist(
                          color: AppColors.secondary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
