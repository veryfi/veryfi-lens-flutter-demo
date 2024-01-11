import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreenWidget extends StatelessWidget {
  const LoadingScreenWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9ECE4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 120,
                child: Image.asset('assets/ic_veryfi_logo_black.PNG')),
            const Text('Please wait.. reading document.',
                style: TextStyle(fontSize: 20, color: Color(0xFF171C3A))),
            Lottie.asset('assets/loading_animation.json'),
          ],
        ),
      ),
    );
  }
}


