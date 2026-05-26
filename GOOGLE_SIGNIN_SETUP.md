# Configuración de Google Sign-In

Este documento contiene las instrucciones para configurar Google Sign-In en tu aplicación Flutter.

## ✅ Pasos Completados

1. ✅ Dependencia `google_sign_in: ^6.2.1` agregada al `pubspec.yaml`
2. ✅ Modelo `LocalUser` actualizado con soporte para usuarios de Google
3. ✅ Servicio `GoogleAuthService` creado
4. ✅ Servicio `LocalAuthService` actualizado con métodos para usuarios de Google
5. ✅ Pantallas de Login y Register actualizadas con botones de Google Sign-In
6. ✅ Dependencias instaladas con `flutter pub get`

## 🔧 Configuración Requerida

### 1. Configurar Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la **Google Sign-In API**
4. Ve a **Credenciales** → **Crear credenciales** → **ID de cliente de OAuth 2.0**

### 2. Configuración para Android

#### A. Obtener el SHA-1 de tu aplicación

Ejecuta este comando en la terminal desde la raíz del proyecto:

```bash
cd android
./gradlew signingReport
```

O en Windows:
```bash
cd android
gradlew.bat signingReport
```

Busca el **SHA-1** en la salida (generalmente bajo `Variant: debug`).

#### B. Crear credenciales OAuth para Android

1. En Google Cloud Console, crea un **ID de cliente de OAuth 2.0** para Android
2. Ingresa:
   - **Nombre**: RPG ISO Android
   - **Nombre del paquete**: `com.example.rpgiso` (del archivo `android/app/build.gradle.kts`)
   - **SHA-1**: El que obtuviste en el paso anterior

#### C. Descargar google-services.json (Opcional pero recomendado)

Si usas Firebase:
1. Descarga el archivo `google-services.json` desde Firebase Console
2. Colócalo en `android/app/google-services.json`
3. Agrega el plugin de Google Services en `android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

4. En `android/app/build.gradle.kts`, agrega al inicio:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Agregar esta línea
}
```

### 3. Configuración para iOS

#### A. Configurar el proyecto en Xcode

1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona el proyecto Runner
3. En la pestaña **Signing & Capabilities**, asegúrate de tener un Bundle ID único

#### B. Crear credenciales OAuth para iOS

1. En Google Cloud Console, crea un **ID de cliente de OAuth 2.0** para iOS
2. Ingresa:
   - **Nombre**: RPG ISO iOS
   - **Bundle ID**: El Bundle ID de tu app (del paso anterior)

#### C. Actualizar Info.plist

Agrega el siguiente código en `ios/Runner/Info.plist` antes de `</dict>`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reemplaza con tu REVERSED_CLIENT_ID de Google -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

**Nota**: Obtén el `REVERSED_CLIENT_ID` del archivo de configuración de Google o de la consola.

### 4. Configuración para Web

#### A. Crear credenciales OAuth para Web

1. En Google Cloud Console, crea un **ID de cliente de OAuth 2.0** para aplicación web
2. Ingresa:
   - **Nombre**: RPG ISO Web
   - **Orígenes autorizados**: `http://localhost` (para desarrollo)
   - **URIs de redirección autorizados**: `http://localhost`

#### B. Actualizar index.html

Agrega el siguiente código en `web/index.html` dentro de `<head>`:

```html
<meta name="google-signin-client_id" content="TU-CLIENT-ID.apps.googleusercontent.com">
```

## 🧪 Pruebas

### Probar en Android

```bash
flutter run -d android
```

### Probar en iOS

```bash
flutter run -d ios
```

### Probar en Web

```bash
flutter run -d chrome
```

## 📝 Notas Importantes

1. **Modo Debug vs Release**: Las credenciales de debug y release son diferentes. Necesitarás configurar ambas.

2. **Errores Comunes**:
   - **PlatformException(sign_in_failed)**: Verifica que el SHA-1 sea correcto
   - **Error 10**: El paquete no coincide con el configurado en Google Console
   - **Error 12500**: Verifica que Google Play Services esté actualizado

3. **Seguridad**: Nunca compartas tus archivos de configuración (`google-services.json`, etc.) en repositorios públicos.

4. **Producción**: Para publicar en producción, necesitarás:
   - Configurar el SHA-1 de tu keystore de release
   - Actualizar las credenciales en Google Cloud Console
   - Verificar que todos los dominios estén autorizados

## 🎮 Funcionalidades Implementadas

- ✅ Botón "Iniciar sesión con Google" en LoginScreen
- ✅ Botón "Registrarse con Google" en RegisterScreen
- ✅ Detección automática de usuarios nuevos vs existentes
- ✅ Navegación apropiada según el tipo de usuario
- ✅ Almacenamiento local de datos del usuario de Google
- ✅ Integración con el sistema de autenticación existente
- ✅ Manejo de errores y mensajes de feedback
- ✅ Indicadores de carga durante el proceso

## 🔗 Enlaces Útiles

- [Google Sign-In para Flutter](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Documentación oficial de Google Sign-In](https://developers.google.com/identity/sign-in/android/start)

## 💡 Próximos Pasos

1. Configurar las credenciales de OAuth en Google Cloud Console
2. Obtener el SHA-1 de tu aplicación
3. Probar el flujo de autenticación en un dispositivo real o emulador
4. Verificar que los datos del usuario se guarden correctamente
5. Probar el cierre de sesión y re-autenticación

---

**Nota**: Esta implementación usa Google Sign-In standalone (sin Firebase) para simplicidad. Es perfecta para demostraciones y proyectos pequeños.
