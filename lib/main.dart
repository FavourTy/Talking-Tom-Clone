import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';

void main() {
  runApp(const TalkingTomApp());
}

class TalkingTomApp extends StatelessWidget {
  const TalkingTomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: MaterialApp(
        title: 'Talking Tom Clone',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const TalkingTomHomePage(),
      ),
    );
  }
}

class TalkingTomHomePage extends StatefulWidget {
  const TalkingTomHomePage({super.key});

  @override
  State<TalkingTomHomePage> createState() => _TalkingTomHomePageState();
}

class _TalkingTomHomePageState extends State<TalkingTomHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    
    // Setup animation controller for character animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    setState(() {
      _permissionGranted = status.isGranted;
    });
    
    if (!_permissionGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for this app to work'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.idle:
        return Colors.blue;
      case PlayerState.listening:
        return Colors.green;
      case PlayerState.talking:
        return Colors.orange;
    }
  }

  String _getStateText(PlayerState state) {
    switch (state) {
      case PlayerState.idle:
        return 'Idle - Waiting for voice...';
      case PlayerState.listening:
        return 'Listening...';
      case PlayerState.talking:
        return 'Talking!';
    }
  }

  IconData _getStateIcon(PlayerState state) {
    switch (state) {
      case PlayerState.idle:
        return Icons.sentiment_neutral;
      case PlayerState.listening:
        return Icons.hearing;
      case PlayerState.talking:
        return Icons.record_voice_over;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talking Tom Clone'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<GameController>(
        builder: (context, gameController, child) {
          // Trigger animation based on state
          if (gameController.playerState == PlayerState.talking) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.reset();
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_permissionGranted)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.redAccent,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Microphone permission required!',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Character representation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _getStateColor(gameController.playerState),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getStateColor(gameController.playerState).withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getStateIcon(gameController.playerState),
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // State indicator
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Text(
                      _getStateText(gameController.playerState),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _getStateColor(gameController.playerState),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Instructions
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Speak to the character and it will listen and repeat what you said!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
