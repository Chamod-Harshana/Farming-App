import 'package:flutter/material.dart';
import '../../data/datasources/crop_database_helper.dart';
import '../../domain/models/crop_model.dart';

/// State Management Provider for My Crops and Bin management.
class CropProvider extends ChangeNotifier {
  static final CropProvider instance = CropProvider._internal();
  CropProvider._internal();

  List<CropModel> _activeCrops = [];
  List<CropModel> _binCrops = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<CropModel> get activeCrops => _activeCrops;
  List<CropModel> get binCrops => _binCrops;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  /// Returns real-time filtered list of active crops matching searchQuery
  List<CropModel> get filteredActiveCrops {
    if (_searchQuery.trim().isEmpty) {
      return _activeCrops;
    }
    final q = _searchQuery.trim().toLowerCase();
    return _activeCrops.where((crop) {
      final nameMatches = crop.name.toLowerCase().contains(q);
      final nameSiMatches = crop.nameSi.toLowerCase().contains(q);
      final categoryMatches = crop.category.toLowerCase().contains(q);
      final categorySiMatches = crop.categorySi.toLowerCase().contains(q);
      return nameMatches || nameSiMatches || categoryMatches || categorySiMatches;
    }).toList();
  }

  /// Initialize and load crops from local offline database
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await CropDatabaseHelper.instance.initDatabase();
    await loadCrops();
    _isLoading = false;
    notifyListeners();
  }

  /// Refresh crops from local storage
  Future<void> loadCrops() async {
    _activeCrops = await CropDatabaseHelper.instance.getActiveCrops();
    _binCrops = await CropDatabaseHelper.instance.getBinCrops();
    notifyListeners();
  }

  /// Update real-time search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Add a crop from master catalog to user's saved crops
  Future<bool> addCrop(CropModel crop) async {
    // Check if crop already exists in active crops
    final exists = _activeCrops.any((c) => c.id == crop.id);
    if (exists) {
      return false; // Already added
    }

    final newCrop = crop.copyWith(
      isDeleted: false,
      createdAt: DateTime.now(),
    );

    await CropDatabaseHelper.instance.insertCrop(newCrop);
    await loadCrops();
    return true;
  }

  /// Toggle pin status ("Pin to top" / "Unpin")
  Future<void> togglePin(CropModel crop) async {
    final newPinnedState = !crop.isPinned;
    await CropDatabaseHelper.instance.togglePin(crop.id, newPinnedState);
    await loadCrops();
  }

  /// Soft delete: Move crop to Bin
  Future<void> moveToBin(CropModel crop) async {
    await CropDatabaseHelper.instance.moveToBin(crop.id);
    await loadCrops();
  }

  /// Restore crop from Bin back to My Crops
  Future<void> restoreFromBin(CropModel crop) async {
    await CropDatabaseHelper.instance.restoreFromBin(crop.id);
    await loadCrops();
  }

  /// Permanently delete crop from offline database
  Future<void> deletePermanently(CropModel crop) async {
    await CropDatabaseHelper.instance.deletePermanently(crop.id);
    await loadCrops();
  }
}
