import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/repositories.dart';
import '../data/repositories/shedding_repository.dart';
import '../data/repositories/reminder_repository.dart';

final reptileRepositoryProvider = Provider<ReptileRepository>((ref) => ReptileRepository());

final recordRepositoryProvider = Provider<RecordRepository>((ref) => RecordRepository());

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) => ReminderRepository());

final sheddingRepositoryProvider = Provider<SheddingRepository>((ref) => SheddingRepository());

final encyclopediaRepositoryProvider = Provider<EncyclopediaRepository>((ref) => EncyclopediaRepository());

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) => KnowledgeRepository());

final habitatRepositoryProvider = Provider<HabitatRepository>((ref) => HabitatRepository());

final medicalRepositoryProvider = Provider<MedicalRepository>((ref) => MedicalRepository());

final qaRepositoryProvider = Provider<QaRepository>((ref) => QaRepository());

final breedingRepositoryProvider = Provider<BreedingRepository>((ref) => BreedingRepository());
