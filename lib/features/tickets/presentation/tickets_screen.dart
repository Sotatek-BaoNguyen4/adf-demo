import 'package:flutter/material.dart';

/// Placeholder screen for the Tickets branch.
///
/// Real booking flow is out of scope for MVP — this stub satisfies the
/// navigation shell requirement (phase 05) without exposing any auth-gated data.
class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets')),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
