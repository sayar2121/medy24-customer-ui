import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/profile_notifier.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(ref);
});
