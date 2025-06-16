import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import '../models/inventory_models.dart';

class InventoryService {
  static const String baseUrl = 'http://localhost:8081'; // FastAPI server port
  
  // Get all inventory items
  static Future<List<InventoryItem>> getInventory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/inventory'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        return items.map((item) => InventoryItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load inventory: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading inventory: $e');
    }
  }

  // Add new inventory item
  static Future<InventoryItem> addInventoryItem({
    required String name,
    required String category,
    required String quantity,
    dynamic sourceImage, // Accept both XFile and File
    String? brand,
    String? notes,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/inventory'),
      );
      
      request.fields['name'] = name;
      request.fields['category'] = category;
      request.fields['quantity'] = quantity;
      request.fields['fullness'] = QuantityDescription.getFullnessValue(quantity).toString();
      if (brand != null && brand.isNotEmpty) request.fields['brand'] = brand;
      if (notes != null && notes.isNotEmpty) request.fields['notes'] = notes;

      // Generate and store stylized image if source image provided
      // Note: Stylized image generation temporarily disabled due to missing backend endpoint
      String? imagePath;
      // TODO: Re-enable when /inventory/generate_stylized_image endpoint is implemented
      /*
      if (sourceImage != null) {
        imagePath = await _generateAndStoreStylizedImage(
          sourceImage: sourceImage,
          itemName: name,
          category: category,
        );
        if (imagePath != null) {
          request.fields['image_path'] = imagePath;
        }
      }
      */

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return InventoryItem.fromJson(data['item']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to add item');
      }
    } catch (e) {
      throw Exception('Error adding inventory item: $e');
    }
  }

  // Update inventory item
  static Future<InventoryItem> updateInventoryItem({
    required String itemId,
    String? quantity,
    double? fullness,
    String? imagePath,
    String? brand,
    String? notes,
    bool? expiresSoon,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/inventory/$itemId'),
      );
      
      if (quantity != null) {
        request.fields['quantity'] = quantity;
        // Also update fullness based on quantity if not explicitly provided
        if (fullness == null) {
          request.fields['fullness'] = QuantityDescription.getFullnessValue(quantity).toString();
        }
      }
      if (fullness != null) request.fields['fullness'] = fullness.toString();
      if (imagePath != null) request.fields['image_path'] = imagePath;
      if (brand != null) request.fields['brand'] = brand;
      if (notes != null) request.fields['notes'] = notes;
      if (expiresSoon != null) request.fields['expires_soon'] = expiresSoon.toString();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return InventoryItem.fromJson(data['item']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to update item');
      }
    } catch (e) {
      throw Exception('Error updating inventory item: $e');
    }
  }

  // Delete inventory item
  static Future<void> deleteInventoryItem(String itemId, {String? imagePath}) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/inventory/$itemId'));
      
      if (response.statusCode == 200) {
        // Also delete the stored image if it exists
        if (imagePath != null) {
          await deleteStoredImage(imagePath);
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to delete item');
      }
    } catch (e) {
      throw Exception('Error deleting inventory item: $e');
    }
  }

  // Get inventory statistics
  static Future<InventoryStats> getInventoryStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/inventory/stats'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return InventoryStats.fromJson(data['stats']);
      } else {
        throw Exception('Failed to load inventory stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading inventory stats: $e');
    }
  }

  // Analyze image for ingredients - Web and mobile compatible
  static Future<ImageRecognitionResponse> analyzeImage(dynamic imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/inventory/analyze_image'),
      );
      
      // Handle both XFile (web/cross-platform) and File (mobile)
      if (imageFile is XFile) {
        // Web-compatible: use XFile.readAsBytes()
        final bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ));
      } else if (imageFile is File) {
        // Mobile: use File.readAsBytes()
        final bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.path.split('/').last,
        ));
      } else {
        throw Exception('Unsupported image file type');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ImageRecognitionResponse.fromJson(data['recognition_results']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to analyze image');
      }
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }

  // Check recipe availability
  static Future<Map<String, dynamic>> checkRecipeAvailability(
      List<Map<String, String>> ingredients) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/inventory/check_recipe'),
      );
      
      request.fields['ingredients'] = json.encode(ingredients);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['availability'];
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to check recipe availability');
      }
    } catch (e) {
      throw Exception('Error checking recipe availability: $e');
    }
  }

  // Get compatible recipes
  static Future<List<String>> getCompatibleRecipes({
    bool availableOnly = true,
    bool includeSubstitutions = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/inventory/compatible_recipes').replace(
        queryParameters: {
          'available_only': availableOnly.toString(),
          'include_substitutions': includeSubstitutions.toString(),
        },
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['compatible_recipes']);
      } else {
        throw Exception('Failed to load compatible recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading compatible recipes: $e');
    }
  }

  // Get ingredient categories
  static Future<List<Map<String, String>>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/inventory/categories'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, String>>.from(
          data['categories'].map((cat) => Map<String, String>.from(cat))
        );
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  // Get quantity options
  static Future<List<Map<String, String>>> getQuantities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/inventory/quantities'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, String>>.from(
          data['quantities'].map((qty) => Map<String, String>.from(qty))
        );
      } else {
        throw Exception('Failed to load quantities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading quantities: $e');
    }
  }

  // Image Management Methods

  // Get the local images directory
  static Future<Directory> _getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'bar_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  // Generate a filename for a bottle image
  static String _generateImageFilename(String itemName, String category) {
    final sanitized = itemName.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return '${category}_$sanitized.png';
  }

  // Check if stylized image already exists for this item
  static Future<String?> getExistingImagePath(String itemName, String category) async {
    try {
      final imagesDir = await _getImagesDirectory();
      final filename = _generateImageFilename(itemName, category);
      final file = File(path.join(imagesDir.path, filename));
      
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Generate and store a stylized bottle image
  static Future<String?> _generateAndStoreStylizedImage({
    required dynamic sourceImage, // Accept both XFile and File
    required String itemName,
    required String category,
  }) async {
    try {
      // Check if image already exists to avoid regeneration
      final existingPath = await getExistingImagePath(itemName, category);
      if (existingPath != null) {
        return existingPath;
      }

      // Generate stylized image using AI
      final stylizedImageData = await _generateStylizedImage(sourceImage, itemName, category);
      if (stylizedImageData == null) {
        return null;
      }

      // Store the image locally
      final imagesDir = await _getImagesDirectory();
      final filename = _generateImageFilename(itemName, category);
      final file = File(path.join(imagesDir.path, filename));
      
      await file.writeAsBytes(stylizedImageData);
      return file.path;
    } catch (e) {
      print('Error generating and storing stylized image: $e');
      return null;
    }
  }

  // Generate stylized image using AI API
  static Future<Uint8List?> _generateStylizedImage(dynamic sourceImage, String itemName, String category) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/inventory/generate_stylized_image'),
      );
      
      // Handle both XFile and File
      if (sourceImage is XFile) {
        final bytes = await sourceImage.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: sourceImage.name,
        ));
      } else if (sourceImage is File) {
        request.files.add(await http.MultipartFile.fromPath('file', sourceImage.path));
      }
      request.fields['item_name'] = itemName;
      request.fields['category'] = category;
      request.fields['style'] = 'cartoon bar item in an 8-bit pixel style with transparent background';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to generate stylized image');
      }
    } catch (e) {
      print('Error generating stylized image: $e');
      return null;
    }
  }

  // Delete stored image for an item
  static Future<void> deleteStoredImage(String? imagePath) async {
    if (imagePath != null) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting stored image: $e');
      }
    }
  }

  // Regenerate stylized image for an existing item
  static Future<String?> regenerateStylizedImage({
    required dynamic sourceImage, // Accept both XFile and File
    required String itemName,
    required String category,
    String? oldImagePath,
  }) async {
    // Delete old image first
    if (oldImagePath != null) {
      await deleteStoredImage(oldImagePath);
    }

    // Generate new image
    return await _generateAndStoreStylizedImage(
      sourceImage: sourceImage,
      itemName: itemName,
      category: category,
    );
  }
}