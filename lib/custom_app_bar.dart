import 'dart:async';

import 'package:flutter/material.dart';
import 'services/network_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Key? infoIconKey;
  final String? userEmail;
  final List<Widget>? extraActions;
  final Widget? title;

  const CustomAppBar({
    super.key,
    this.infoIconKey,
    this.userEmail,
    this.extraActions,
    this.title,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isConnected = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkConnection());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final status = await NetworkService.checkColposcopeConnection();
    if (mounted) {
      setState(() {
        _isConnected = status == ColposcopeConnectionStatus.connected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const _purple = Color(0xFF8B44F7);
    final iconColor = _isConnected ? _purple : Colors.red[400]!;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.purple),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: widget.title ??
          Container(
            padding: const EdgeInsets.all(4),
            child: Image.asset('assets/images/griva_bg.png', height: 36),
          ),
      actions: [
        IconButton(
          key: widget.infoIconKey,
          icon: Icon(Icons.precision_manufacturing, color: iconColor),
          onPressed: () {
            bool showDeviceSetup = false;
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.4),
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        if (_isConnected) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3EDFC),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF8B44F7), size: 32),
                                ),
                                const SizedBox(height: 20),
                                const Text('Connected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your device is connected to Griva Colposcope and ready for examination.',
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B44F7),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Done'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return showDeviceSetup
                            ? Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3EDFC),
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: const Icon(Icons.usb_rounded, color: Color(0xFF8B44F7), size: 32),
                                        ),
                                        const SizedBox(height: 24),
                                        const Text('Device Setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black), textAlign: TextAlign.center),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Please complete the following steps to prepare your Colposcope device for connection.',
                                          style: TextStyle(fontSize: 15, color: Colors.black87),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        _setupStep(Icons.power_settings_new, 'Power On Device', 'Press the power button on your Colposcope device'),
                                        const SizedBox(height: 12),
                                        _setupStep(Icons.wifi, 'Enable Hotspot', 'Ensure the blue light is visible on the device'),
                                        const SizedBox(height: 18),
                                        const Text(
                                          'Once both steps are complete, tap the button below to open network settings and connect to your device',
                                          style: TextStyle(fontSize: 13, color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await NetworkService.openSpecificNetworkSettings(NetworkType.wifi);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF8B44F7),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('Open Network Settings'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.black45),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3EDFC),
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: const Icon(Icons.usb_rounded, color: Color(0xFF8B44F7), size: 32),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text('Connect to Colposcope?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black), textAlign: TextAlign.center),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'You need to connect to Griva Colposcope to begin the examination. Would you like to do it now?',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: Colors.grey.shade300),
                                              foregroundColor: Colors.black87,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('Do it Later'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => setState(() => showDeviceSetup = true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF8B44F7),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('Connect Now'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        ...widget.extraActions ?? [],
      ],
    );
  }

  Widget _setupStep(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B44F7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
