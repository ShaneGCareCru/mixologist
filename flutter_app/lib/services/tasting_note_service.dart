import 'package:flutter/material.dart';

/// Service for managing tasting notes database
class TastingNoteService {
  // Private static instance
  static final TastingNoteService _instance = TastingNoteService._internal();
  
  // Factory constructor
  factory TastingNoteService() {
    return _instance;
  }
  
  // Private constructor
  TastingNoteService._internal();

  /// Core tasting notes mapping
  final Map<String, String> _notes = {
    // Spirits
    'tequila': 'Earthy agave with citrus hints',
    'rum': 'Sweet molasses and vanilla',
    'whiskey': 'Rich oak and caramel undertones',
    'bourbon': 'Smooth vanilla with spice finish',
    'scotch': 'Smoky peat and honey notes',
    'vodka': 'Clean and neutral character',
    'gin': 'Juniper-forward with botanical blend',
    'cognac': 'Elegant fruit and oak complexity',
    'brandy': 'Warm fruit and subtle spice',
    'mezcal': 'Smoky agave with earthy depth',
    
    // Liqueurs
    'triple_sec': 'Bright orange citrus essence',
    'cointreau': 'Premium orange with balanced sweetness',
    'grand_marnier': 'Orange cognac with sophisticated depth',
    'amaretto': 'Sweet almond with cherry undertones',
    'kahlua': 'Rich coffee with vanilla notes',
    'baileys': 'Creamy Irish whiskey and vanilla',
    'sambuca': 'Intense anise with herbal complexity',
    'chambord': 'Luxurious raspberry and honey',
    'st_germain': 'Delicate elderflower with floral notes',
    'aperol': 'Bitter orange with herbal balance',
    'campari': 'Bitter herbs with citrus complexity',
    
    // Wine & Champagne
    'champagne': 'Crisp bubbles with citrus brightness',
    'prosecco': 'Light bubbles with apple and pear',
    'white_wine': 'Crisp acidity with fruit character',
    'red_wine': 'Rich tannins with berry complexity',
    'sherry': 'Nutty richness with dried fruit',
    'port': 'Sweet fortified with dark fruit',
    
    // Mixers & Syrups
    'simple_syrup': 'Pure sweetness without flavor',
    'grenadine': 'Sweet pomegranate with ruby color',
    'orgeat': 'Almond sweetness with floral notes',
    'falernum': 'Spiced lime with almond undertones',
    'lime_juice': 'Bright acidity with citrus zing',
    'lemon_juice': 'Sharp citrus with clean tartness',
    'orange_juice': 'Sweet citrus with pulp richness',
    'cranberry_juice': 'Tart berry with subtle sweetness',
    'pineapple_juice': 'Tropical sweetness with tang',
    'grapefruit_juice': 'Bitter citrus with refreshing bite',
    
    // Bitters
    'angostura_bitters': 'Aromatic spice with herbal complexity',
    'orange_bitters': 'Citrus peel with warm spice',
    'peychauds_bitters': 'Cherry-anise with gentle spice',
    'walnut_bitters': 'Nutty richness with earthy depth',
    
    // Garnishes
    'lime_wheel': 'Fresh citrus oils and bright aroma',
    'lemon_twist': 'Aromatic citrus oils with elegant appeal',
    'orange_peel': 'Fragrant oils with sweet citrus notes',
    'mint_sprig': 'Fresh herbal aroma with cooling effect',
    'cherry': 'Sweet fruit with cocktail tradition',
    'olive': 'Briny saltiness with savory depth',
  };

  /// Regional variations for localization
  final Map<String, Map<String, String>> _regionalNotes = {
    'US': {
      'whiskey': 'American oak and corn sweetness',
      'bourbon': 'Kentucky tradition with vanilla warmth',
    },
    'UK': {
      'gin': 'London dry with juniper prominence',
      'whisky': 'Scottish heritage with peat influence',
    },
    'MX': {
      'tequila': 'Blue agave from highland terroir',
      'mezcal': 'Traditional smokiness from earth ovens',
    },
  };

  /// Get tasting note for an ingredient
  String? getTastingNote(String ingredient, {String? region}) {
    final cleanKey = _sanitizeKey(ingredient);
    
    // Check regional variations first
    if (region != null && _regionalNotes.containsKey(region)) {
      final regionalNote = _regionalNotes[region]![cleanKey];
      if (regionalNote != null) return regionalNote;
    }
    
    // Fallback to general notes
    return _notes[cleanKey];
  }

  /// Get fallback description for unknown ingredients
  String getFallbackDescription(String ingredient) {
    final category = _inferCategory(ingredient);
    switch (category) {
      case 'spirit':
        return 'Premium spirit with complex character';
      case 'liqueur':
        return 'Flavored liqueur with sweet profile';
      case 'wine':
        return 'Fine wine with balanced acidity';
      case 'mixer':
        return 'Quality mixer for cocktail enhancement';
      case 'bitter':
        return 'Aromatic bitters with herbal complexity';
      default:
        return 'Quality ingredient for cocktail crafting';
    }
  }

  /// Add or update a tasting note
  void addTastingNote(String ingredient, String note, {String? region}) {
    final cleanKey = _sanitizeKey(ingredient);
    
    if (region != null) {
      _regionalNotes.putIfAbsent(region, () => {});
      _regionalNotes[region]![cleanKey] = note;
    } else {
      _notes[cleanKey] = note;
    }
  }

  /// Get all available tasting notes
  Map<String, String> getAllNotes({String? region}) {
    if (region != null && _regionalNotes.containsKey(region)) {
      return {..._notes, ..._regionalNotes[region]!};
    }
    return Map.from(_notes);
  }

  /// Search tasting notes by keyword
  Map<String, String> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    final results = <String, String>{};
    
    _notes.forEach((key, value) {
      if (key.contains(lowerQuery) || 
          value.toLowerCase().contains(lowerQuery)) {
        results[key] = value;
      }
    });
    
    return results;
  }

  /// Get localization key for internationalization
  String getLocalizationKey(String ingredient) {
    final cleanKey = _sanitizeKey(ingredient);
    return 'tasting_note.$cleanKey';
  }

  /// Private helper to sanitize ingredient names
  String _sanitizeKey(String ingredient) {
    return ingredient
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'[^\w_]'), '');
  }

  /// Private helper to infer category from ingredient name
  String _inferCategory(String ingredient) {
    final lower = ingredient.toLowerCase();
    
    if (lower.contains('whiskey') || lower.contains('bourbon') || 
        lower.contains('scotch') || lower.contains('vodka') ||
        lower.contains('gin') || lower.contains('rum') ||
        lower.contains('tequila') || lower.contains('brandy')) {
      return 'spirit';
    }
    
    if (lower.contains('liqueur') || lower.contains('schnapps') ||
        lower.contains('amaretto') || lower.contains('kahlua')) {
      return 'liqueur';
    }
    
    if (lower.contains('wine') || lower.contains('champagne') ||
        lower.contains('prosecco') || lower.contains('sherry')) {
      return 'wine';
    }
    
    if (lower.contains('bitters')) {
      return 'bitter';
    }
    
    if (lower.contains('juice') || lower.contains('syrup') ||
        lower.contains('soda') || lower.contains('water')) {
      return 'mixer';
    }
    
    return 'other';
  }
}