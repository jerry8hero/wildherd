import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/repositories.dart';

final reptileRepositoryProvider = Provider<ReptileRepository>((ref) => ReptileRepository());

final recordRepositoryProvider = Provider<RecordRepository>((ref) => RecordRepository());

final encyclopediaRepositoryProvider = Provider<EncyclopediaRepository>((ref) => EncyclopediaRepository());

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) => KnowledgeRepository());

final habitatRepositoryProvider = Provider<HabitatRepository>((ref) => HabitatRepository());

final medicalRepositoryProvider = Provider<MedicalRepository>((ref) => MedicalRepository());

final qaRepositoryProvider = Provider<QaRepository>((ref) => QaRepository());

final breedingRepositoryProvider = Provider<BreedingRepository>((ref) => BreedingRepository());
