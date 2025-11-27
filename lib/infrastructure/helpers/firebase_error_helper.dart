/// Helper para traducir errores de Firebase Auth a mensajes en español
class FirebaseErrorHelper {
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado. Intenta iniciar sesión.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacta al soporte.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      case 'popup-closed-by-user':
        return 'Inicio de sesión cancelado.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo usando otro método.';
      case 'invalid-credential':
        return 'Las credenciales no son válidas.';
      case 'popup-blocked':
        return 'El navegador bloqueó la ventana emergente. Permite ventanas emergentes.';
      default:
        return 'Ocurrió un error inesperado. Intenta nuevamente.';
    }
  }
}
