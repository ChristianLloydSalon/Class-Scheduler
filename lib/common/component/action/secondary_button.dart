import 'package:flutter/material.dart';
import 'package:scheduler/common/component/communication/custom_loading_indicator.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.state = SecondaryButtonState.idle,
  });

  final void Function() onPressed;
  final String text;
  final double? width;
  final SecondaryButtonState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color:
                state.isDisabled
                    ? context.colors.primary
                    : context.colors.textPrimary,
          ),
          foregroundColor:
              state.isDisabled
                  ? context.colors.textHint
                  : context.colors.textPrimary,
          backgroundColor: context.colors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          if (state.isDisabled) return;

          onPressed.call();
        },
        child:
            state == SecondaryButtonState.loading
                ? CustomLoadingIndicator(
                  color:
                      state.isDisabled
                          ? context.colors.textHint
                          : context.colors.textPrimary,
                )
                : Text(text, style: context.textStyles.caption2.textPrimary),
      ),
    );
  }
}

enum SecondaryButtonState {
  idle,
  loading,
  disabled;

  bool get isIdle => this == idle;
  bool get isLoading => this == loading;
  bool get isDisabled => this == disabled;
}
