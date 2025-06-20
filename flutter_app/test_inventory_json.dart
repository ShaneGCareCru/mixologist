import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/features/inventory/models/inventory_models.dart';

void main() async {
  print('Testing inventory JSON parsing...');
  
  try {
    // Test the raw API response
    final response = await http.get(Uri.parse('http://localhost:8081/inventory'));
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    
    if (response.statusCode == 200) {
      final rawData = response.body;
      print('Raw response length: ${rawData.length}');
      
      // Parse JSON
      final data = json.decode(rawData);
      print('JSON parsed successfully');
      print('Data type: ${data.runtimeType}');
      print('Data keys: ${data.keys}');
      
      if (data.containsKey('items')) {
        final items = data['items'] as List;
        print('Items count: ${items.length}');
        
        if (items.isNotEmpty) {
          print('First item: ${items[0]}');
          
          // Try to parse first item
          try {
            final firstItem = InventoryItem.fromJson(items[0]);
            print('Successfully parsed first item: ${firstItem.name}');
          } catch (e) {
            print('Error parsing first item: $e');
            print('First item structure: ${items[0].keys}');
          }
        }
      } else {
        print('No "items" key in response');
      }
    } else {
      print('HTTP error: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}