import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sohba/config/utils/colors.dart';

ThemeData getThemDataLight() => ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: AppColors.white,
      primaryColor: AppColors.primary,
      textSelectionTheme: const TextSelectionThemeData(selectionHandleColor: AppColors.primary),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          )),
          textStyle: MaterialStateProperty.all<TextStyle>(
            GoogleFonts.cairo(
              fontSize: 16.0,
              color: AppColors.black,
            ),
          ),
          backgroundColor: const MaterialStatePropertyAll(AppColors.primary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            textStyle: GoogleFonts.cairo(
              fontSize: 16.0,
            ),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
      cardTheme: const CardTheme(color: Colors.white70),
      dividerColor: AppColors.black,
      textTheme: TextTheme(
          displayMedium: GoogleFonts.cairo(fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.primary),
          displaySmall: GoogleFonts.cairo(
            fontSize: 14.0.sp,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: GoogleFonts.cairo(
            fontSize: 34.0.sp,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: GoogleFonts.cairo(
            fontSize: 30.0.sp,
            fontWeight: FontWeight.normal,
          ),
          titleLarge: GoogleFonts.cairo(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: GoogleFonts.cairo(
            fontSize: 20.sp,
          ),
          bodyMedium: GoogleFonts.cairo(
            fontSize: 18.sp,
          ),
          displayLarge: GoogleFonts.cairo(
            fontSize: 14.sp,
          ),
          bodySmall: GoogleFonts.cairo(
            fontSize: 14.0.sp,
          ),
          labelLarge: TextStyle(
            fontSize: 14.0.sp,
          )),
    );
