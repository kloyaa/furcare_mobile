import 'dart:io';
import 'package:flutter/material.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class UploadQR extends StatefulWidget {
  final String paymentMethod;
  final String referenceNo;
  final String date;

  const UploadQR({
    super.key,
    required this.paymentMethod,
    required this.referenceNo,
    required this.date,
  });

  @override
  State<UploadQR> createState() => _UploadQRState();
}

class _UploadQRState extends State<UploadQR> {
  final TextEditingController _refController = TextEditingController();
  late FocusNode _refFocus;
  bool _isUploading = false;

  File? _selectedImage;

  Future<void> _selectImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compressed for better performance
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      _showErrorSnackbar("Permission denied: ${e.message}");
    } catch (e) {
      _showErrorSnackbar("Error selecting image");
    }
  }

  Future<void> _captureImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      _showErrorSnackbar("Permission denied: ${e.message}");
    } catch (e) {
      _showErrorSnackbar("Error capturing image");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitPayment() async {
    if (_selectedImage == null) {
      _showErrorSnackbar("Please upload a proof of payment first");
      return;
    }

    if (_refController.text.isEmpty) {
      _showErrorSnackbar("Please enter a reference number");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isUploading = false;
    });

    // Show success dialog before navigation
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
            ),
            title: Text(
              "Payment Successful",
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  "Your payment has been successfully recorded. Thank you!",
                  style: GoogleFonts.urbanist(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, "/c/main");
                },
                child: Text(
                  "Continue",
                  style: GoogleFonts.urbanist(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refFocus = FocusNode();
    _refController.text = widget.referenceNo;
  }

  @override
  void dispose() {
    _refFocus.dispose();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Payment via ${widget.paymentMethod}",
          style: GoogleFonts.urbanist(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Payment Details Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Details",
                          style: GoogleFonts.urbanist(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow("Payment Method", widget.paymentMethod),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          "Date",
                          formatDate(DateTime.parse(widget.date)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Upload Section
                Text(
                  "Upload Proof of Payment",
                  style: GoogleFonts.urbanist(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // Image Upload Area
                Container(
                  height: screenSize.height * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    border: Border.all(
                      color:
                          _selectedImage != null
                              ? AppColors.primary
                              : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: _selectImage,
                    child:
                        _selectedImage != null
                            ? GestureDetector(
                              onTap: () {
                                // Show image in a lightbox when tapped
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.black.withOpacity(0.9),
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.zero,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Full screen image with zoom capability
                                          InteractiveViewer(
                                            panEnabled: true,
                                            boundaryMargin: EdgeInsets.all(20),
                                            minScale: 0.5,
                                            maxScale: 4.0,
                                            child: Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          // Close button
                                          Positioned(
                                            top: 20,
                                            right: 20,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.defaultBorderRadius,
                                ),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            )
                            : Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(
                                AppConstants.defaultPadding,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 64,
                                    color: AppColors.primary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Tap to upload \nproof of payment",
                                    style: GoogleFonts.urbanist(
                                      color: AppColors.primary.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 16),

                // Camera and Gallery Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: Text("Camera", style: GoogleFonts.urbanist()),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectImage,
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: Text("Gallery", style: GoogleFonts.urbanist()),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reference Number Field
                Text(
                  "Reference Number",
                  style: GoogleFonts.urbanist(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: TextFormField(
                    controller: _refController,
                    focusNode: _refFocus,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: AppColors.primary,
                      hintText: "Enter reference number",
                      hintStyle: GoogleFonts.urbanist(
                        color: AppColors.primary.withOpacity(0.5),
                        fontSize: 14.0,
                      ),
                      prefixIcon: Icon(
                        Icons.numbers_outlined,
                        size: 20.0,
                        color: AppColors.primary.withOpacity(0.8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    style: GoogleFonts.urbanist(
                      color: AppColors.primary,
                      fontSize: 14.0,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(
                        0.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isUploading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Submit Payment',
                              style: GoogleFonts.urbanist(
                                color: AppColors.secondary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14.0,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
