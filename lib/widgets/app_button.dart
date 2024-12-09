import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isDisabled;
  final IconData? icon;

  const AppButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isDisabled = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define button styles based on the type
    Color getBackgroundColor() {
      if (isDisabled) return Colors.grey.shade300;

      switch (type) {
        case ButtonType.primary:
          return Colors.blue;
        case ButtonType.secondary:
          return Colors.grey.shade400;
        case ButtonType.danger:
          return Colors.red;
        case ButtonType.warning:
          return Colors.amber;
        case ButtonType.success:
          return Colors.green;
        case ButtonType.info:
          return Colors.teal;
        case ButtonType.link:
          return Colors.transparent;
        default:
          return Colors.blue;
      }
    }

    Color getTextColor() {
      if (type == ButtonType.link) return Colors.blue;
      return isDisabled ? Colors.grey : Colors.white;
    }

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          elevation: type == ButtonType.link ? 0 : 2,
          shadowColor: type == ButtonType.link ? Colors.transparent : null,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: getTextColor(),
                size: 20,
              ),
            if (icon != null)
              const SizedBox(width: 8), // Space between icon and text
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: getTextColor(),
                decoration:
                    type == ButtonType.link ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ButtonType {
  primary,
  secondary,
  danger,
  warning,
  success,
  info,
  link,
}
