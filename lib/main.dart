import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/branch.dart';
import 'package:furcare_app/providers/fees.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/admin/reports/screen_checkins.dart';
import 'package:furcare_app/screens/admin/reports/screen_service_usage.dart';
import 'package:furcare_app/screens/admin/reports/screen_transactions.dart';
import 'package:furcare_app/screens/admin/screen_customer_management.dart';
import 'package:furcare_app/screens/admin/screen_profile.dart';
import 'package:furcare_app/screens/admin/screen_staff_edit.dart';
import 'package:furcare_app/screens/admin/screen_staff_enrollment.dart';
import 'package:furcare_app/screens/admin/screen_staff_management.dart';
import 'package:furcare_app/screens/auth/admin_login.dart';
import 'package:furcare_app/screens/auth/registration/customer_registration.dart';
import 'package:furcare_app/screens/auth/staff_login.dart';
import 'package:furcare_app/screens/booking/board.dart';
import 'package:furcare_app/screens/booking/grooming.dart';
import 'package:furcare_app/screens/booking/transit.dart';
import 'package:furcare_app/screens/branch/branch.dart';
import 'package:furcare_app/screens/customer/create_profile/create_new_pet.dart';
import 'package:furcare_app/screens/customer/create_profile/create_pet_profile.dart';
import 'package:furcare_app/screens/customer/create_profile/create_profile_1.dart';
import 'package:furcare_app/screens/customer/create_profile/create_profile_2.dart';
import 'package:furcare_app/screens/customer/customer_activity_log.dart';
import 'package:furcare_app/screens/customer/customer_main.dart';
import 'package:furcare_app/screens/customer/edit/edit_owner_profile.dart';
import 'package:furcare_app/screens/customer/edit/edit_profile_step_1.dart';
import 'package:furcare_app/screens/others/setup.dart';
import 'package:furcare_app/screens/staff/screen_dashboard.dart';
import 'package:furcare_app/screens/staff/screen_edit_profile_1.dart';
import 'package:furcare_app/screens/staff/screen_edit_profile_2.dart';
import 'package:furcare_app/screens/staff/tabs/preview/boarding.dart';
import 'package:furcare_app/screens/staff/tabs/preview/grooming.dart';
import 'package:furcare_app/screens/staff/tabs/preview/transit.dart';
import 'package:furcare_app/screens/staff/tabs/preview_inprogress_bookings/boarding.dart';
import 'package:furcare_app/screens/staff/tabs/preview_inprogress_bookings/grooming.dart';
import 'package:furcare_app/screens/staff/tabs/preview_inprogress_bookings/transit.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/app_theme.dart';
import 'package:furcare_app/utils/logger.util.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/screens/auth/customer_login.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.time}: ${record.level.name}: ${record.message}');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/success.gif'), context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthTokenProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => FeesProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.loginAdmin,
        routes: _buildAppRoutes(),
        navigatorObservers: [RouteLoggingObserver()],
        onGenerateRoute: (settings) {
          if (kDebugMode) {
            print('Generating route: ${settings.name}');
          }
          return null;
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      AppRoutes.login: (context) => const CustomerLogin(),
      AppRoutes.loginStaff: (context) => const StaffLogin(),
      AppRoutes.loginAdmin: (context) => const ScreenAdminLogin(),

      AppRoutes.branches: (context) => const BranchesList(),

      // Customer routes
      AppRoutes.customerActivity: (context) => const CustomerActivityLog(),
      AppRoutes.customerMain: (context) => const CustomerMain(),
      AppRoutes.customerRegister: (context) => const CustomerRegister(),
      AppRoutes.editProfileStep1: (context) => const EditProfileStep1(),
      AppRoutes.createProfileStep1: (context) => const CreateProfileStep1(),
      AppRoutes.createProfileStep2: (context) => const CreateProfileStep2(),
      AppRoutes.editOwnerProfile: (context) => const EditOwner(),
      AppRoutes.createPetProfile: (context) => const CreatePet(),
      AppRoutes.addNewPet: (context) => const AddNewPet(),

      // Booking routes
      AppRoutes.bookBoarding: (context) => const BookBoarding(),
      AppRoutes.bookTransit: (context) => const HomeServiceScreen(),
      AppRoutes.bookGrooming: (context) => const BookGroomingScreen(),

      //others
      AppRoutes.setupAnimation:
          (context) => const ProfileSetupAnimation(redirectPath: "/"),

      // Staff
      AppRoutes.staffMain: (context) => const StaffMain(),
      AppRoutes.staffEditProfileStep1:
          (context) => const StaffEditProfileStep1(),
      AppRoutes.staffEditProfileStep2:
          (context) => const StaffEditProfileStep2(),

      AppRoutes.previewBoarding: (context) => const PreviewBoarding(),
      AppRoutes.previewTransit: (context) => const PreviewTransit(),
      AppRoutes.previewGrooming: (context) => const PreviewGrooming(),

      AppRoutes.previewInprogressBoarding:
          (context) => const PreviewInprogressBoarding(),
      AppRoutes.previewInprogressTransit:
          (context) => const PreviewInprogressTransit(),
      AppRoutes.previewInprogressGrooming:
          (context) => const PreviewInprogressGrooming(),

      // Admin
      AppRoutes.adminStaffManagement: (context) => const AdminStaffManagement(),
      AppRoutes.adminStaffEnrollment: (context) => const AdminStaffEnrollment(),
      AppRoutes.adminStaffEdit: (context) => const AdminStaffEdit(),
      AppRoutes.adminCustomerManagement:
          (context) => const AdminCustomerManagement(),

      AppRoutes.reportCheckins: (context) => const Checkins(),
      AppRoutes.reportServiceUsage: (context) => const ServiceUsage(),
      AppRoutes.reportTransactions: (context) => const Transactions(),

      AppRoutes.adminProfile: (context) => const AdminProfile(),
    };
  }
}

