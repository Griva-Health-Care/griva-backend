import 'package:flutter/material.dart';

class VulvoscopyForm extends StatelessWidget {
  const VulvoscopyForm({super.key});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    double bodyH = vh * 0.55;
    if (bodyH < 320) bodyH = 320;
    if (bodyH > 720) bodyH = 720;
    final ScrollController ctrl = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: bodyH,
          child: Scrollbar(
            controller: ctrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: ctrl,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Vulvoscopy Report',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(child: Text('Coming soon')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


