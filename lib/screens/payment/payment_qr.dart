import 'dart:io';
import 'package:flutter/material.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _selectedImage;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _refFocus = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _refFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.paymentMethod,
          style: GoogleFonts.urbanist(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            GestureDetector(
              onTap: () {
                _selectImage();
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child:
                    _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.fill)
                        : Image.asset(
                          "assets/image_placeholder.png",
                          fit: BoxFit.cover,
                        ),
              ),
            ),
            const SizedBox(height: 40.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextFormField(
                controller: _refController,
                focusNode: _refFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: AppColors.primary,
                  labelText: "Reference No.",
                  labelStyle: GoogleFonts.urbanist(
                    color: AppColors.primary.withOpacity(0.5),
                    fontSize: 10.0,
                  ),
                  prefixIcon: Icon(
                    Icons.numbers_outlined,
                    size: 18.0,
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                  prefixIconColor: AppColors.primary,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                ),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            Text(
              "Transaction Date ${formatDate(DateTime.parse(widget.date))}",
              style: GoogleFonts.urbanist(
                color: AppColors.primary.withOpacity(0.6),
                fontSize: 8.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(flex: 3),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacementNamed(context, "/c/main");
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    'Finish',
                    style: GoogleFonts.urbanist(
                      color: AppColors.secondary,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
