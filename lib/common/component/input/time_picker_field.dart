import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final Function(TimeOfDay) onChanged;
  final String? errorText;

  const TimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: value ?? TimeOfDay.now(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(alwaysUse24HourFormat: false),
                  child: child!,
                );
              },
            );
            if (time != null) {
              onChanged(time);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    errorText != null
                        ? context.colors.error
                        : context.colors.inputBorder,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.textStyles.caption1.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value?.format(context) ?? 'Select time',
                        style:
                            value == null
                                ? context.textStyles.body1.textHint
                                : context.textStyles.body1.textPrimary,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.access_time, color: context.colors.textHint),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(errorText!, style: context.textStyles.caption2.error),
          ),
      ],
    );
  }
}

class DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? errorText;
  final String placeholder;

  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.placeholder,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  errorText != null
                      ? context.colors.error
                      : context.colors.inputBorder,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(placeholder, style: context.textStyles.body1.textHint),
              items: items,
              onChanged: onChanged,
              style: context.textStyles.body1.textPrimary,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(errorText!, style: context.textStyles.caption2.error),
          ),
      ],
    );
  }
}
