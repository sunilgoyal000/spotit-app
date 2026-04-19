import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/report_repository.dart';
import '../repositories/storage_repository.dart';

final reportControllerProvider = AsyncNotifierProvider<ReportController, void>(ReportController.new);

class ReportController extends AsyncNotifier<void> {
  late final ReportRepository _reportRepository;
  late final StorageRepository _storageRepository;

  @override
  FutureOr<void> build() {
    _reportRepository = ref.watch(reportRepositoryProvider);
    _storageRepository = ref.watch(storageRepositoryProvider);
  }

  Future<void> submitReport({
    required String userId,
    required String name,
    required String phone,
    required bool sharePhone,
    required String category,
    required String description,
    required String location,
    required double lat,
    required double lng,
    required String district,
    File? image,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      String? imageUrl;
      if (image != null) {
        imageUrl = await _storageRepository.uploadImage(image);
      }

      await _reportRepository.submitReport(
        userId: userId,
        name: name,
        phone: phone,
        sharePhone: sharePhone,
        category: category,
        description: description,
        location: location,
        lat: lat,
        lng: lng,
        district: district,
        imageUrl: imageUrl,
      );
    });
  }
}
