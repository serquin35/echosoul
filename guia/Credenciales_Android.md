# Credenciales de Firma Android (Google Play Store)

> **⚠️ IMPORTANTE:** Este archivo es sólo una referencia para tu entorno local. No subas este archivo ni compartas estas contraseñas públicamente. El archivo `key.properties` y `upload-keystore.jks` ya han sido agregados al `.gitignore`.

Para compilar el App Bundle (.aab) firmado, hemos configurado las siguientes credenciales en `echosoul/android/key.properties`:

- **Contraseña del Keystore (`storePassword`)**: `echosoul_password_123`
- **Contraseña de la Clave (`keyPassword`)**: `echosoul_password_123`
- **Alias (`keyAlias`)**: `upload`
- **Archivo Keystore (`storeFile`)**: `upload-keystore.jks`

**Datos adicionales usados en el comando (DNAME):**
- **CN** (Nombre Común): Serquin
- **OU** (Unidad Organizativa): EchoSoul
- **O** (Organización): Serquin
- **L** (Ciudad): Madrid
- **S** (Provincia/Estado): Madrid
- **C** (Código de País): ES

### Generación de la Clave (Instrucciones)
Dado que el comando `keytool` no está en el PATH del sistema directamente en esta consola, deberás abrir una terminal de **PowerShell** o el terminal de **Android Studio** (que sí tiene Java integrado) en la carpeta `echosoul\android\app\` y ejecutar el siguiente comando una única vez:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass echosoul_password_123 -keypass echosoul_password_123 -dname "CN=Serquin, OU=EchoSoul, O=Serquin, L=Madrid, S=Madrid, C=ES"
```

Una vez que el archivo `upload-keystore.jks` aparezca en tu carpeta `echosoul/android/app/`, estarás listo para compilar con `flutter build aab`.
