import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/extensions.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class CustomerTabPets extends StatefulWidget {
  const CustomerTabPets({super.key});

  @override
  State<CustomerTabPets> createState() => _CustomerTabPetsState();
}

class _CustomerTabPetsState extends State<CustomerTabPets> {
  String _accessToken = "";
  List<dynamic> _pets = [];
  bool _isLoading = true;

  Future<void> _fetchPets() async {
    try {
      ClientApi clientApi = ClientApi(_accessToken);
      Response<dynamic> response = await clientApi.getMePets();

      setState(() {
        _pets = response.data;
        _isLoading = false;
      });
    } on DioException {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
    _fetchPets();
  }

  void _navigateToAddPet() {
    Navigator.of(context).pushNamed("/c/add/pet");
  }

  void _showPetDetails(dynamic pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => PetDetailsSheet(pet: pet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPet,
        backgroundColor: AppColors.primary,
        child: const Icon(Ionicons.add_outline, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPets,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _isLoading
                ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
                : _pets.isEmpty
                ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Ionicons.paw_outline,
                          size: 80,
                          color: AppColors.primary.withAlpha(200),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No pets found',
                          style: GoogleFonts.urbanist(
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _navigateToAddPet,
                          child: Text('Add Your First Pet'),
                        ),
                      ],
                    ),
                  ),
                )
                : SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final pet = _pets[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: PetListItem(
                              pet: pet,
                              onTap: () => _showPetDetails(pet),
                            )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                            .slideX(begin: 0.1, end: 0),
                      );
                    }, childCount: _pets.length),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class PetListItem extends StatelessWidget {
  final dynamic pet;
  final VoidCallback onTap;

  const PetListItem({super.key, required this.pet, required this.onTap});

  Widget _buildDetailChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.urbanist(
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      pet['gender'] == "male"
                          ? Colors.blueGrey.shade100
                          : Colors.pink.shade100,
                  child: Icon(
                    Ionicons.paw,
                    color:
                        pet['gender'] == "male" ? Colors.blueGrey : Colors.pink,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${pet['name']}",
                        style: GoogleFonts.urbanist(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildDetailChip(
                            icon:
                                pet['gender'] == "male"
                                    ? Ionicons.male
                                    : Ionicons.female,
                            text: pet['gender'],
                          ),
                          const SizedBox(width: 10),
                          _buildDetailChip(
                            icon: Ionicons.calendar_number_outline,
                            text: pet['age'].toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Ionicons.chevron_forward,
                  color: AppColors.primary.withAlpha(200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PetDetailsSheet extends StatelessWidget {
  final dynamic pet;

  const PetDetailsSheet({super.key, required this.pet});

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.urbanist(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value.capitalize(),
                  style: GoogleFonts.urbanist(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor:
                  pet['gender'] == "male"
                      ? Colors.blueGrey.shade100
                      : Colors.pink.shade100,
              child: Icon(
                Ionicons.paw,
                size: 60,
                color: pet['gender'] == "male" ? Colors.blueGrey : Colors.pink,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "${pet['name']}",
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            icon: pet['gender'] == "male" ? Ionicons.male : Ionicons.female,
            label: 'Gender',
            value: pet['gender'],
          ),
          _buildDetailRow(
            icon: Ionicons.calendar_number_outline,
            label: 'Age',
            value: pet['age'].toString(),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),

                child: Text('Close'),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.5, end: 0);
  }
}