class AppRoutes {
  static const String login = '/';
  static const String loginStaff = '/auth/staff';
  static const String loginAdmin = '/auth/admin';

  static const String branches = '/branches';

  // Customer routes
  static const String customerActivity = '/c/activity';
  static const String customerMain = '/c/main';
  static const String customerRegister = '/c/register';
  static const String editProfileStep1 = '/c/edit/profile/1';
  static const String createProfileStep1 = '/c/create/profile/1';
  static const String createProfileStep2 = '/c/create/profile/2';
  static const String editOwnerProfile = '/c/edit/profile/owner';
  static const String createPetProfile = '/c/create/profile/pet';
  static const String addNewPet = '/c/add/pet';

  // Booking routes
  static const String bookBoarding = '/book/boarding';
  static const String bookTransit = '/book/transit';
  static const String bookGrooming = '/book/grooming';

  // Setup
  static const String setupAnimation = '/setup/animation';

  // Staff routes
  static const String staffMain = '/s/main';
  static const String staffEditProfileStep1 = '/s/edit/profile/1';
  static const String staffEditProfileStep2 = '/s/edit/profile/2';

  static const String previewBoarding = '/s/preview/boarding';
  static const String previewTransit = '/s/preview/transit';
  static const String previewGrooming = '/s/preview/grooming';

  static const String previewInprogressBoarding =
      '/s/preview-inprogress/boarding';
  static const String previewInprogressTransit =
      '/s/preview-inprogress/transit';
  static const String previewInprogressGrooming =
      '/s/preview-inprogress/grooming';

  // Admin routes
  static const String adminStaffManagement = '/a/management/staff';
  static const String adminStaffEnrollment = '/a/management/staff/enrollment';
  static const String adminStaffEdit = '/a/management/staff/edit';
  static const String adminCustomerManagement = '/a/management/customers';

  static const String reportCheckins = '/a/report/checkins';
  static const String reportServiceUsage = '/a/report/service-usage';
  static const String reportTransactions = '/a/report/transactions';

  static const String adminProfile = '/a/profile';
}
