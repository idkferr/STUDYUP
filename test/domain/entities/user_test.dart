import 'package:flutter_test/flutter_test.dart';
import 'package:study_up/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('should create UserEntity with required fields', () {
      // Arrange
      const uid = 'test-uid-123';
      const email = 'test@example.com';

      // Act
      final user = UserEntity(uid: uid, email: email);

      // Assert
      expect(user.uid, uid);
      expect(user.email, email);
    });

    test('should create UserEntity with different values', () {
      // Arrange
      const uid = 'another-uid';
      const email = 'another@example.com';

      // Act
      final user = UserEntity(uid: uid, email: email);

      // Assert
      expect(user.uid, uid);
      expect(user.email, email);
    });

    test('should allow empty strings for uid and email', () {
      // Act
      final user = UserEntity(uid: '', email: '');

      // Assert
      expect(user.uid, '');
      expect(user.email, '');
    });

    test('should create multiple instances independently', () {
      // Act
      final user1 = UserEntity(uid: 'uid1', email: 'email1@test.com');
      final user2 = UserEntity(uid: 'uid2', email: 'email2@test.com');

      // Assert
      expect(user1.uid, 'uid1');
      expect(user2.uid, 'uid2');
      expect(user1.email, 'email1@test.com');
      expect(user2.email, 'email2@test.com');
    });
  });
}
