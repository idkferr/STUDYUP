# Configuración de Google Sign-In en Firebase

## Pasos para habilitar Google Sign-In

### 1. En Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto **study-up-uv**
3. Ve a **Authentication** > **Sign-in method**
4. En la lista de proveedores, busca **Google**
5. Haz clic en **Google** para configurarlo
6. Activa el interruptor **Enable**
7. Configura:
   - **Project support email**: tu correo de soporte (ej: tu email de Gmail)
   - **Project public-facing name**: Study-UP
8. Haz clic en **Save**

### 2. Para Android (opcional, si vas a probar en Android)

1. Necesitas el **SHA-1** de tu certificado de debug
2. Ejecuta en terminal:
   ```bash
   cd android
   ./gradlew signingReport
   ```
3. Copia el SHA-1 que aparece en `Task :app:signingReport`
4. Ve a Firebase Console > Project Settings > Your apps > Android app
5. Agrega el SHA-1 en la sección **SHA certificate fingerprints**

### 3. Para iOS (opcional, si vas a probar en iOS)

1. Ve a Firebase Console > Project Settings > Your apps > iOS app
2. Descarga el archivo `GoogleService-Info.plist`
3. Reemplaza el archivo en `ios/Runner/GoogleService-Info.plist`

### 4. Para Web (ya está configurado)

La configuración web ya está lista con los parámetros en `firebase_options.dart`.

## Verificar que funciona

1. Ejecuta la app: `flutter run -d chrome`
2. Haz clic en "Iniciar con Google" o "Continuar con Google"
3. Selecciona una cuenta de Google
4. Deberías ser redirigido a la pantalla Home

## Notas importantes

- Google Sign-In en web funciona automáticamente sin configuración adicional
- Para Android/iOS necesitas configurar SHA-1 y descargar los archivos de configuración actualizados
- El dominio `localhost` ya está autorizado en Firebase
- Para producción, asegúrate de agregar tu dominio en **Authorized domains**

## Troubleshooting

Si ves errores:
- `popup_closed_by_user`: El usuario cerró la ventana emergente de Google
- `network-request-failed`: Problema de conexión a internet
- `account-exists-with-different-credential`: El email ya está registrado con otro método

Todos estos errores están manejados en el código con mensajes amigables.
