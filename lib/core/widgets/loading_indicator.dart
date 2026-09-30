import 'package:flutter/material.dart';
import 'logo_loading_indicator.dart';

/// Reusable center loading indicator featuring Govi Mithuru stationary rectangle with traveling gap animation
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double logoSize;
  final double boxWidth;
  final double boxHeight;

  const LoadingIndicator({
    super.key,
    this.message,
    this.logoSize = 75.0,
    this.boxWidth = 170.0,
    this.boxHeight = 105.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LogoLoadingIndicator(
            logoSize: logoSize,
            boxWidth: boxWidth,
            boxHeight: boxHeight,
          ),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
