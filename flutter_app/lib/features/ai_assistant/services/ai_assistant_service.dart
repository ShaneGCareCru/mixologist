import 'dart:convert';
import 'dart:typed_data';

class AIAssistantService {
  static const String _baseUrl = 'wss://api.openai.com/v1/realtime';
  
  // Configuration - These should be set from environment variables or secure storage
  static String? _apiKey;
  static String? _assistantId;
  
  static void configure({required String apiKey, String? assistantId}) {
    _apiKey = apiKey;
    _assistantId = assistantId;
  }
  
  static Map<String, dynamic> getSessionConfig() {
    return {
      'type': 'session.create',
      'session': {
        'model': 'gpt-4o-realtime-preview',
        'modalities': ['text', 'audio'],
        'instructions': '''You are a friendly, knowledgeable bartender and mixologist assistant. 
        Your name is Alex, and you work at an upscale cocktail bar. 
        
        Help users create cocktails by:
        - Understanding their preferences (sweet, sour, strong, light, etc.)
        - Asking about available ingredients
        - Considering their skill level
        - Suggesting appropriate glassware and techniques
        
        When you have enough information to provide a complete recipe, call the return_recipe tool 
        with the drink name, detailed ingredients list (with measurements), and step-by-step instructions.
        
        Be conversational, enthusiastic, and helpful. Ask clarifying questions when needed.
        Feel free to share interesting cocktail history or tips.
        
        Example conversation flow:
        1. Greet the user and ask what they're in the mood for
        2. Ask follow-up questions about preferences
        3. Inquire about available ingredients
        4. Provide the recipe using the return_recipe tool
        ''',
        'voice': 'alloy',
        'input_audio_format': 'pcm16',
        'output_audio_format': 'pcm16',
        'input_audio_transcription': {
          'model': 'whisper-1'
        },
        'turn_detection': {
          'type': 'server_vad',
          'threshold': 0.5,
          'prefix_padding_ms': 300,
          'silence_duration_ms': 500
        },
        'tools': [_getRecipeToolDefinition()],
        'tool_choice': 'auto'
      }
    };
  }
  
  static Map<String, dynamic> _getRecipeToolDefinition() {
    return {
      'type': 'function',
      'name': 'return_recipe',
      'description': 'Provide a complete cocktail recipe to the user when you have gathered enough information about their preferences and available ingredients.',
      'parameters': {
        'type': 'object',
        'properties': {
          'drink_name': {
            'type': 'string',
            'description': 'The name of the cocktail (e.g., "Classic Old Fashioned", "Spicy Margarita")'
          },
          'description': {
            'type': 'string',
            'description': 'A brief description of the drink and its flavor profile'
          },
          'ingredients': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'List of ingredients with precise measurements (e.g., "2 oz Bourbon whiskey", "0.5 oz Simple syrup", "2-3 dashes Angostura bitters")'
          },
          'steps': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'Detailed step-by-step preparation instructions'
          },
          'glassware': {
            'type': 'string',
            'description': 'Recommended glass type (e.g., "Old fashioned glass", "Coupe", "Highball")'
          },
          'garnish': {
            'type': 'string',
            'description': 'Recommended garnish (e.g., "Orange peel", "Lime wheel", "Cherry")'
          },
          'difficulty': {
            'type': 'string',
            'enum': ['Easy', 'Medium', 'Hard'],
            'description': 'Difficulty level based on techniques required'
          },
          'prep_time': {
            'type': 'string',
            'description': 'Estimated preparation time (e.g., "2 minutes", "5 minutes")'
          }
        },
        'required': ['drink_name', 'ingredients', 'steps']
      }
    };
  }
  
  static Map<String, dynamic> createAudioMessage(Uint8List audioData) {
    return {
      'type': 'input_audio_buffer.append',
      'audio': base64Encode(audioData),
    };
  }
  
  static Map<String, dynamic> createTextMessage(String text) {
    return {
      'type': 'conversation.item.create',
      'item': {
        'type': 'message',
        'role': 'user',
        'content': [
          {
            'type': 'input_text',
            'text': text
          }
        ]
      }
    };
  }
  
  static Map<String, String> getWebSocketHeaders() {
    if (_apiKey == null) {
      throw Exception('API key not configured. Call AIAssistantService.configure() first.');
    }
    
    return {
      'Authorization': 'Bearer $_apiKey',
      'OpenAI-Beta': 'realtime=v1',
    };
  }
  
  static Uri getWebSocketUri() {
    final uri = Uri.parse(_baseUrl);
    if (_assistantId != null) {
      return uri.replace(queryParameters: {'assistant_id': _assistantId});
    }
    return uri;
  }
  
  // Helper method to format recipe data for RecipeScreen
  static Map<String, dynamic> formatRecipeForScreen(Map<String, dynamic> recipeData) {
    return {
      'name': recipeData['drink_name'] ?? 'AI Assistant Recipe',
      'description': recipeData['description'] ?? 'Recipe provided by AI Assistant',
      'ingredients': recipeData['ingredients'] ?? [],
      'method': recipeData['steps'] ?? [],
      'glassware': recipeData['glassware'] ?? 'Cocktail glass',
      'garnish': recipeData['garnish'] ?? 'As desired',
      'difficulty': recipeData['difficulty'] ?? 'Medium',
      'time': recipeData['prep_time'] ?? '5 minutes',
      'serves': 1,
      // Additional metadata for the app
      'source': 'AI Assistant',
      'created_at': DateTime.now().toIso8601String(),
    };
  }
  
  // Validate that required configuration is set
  static bool isConfigured() {
    return _apiKey != null;
  }
  
  // Get configuration status for debugging
  static Map<String, bool> getConfigStatus() {
    return {
      'hasApiKey': _apiKey != null,
      'hasAssistantId': _assistantId != null,
    };
  }
}