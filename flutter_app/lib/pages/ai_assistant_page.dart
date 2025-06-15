import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rive/rive.dart';
import '../main.dart'; // For RecipeScreen
import '../services/ai_assistant_service.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  // Animation and UI state
  RiveAnimationController? _talkController;
  SMIInput<bool>? _isTalkingInput;
  
  // Audio and WebSocket
  WebSocketChannel? _rtChannel;
  AudioPlayer? _ttsPlayer;
  bool _isListening = false;
  bool _isConnected = false;
  bool _hasPermission = false;
  
  // UI state
  String _subtitle = 'How can I help you today?';
  String _status = 'Ready';
  String? _error;
  
  // Configuration - Set these in production
  static const String _defaultApiKey = 'YOUR_OPENAI_API_KEY';
  static const String _defaultAssistantId = 'YOUR_ASSISTANT_ID';
  
  @override
  void initState() {
    super.initState();
    _configureService();
    _initializeAudio();
    _requestPermissions();
  }

  void _configureService() {
    // Configure the AI Assistant service
    // In production, these should come from secure storage or environment variables
    AIAssistantService.configure(
      apiKey: _defaultApiKey,
      assistantId: _defaultAssistantId,
    );
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  void _cleanup() {
    _rtChannel?.sink.close();
    _ttsPlayer?.dispose();
    FlutterAudioCapture().stop();
  }

  Future<void> _initializeAudio() async {
    try {
      _ttsPlayer = AudioPlayer();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize audio: $e';
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // For web, assume permission is granted for now
      // In a real app, you'd handle platform-specific permission requests
      setState(() {
        _hasPermission = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Permission error: $e';
        _hasPermission = false;
      });
    }
  }

  Future<void> _startSession() async {
    if (!_hasPermission) {
      await _requestPermissions();
      if (!_hasPermission) {
        setState(() {
          _error = 'Microphone permission required';
        });
        return;
      }
    }

    // Check if service is configured
    if (!AIAssistantService.isConfigured()) {
      setState(() {
        _error = 'AI service not configured. Please set up API keys.';
      });
      return;
    }

    try {
      setState(() {
        _error = null;
        _status = 'Connecting...';
      });

      // Connect to OpenAI Realtime API using the service
      _rtChannel = WebSocketChannel.connect(
        AIAssistantService.getWebSocketUri(),
        protocols: ['realtime'],
      );

      // Configure the session using the service
      _rtChannel!.sink.add(jsonEncode(AIAssistantService.getSessionConfig()));

      // Listen to WebSocket messages
      _rtChannel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: () {
          setState(() {
            _isConnected = false;
            _isListening = false;
            _status = 'Disconnected';
          });
        },
      );

      // Start audio capture
      await _startAudioCapture();

      setState(() {
        _isConnected = true;
        _status = 'Listening';
        _subtitle = 'Speak to me about cocktails...';
      });

    } catch (e) {
      setState(() {
        _error = 'Connection failed: $e';
        _status = 'Error';
      });
    }
  }

  Future<void> _startAudioCapture() async {
    try {
      await FlutterAudioCapture().start(
        (Float32List data) {
          // Handle audio data callback
          if (_rtChannel != null) {
            // Convert Float32List to Uint8List for OpenAI API
            final buffer = data.buffer.asUint8List();
            _rtChannel!.sink.add(jsonEncode(AIAssistantService.createAudioMessage(buffer)));
          }
        },
        (error) {
          setState(() {
            _error = 'Audio capture error: $error';
          });
        },
      );

      setState(() {
        _isListening = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to start audio capture: $e';
      });
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];

      switch (type) {
        case 'session.created':
          print('Session created successfully');
          break;

        case 'input_audio_buffer.speech_started':
          setState(() {
            _status = 'Listening...';
          });
          break;

        case 'input_audio_buffer.speech_stopped':
          setState(() {
            _status = 'Processing...';
          });
          break;

        case 'conversation.item.input_audio_transcription.completed':
          final transcript = data['transcript'];
          setState(() {
            _subtitle = transcript;
          });
          break;

        case 'response.audio.delta':
          final audioDelta = data['delta'];
          if (audioDelta != null) {
            _playAudioDelta(audioDelta);
            _setTalking(true);
          }
          break;

        case 'response.audio.done':
          _setTalking(false);
          setState(() {
            _status = 'Listening';
          });
          break;

        case 'response.function_call_arguments.done':
          final functionCall = data['call'];
          if (functionCall['name'] == 'return_recipe') {
            _handleRecipeResponse(jsonDecode(functionCall['arguments']));
          }
          break;

        case 'error':
          setState(() {
            _error = 'API Error: ${data['error']['message']}';
          });
          break;
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _handleWebSocketError(error) {
    setState(() {
      _error = 'WebSocket error: $error';
      _isConnected = false;
      _isListening = false;
      _status = 'Error';
    });
  }

  Future<void> _playAudioDelta(String audioDelta) async {
    try {
      final audioBytes = base64Decode(audioDelta);
      // Note: just_audio may need a different approach for streaming PCM audio
      // This is a simplified implementation
      await _ttsPlayer?.setAudioSource(
        AudioSource.uri(Uri.dataFromBytes(audioBytes, mimeType: 'audio/wav'))
      );
      await _ttsPlayer?.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _setTalking(bool talking) {
    _isTalkingInput?.value = talking;
  }

  void _handleRecipeResponse(Map<String, dynamic> recipeData) {
    // Format the recipe data using the service and navigate to RecipeScreen
    final formattedRecipe = AIAssistantService.formatRecipeForScreen(recipeData);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeScreen(recipeData: formattedRecipe),
      ),
    );
  }

  void _stopSession() {
    _cleanup();
    setState(() {
      _isConnected = false;
      _isListening = false;
      _status = 'Ready';
      _subtitle = 'How can I help you today?';
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission'),
        content: const Text(
          'This feature requires microphone access to listen to your voice. '
          'You can also use text input as an alternative.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions();
            },
            child: const Text('Grant Permission'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showTextInput();
            },
            child: const Text('Use Text Instead'),
          ),
        ],
      ),
    );
  }

  void _showTextInput() {
    // Fallback to text input when microphone is not available
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('What would you like to drink?'),
          content: Material(
            color: Colors.transparent,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Describe your cocktail preferences...',
              ),
              maxLines: 3,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processTextInput(controller.text);
              },
              child: const Text('Get Recipe'),
            ),
          ],
        );
      },
    );
  }

  void _processTextInput(String text) {
    // For text input fallback, create a simple recipe based on keywords
    // This is a simplified implementation - in production you might want to
    // use a different API endpoint for text-based processing
    setState(() {
      _subtitle = 'Processing your request: "$text"';
    });
    
    // Simulate processing and provide a basic recipe
    Future.delayed(const Duration(seconds: 2), () {
      _handleRecipeResponse({
        'drink_name': 'Classic Cocktail',
        'ingredients': [
          '2 oz Spirit of choice',
          '1 oz Fresh citrus juice', 
          '0.5 oz Simple syrup',
          'Ice',
          'Garnish of choice'
        ],
        'steps': [
          'Add all ingredients to a shaker with ice',
          'Shake vigorously for 10-15 seconds',
          'Strain into a chilled glass',
          'Garnish and serve immediately'
        ]
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('AI Mixologist'),
        backgroundColor: CupertinoColors.systemBackground,
        border: Border(),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar Section
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.person_circle,
                          size: 80,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Subtitle Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Status and Controls
              Column(
                children: [
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isListening 
                          ? Colors.green.withOpacity(0.1)
                          : _error != null
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isListening 
                            ? Colors.green
                            : _error != null
                                ? Colors.red
                                : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isListening 
                              ? Icons.mic
                              : _error != null
                                  ? Icons.error
                                  : Icons.mic_off,
                          color: _isListening 
                              ? Colors.green
                              : _error != null
                                  ? Colors.red
                                  : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _error ?? _status,
                          style: TextStyle(
                            color: _isListening 
                                ? Colors.green
                                : _error != null
                                    ? Colors.red
                                    : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Control Button
                  if (!_isConnected)
                    ElevatedButton.icon(
                      onPressed: _hasPermission ? _startSession : _showPermissionDialog,
                      icon: Icon(_hasPermission ? Icons.mic : Icons.mic_off),
                      label: Text(_hasPermission ? 'Start Talking' : 'Enable Microphone'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _stopSession,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showTextInput,
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Use Text'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}