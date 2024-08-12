import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, this.pickedImage, this.isLoading = false});

  final Uint8List? pickedImage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
        image: pickedImage != null
            ? DecorationImage(
                fit: BoxFit.cover,
                image: Image.memory(
                  pickedImage!,
                  fit: BoxFit.cover,
                ).image,
              )
            : null,
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.person_rounded,
                size: 50,
                color: Colors.black38,
              ),
      ),
    );
  }
}
