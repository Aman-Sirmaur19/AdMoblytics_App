import 'package:flutter/material.dart';

class InternetConnectivityButton extends StatefulWidget {
  final void Function() onPressed;

  const InternetConnectivityButton({super.key, required this.onPressed});

  @override
  State<InternetConnectivityButton> createState() =>
      _InternetConnectivityButtonState();
}

class _InternetConnectivityButtonState
    extends State<InternetConnectivityButton> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(5),
      children: [
        const SizedBox(height: 200),
        const Text(
          'ᯤ Network Error ᯤ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 2,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Pull down to Refresh\n\nOR',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              fixedSize: const Size(64, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                letterSpacing: 1,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
