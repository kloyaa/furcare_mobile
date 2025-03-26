import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/branch_api.dart';
import 'package:furcare_app/models/branch_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Assuming you have a Branch model

class BranchesList extends StatefulWidget {
  const BranchesList({super.key});

  @override
  State<BranchesList> createState() => _BranchesListState();
}

class _BranchesListState extends State<BranchesList> {
  List<Branch> branches = [];
  bool isLoading = true;
  String? errorMessage;
  String _accessToken = "";

  @override
  void initState() {
    super.initState();

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    fetchBranches();
  }

  Future<void> fetchBranches() async {
    try {
      // Assuming BranchApi is already defined
      BranchApi branchApi = BranchApi(_accessToken);
      Response response = await branchApi.getBranches();

      setState(() {
        branches =
            (response.data as List)
                .map((branchJson) => Branch.fromJson(branchJson))
                .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load branches';
        isLoading = false;
      });
    }
  }

  void _showBranchDetails(Branch branch) {
    print(branch.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => BranchDetailsSheet(branch: branch),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.blue.shade300),
              )
              : errorMessage != null
              ? Center(child: Text(errorMessage!, style: GoogleFonts.poppins()))
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 50,
                ),
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return BranchListItem(
                        branch: branch,
                        onTap: () => _showBranchDetails(branch),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                      .slideX(begin: 0.1, end: 0);
                },
              ),
    );
  }
}

class BranchListItem extends StatelessWidget {
  final Branch branch;
  final VoidCallback onTap;

  const BranchListItem({super.key, required this.branch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.secondary,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          branch.name,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          branch.address,
          style: GoogleFonts.roboto(fontSize: 12, color: AppColors.primary),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: branch.isActive ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            branch.isActive ? 'Open' : 'Closed',
            style: GoogleFonts.poppins(
              color: branch.isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class BranchDetailsSheet extends StatelessWidget {
  final Branch branch;

  const BranchDetailsSheet({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            branch.name,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            text: branch.address,
          ),
          _buildDetailRow(icon: Icons.phone_outlined, text: branch.mobileNo),
          _buildDetailRow(
            icon: Icons.verified_outlined,
            text: branch.isActive ? 'Active' : 'Closed',
            color: branch.isActive ? Colors.green : Colors.red,
          ),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            text: 'Created: ${_formatDate(branch.createdAt)}',
          ),
          const SizedBox(height: 20),
          Center(
            child: Opacity(
              opacity: branch.isActive ? 1 : 0.2,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: TapRegion(
                    enabled: branch.isActive,
                    child: Text(
                      branch.isActive
                          ? 'Select Branch'
                          : 'Closed, Please Come back next time',
                      style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.5, end: 0);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.black54, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                color: color ?? Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
