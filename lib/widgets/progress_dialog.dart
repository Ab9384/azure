
import 'package:flutter/material.dart';

import '../brand_colors.dart';

class ProgressDialog extends StatelessWidget {
  final String status;

  const ProgressDialog({Key? key, required this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 47, 47, 48),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircularProgressIndicator(
                color: BrandColors.primaryColor,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  status,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, color: BrandColors.primaryTextColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
