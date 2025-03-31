import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomerActivityLog extends StatefulWidget {
  const CustomerActivityLog({super.key});

  @override
  State<CustomerActivityLog> createState() => _CustomerActivityLogState();
}

class _CustomerActivityLogState extends State<CustomerActivityLog>
    with SingleTickerProviderStateMixin {
  // State
  String _accessToken = "";
  late AnimationController _animationController;
  late Animation<double> _animation;

  Future<dynamic> handleGetActivityLogs() async {
    ClientApi clientApi = ClientApi(_accessToken);
    Response<dynamic> response = await clientApi.getMeActivityLog();
    return response.data;
  }

  @override
  void initState() {
    super.initState();
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    // Setup animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Activity Log",
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger a refresh of the activity logs
          setState(() {});
        },
        child: FutureBuilder(
          future: handleGetActivityLogs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading activity logs',
                      style: GoogleFonts.roboto(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${snapshot.error}',
                      style: GoogleFonts.roboto(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      color: AppColors.primary,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No activity logs found',
                      style: GoogleFonts.roboto(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              snapshot.data[index]['description'],
                              style: GoogleFonts.roboto(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            subtitle: Text(
                              formatDate(
                                DateTime.parse(
                                  snapshot.data[index]['createdAt'],
                                ),
                              ),
                              style: GoogleFonts.roboto(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.history,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
