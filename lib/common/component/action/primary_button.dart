import 'package:flutter/material.dart';
import 'package:scheduler/common/component/communication/custom_loading_indicator.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.state = PrimaryButtonState.idle,
  });

  final void Function() onPressed;
  final String text;
  final double? width;
  final PrimaryButtonState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              state.isDisabled
                  ? context.colors.textHint
                  : context.colors.primary,
          foregroundColor: context.colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          if (state.isDisabled) return;

          onPressed.call();
        },
        child:
            state == PrimaryButtonState.loading
                ? const CustomLoadingIndicator()
                : Text(text, style: context.textStyles.caption2.surface),
      ),
    );
  }
}

enum PrimaryButtonState {
  idle,
  loading,
  disabled;

  bool get isIdle => this == idle;
  bool get isLoading => this == loading;
  bool get isDisabled => this == disabled;
}
