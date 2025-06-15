import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Centralized icon definitions for the Mixologist app
/// Includes both Material and Cupertino icons for platform consistency
class AppIcons {
  // Private constructor to prevent instantiation
  AppIcons._();

  // Navigation & Actions - Material
  static const IconData search = Icons.search;
  static const IconData refresh = Icons.refresh;
  static const IconData add = Icons.add;
  static const IconData close = Icons.close;
  static const IconData check = Icons.check;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData moreVert = Icons.more_vert;

  // Navigation & Actions - Cupertino (iOS)
  static const IconData cupertinoSearch = CupertinoIcons.search;
  static const IconData cupertinoAdd = CupertinoIcons.add;
  static const IconData cupertinoRefresh = CupertinoIcons.refresh;
  static const IconData cupertinoClose = CupertinoIcons.clear_circled_solid;
  static const IconData cupertinoList = CupertinoIcons.list_bullet;
  static const IconData cupertinoGrid = CupertinoIcons.square_grid_2x2;
  static const IconData cupertinoPersonCircle = CupertinoIcons.person_circle;
  static const IconData cupertinoClock = CupertinoIcons.clock;

  // Media & Input Icons
  static const IconData mic = Icons.mic;
  static const IconData micOff = Icons.mic_off;
  static const IconData stop = Icons.stop;
  static const IconData keyboard = Icons.keyboard;
  static const IconData camera = Icons.camera_alt;
  static const IconData photoLibrary = Icons.photo_library;
  static const IconData imageNotSupported = Icons.image_not_supported;

  // Status & Feedback Icons
  static const IconData error = Icons.error;
  static const IconData warning = Icons.warning;
  static const IconData timer = Icons.timer;
  static const IconData speed = Icons.speed;

  // UI Control Icons
  static const IconData keyboardArrowUp = Icons.keyboard_arrow_up;
  static const IconData keyboardArrowDown = Icons.keyboard_arrow_down;

  // Category Icons - Beverages & Spirits
  static const IconData spirits = Icons.local_bar;
  static const IconData liqueurs = Icons.wine_bar;
  static const IconData juices = Icons.emoji_food_beverage;
  static const IconData mixers = Icons.bubble_chart;
  static const IconData wine = Icons.wine_bar;

  // Category Icons - Ingredients & Supplies
  static const IconData bitters = Icons.opacity;
  static const IconData syrups = Icons.water_drop;
  static const IconData freshIngredients = Icons.eco;
  static const IconData garnishes = Icons.local_florist;
  static const IconData equipment = Icons.kitchen;
  static const IconData inventory = Icons.inventory;

  // Method Card Icons (Tips Categories)
  static const IconData technique = Icons.touch_app;
  static const IconData timing = Icons.timer;
  static const IconData ingredient = Icons.local_grocery_store;
  static const IconData equipmentTip = Icons.kitchen;
  static const IconData presentation = Icons.palette;
  static const IconData safety = Icons.warning;

  // Special Purpose Icons
  static const IconData defaultIcon = Icons.local_bar;
  static const IconData placeholder = Icons.image_not_supported;

  // Helper method to get category icon
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'spirits':
      case 'spirit':
      case 'whiskey':
      case 'rum':
      case 'vodka':
      case 'gin':
      case 'tequila':
      case 'brandy':
        return spirits;
      
      case 'liqueurs':
      case 'liqueur':
      case 'cordial':
        return liqueurs;
      
      case 'wine':
      case 'champagne':
      case 'prosecco':
        return wine;
      
      case 'bitters':
      case 'bitter':
        return bitters;
      
      case 'syrups':
      case 'syrup':
      case 'honey':
      case 'agave':
        return syrups;
      
      case 'juices':
      case 'juice':
      case 'citrus':
        return juices;
      
      case 'mixers':
      case 'mixer':
      case 'soda':
      case 'tonic':
      case 'club soda':
        return mixers;
      
      case 'fresh ingredients':
      case 'herbs':
      case 'spices':
        return freshIngredients;
      
      case 'garnishes':
      case 'garnish':
      case 'fruit':
        return garnishes;
      
      case 'equipment':
      case 'tools':
      case 'glassware':
        return equipment;
      
      default:
        return defaultIcon;
    }
  }

  // Helper method to get tip category icon
  static IconData getTipCategoryIcon(String tipCategory) {
    switch (tipCategory.toLowerCase()) {
      case 'technique':
        return technique;
      case 'timing':
        return timing;
      case 'ingredient':
        return ingredient;
      case 'equipment':
        return equipmentTip;
      case 'presentation':
        return presentation;
      case 'safety':
        return safety;
      default:
        return technique;
    }
  }

  // Platform-aware icon selection
  static IconData platformSearch(TargetPlatform platform) {
    return platform == TargetPlatform.iOS ? cupertinoSearch : search;
  }

  static IconData platformAdd(TargetPlatform platform) {
    return platform == TargetPlatform.iOS ? cupertinoAdd : add;
  }

  static IconData platformRefresh(TargetPlatform platform) {
    return platform == TargetPlatform.iOS ? cupertinoRefresh : refresh;
  }

  static IconData platformClose(TargetPlatform platform) {
    return platform == TargetPlatform.iOS ? cupertinoClose : close;
  }
}