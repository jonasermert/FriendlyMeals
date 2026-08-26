import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/core/theme/app_radius.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

class LiveAssistantScreen extends StatefulWidget {
  const LiveAssistantScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  State<LiveAssistantScreen> createState() => _LiveAssistantScreenState();
}

class _LiveAssistantScreenState extends State<LiveAssistantScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraDescription? _camera;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('none', 'Keine Kamera');
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _camera = backCamera;
      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException {
      if (mounted) {
        setState(
          () => _error =
              'Kamera- und Mikrofonzugriff werden für den Assistenten benötigt.',
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive &&
        controller != null &&
        controller.value.isInitialized) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && _camera != null) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => context.go('/recipes/${widget.recipeId}'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Expanded(
                    child: Text(
                      'Live-Kochassistent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: ColoredBox(
                    color: const Color(0xFF111827),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_controller?.value.isInitialized ?? false)
                          CameraPreview(_controller!)
                        else if (_error != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          )
                        else
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.tealBright,
                            ),
                          ),
                        const Align(
                          alignment: Alignment.bottomCenter,
                          child: ColoredBox(
                            color: Color(0xAA000000),
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: Text(
                                'Richte die Kamera auf dein Gericht und stelle Fragen.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
