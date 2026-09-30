import 'package:flutter/material.dart';
import 'logo_loading_indicator.dart';

/// Reusable center loading indicator featuring Govi Mithuru custom rotating box animation
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double logoSize;
  final double boxSize;

  const LoadingIndicator({
    super.key,
    this.message,
    this.logoSize = 75.0,
    this.boxSize = 135.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LogoLoadingIndicator(
            logoSize: logoSize,
            boxSize: boxSize,
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
