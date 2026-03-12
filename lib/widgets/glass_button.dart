import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 250,
    this.height = 60,
    this.borderRadius = 20.0,
    this.blurSigma = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.textStyle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = textStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        );

    final bool isDisabled = onPressed == null || isLoading;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        // Aquí ajustas qué tan "borroso" se ve el video detrás del botón
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            // Un blanco muy transparente con borde sutil
            color: isDisabled
                ? (backgroundColor ?? Colors.white.withValues(alpha: 0.05))
                : (backgroundColor ?? Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDisabled
                  ? (borderColor ?? Colors.white.withValues(alpha: 0.05))
                  : (borderColor ?? Colors.white.withValues(alpha: 0.2)),
              width: 1.5,
            ),
          ),
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: isDisabled ? Colors.white54 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: EdgeInsets.zero,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: effectiveTextStyle.copyWith(
                      color: isDisabled
                          ? Colors.white54
                          : effectiveTextStyle.color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
