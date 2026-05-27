import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/character.dart';

part 'character_providers.g.dart';

@Riverpod(keepAlive: true)
class ActiveCharacter extends _$ActiveCharacter {
  @override
  Character? build() => null;

  void select(Character character) {
    state = character;
  }

  void clear() {
    state = null;
  }
}
