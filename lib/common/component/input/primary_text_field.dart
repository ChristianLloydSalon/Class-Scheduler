import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class PrimaryTextField extends HookWidget {
  const PrimaryTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.hintText,
    this.errorText,
    this.validator,
    this.onSaved,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final isObscured = useState(true);

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      onSaved: onSaved,
      obscureText: obscureText && isObscured.value,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: context.textStyles.body2.textPrimary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: context.textStyles.body2.textHint,
        errorText: errorText,
        errorStyle: context.textStyles.caption3.error,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: context.colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.error),
        ),
        suffixIcon:
            obscureText
                ? IconButton(
                  icon: Icon(
                    isObscured.value ? Icons.visibility_off : Icons.visibility,
                    color: context.colors.textHint,
                  ),
                  onPressed: () {
                    isObscured.value = !isObscured.value;
                  },
                )
                : null,
      ),
    );
  }
}
