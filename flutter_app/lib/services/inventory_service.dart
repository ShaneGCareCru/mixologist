import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/inventory_models.dart';

class InventoryService {
  static const String baseUrl = 'http://localhost:8000'; // Adjust for your setup
  
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
      if (brand != null && brand.isNotEmpty) request.fields['brand'] = brand;
      if (notes != null && notes.isNotEmpty) request.fields['notes'] = notes;

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
    String? brand,
    String? notes,
    bool? expiresSoon,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/inventory/$itemId'),
      );
      
      if (quantity != null) request.fields['quantity'] = quantity;
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
  static Future<void> deleteInventoryItem(String itemId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/inventory/$itemId'));
      
      if (response.statusCode != 200) {
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

  // Analyze image for ingredients
  static Future<ImageRecognitionResponse> analyzeImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/inventory/analyze_image'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

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
}