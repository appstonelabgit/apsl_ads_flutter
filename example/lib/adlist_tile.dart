import 'package:flutter/material.dart';

class AdListTile extends StatelessWidget {
  final String networkName;
  final VoidCallback onTap;
  const AdListTile({super.key, required this.networkName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        networkName,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
