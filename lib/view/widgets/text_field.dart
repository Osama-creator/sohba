import 'package:flutter/material.dart';
import 'package:sohba/config/utils/colors.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final String labelText;
  final double width;
  final TextInputType? keyboardType;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final bool obscureText;
  final int? maxLength;
  final int maxLines;

  final String? Function(String?)? validator;

  const MyTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.labelText,
    this.onFieldSubmitted,
    this.keyboardType,
    this.width = double.infinity,
    this.obscureText = false,
    this.maxLength,
    this.onChanged,
    this.maxLines = 1,
    this.validator,
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: widget.maxLines < 1 ? MediaQuery.of(context).size.height * 0.055 : null,
        width: widget.width,
        child: TextFormField(
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          obscureText: isObscured && widget.obscureText,
          controller: widget.controller,
          onFieldSubmitted: widget.onFieldSubmitted ?? (_) => false,
          cursorColor: AppColors.primary,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            counterText: "",
            hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.grey,
                  fontSize: 15,
                ),
            labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.primary,
                  fontSize: 15,
                ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                  )
                : const SizedBox(),
          ),
          validator: widget.validator,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          cursorHeight: 25,
        ),
      ),
    );
  }
}
