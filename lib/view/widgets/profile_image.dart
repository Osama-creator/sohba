import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sohba/config/utils/colors.dart';

// ignore: must_be_immutable
class ProfileImage extends StatefulWidget {
  ProfileImage({
    super.key,
    required this.onChanged,
    required this.profileImage,
  });
  final ValueChanged<File?> onChanged;
  File? profileImage;

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    return InkWell(
      onTap: () async {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            widget.profileImage = File(image.path);
            widget.onChanged(widget.profileImage);
          });
        }
      },
      child: CircleAvatar(
        radius: 100,
        backgroundColor: AppColors.primary,
        backgroundImage: widget.profileImage != null ? FileImage(widget.profileImage!) : null,
        child: widget.profileImage == null
            ? Icon(
                Icons.person,
                size: 80.sp,
                color: AppColors.white,
              )
            : null,
      ),
    );
  }
}
