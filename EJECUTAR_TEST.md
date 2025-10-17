# 🚀 EJECUTAR TEST EN TABLET - Guía Rápida

## ⚡ Pasos para Probar (5 minutos)

### 1️⃣ Preparar la Tablet (2 minutos)

#### Habilitar Opciones de Desarrollador:
1. Abre **Settings** (Ajustes) en la tablet
2. Ve a **About tablet** (Acerca de)
3. Busca **Build number** (Número de compilación)
4. **Toca 7 veces** rápidamente
5. Verás: "You are now a developer!" ✅

#### Activar USB Debugging:
1. Vuelve a **Settings**
2. Ahora verás **Developer options** (Opciones de desarrollador)
3. Entra y activa **USB debugging** ✅
4. (Opcional) Activa **Stay awake** para que no se apague la pantalla

### 2️⃣ Conectar la Tablet (30 segundos)

1. **Conecta** la tablet a tu Mac con el cable USB-C
2. En la tablet aparecerá un **popup**:
   ```
   "Allow USB debugging?"
   Computer's RSA key fingerprint: ...

   [ ] Always allow from this computer
   [Cancel] [OK]
   ```
3. **Marca** la casilla "Always allow..."
4. **Tap OK** ✅

### 3️⃣ Ejecutar el Script (Automático)

Abre Terminal y ejecuta:

```bash
cd /Users/david/AndroidXiboclienteink
./test_tablet.sh
```

**El script hará TODO automáticamente:**
- ✅ Detecta la tablet
- ✅ Compila el APK
- ✅ Instala en la tablet
- ✅ Lanza la aplicación
- ✅ Captura logs
- ✅ Te guía en los tests

---

## 📱 Tests Manuales (1 minuto)

Una vez que el script lance la app, **en la pantalla de la tablet** verás:

```
┌─────────────────────────────┐
│   Xibo E-ink Client         │
│                             │
│   ✓ E-ink display...        │
│                             │
│   [  Full Refresh    ]      │
│   [ Partial Refresh  ]      │
│   [  Clear Screen    ]      │
│   [  Test Pattern    ]      │
│                             │
│   Refresh Count: 0          │
└─────────────────────────────┘
```

### Realiza estos tests:

#### ✅ Test 1: Full Refresh
- **Tap** en "Full Refresh"
- **Observa:** La pantalla hace flash
- **Verifica:** Contador cambia a 1

#### ✅ Test 2: Partial Refresh (10x)
- **Tap** en "Partial Refresh" **10 veces**
- **Observa:** Updates rápidos
- **Verifica:** En el tap 10, auto-refresh completo

#### ✅ Test 3: Clear Screen
- **Tap** en "Clear Screen"
- **Observa:** Pantalla se pone blanca
- **Verifica:** Todo el contenido se limpia

#### ✅ Test 4: Test Pattern (20x)
- **Tap** en "Test Pattern" **20 veces** rápido
- **Observa:** Alterna entre blanco y negro
- **Verifica:** No hay ghosting excesivo

---

## 📊 Resultados Esperados

### ✅ ÉXITO si ves:
- App se abre en fullscreen
- UI visible y responsive
- Botones responden al tap
- Contador incrementa
- No crashes

### ⚠️ Normal si dice:
- "✗ E-ink device not available"
- Esto significa que `/dev/eink-panel` no es accesible
- **Es NORMAL sin root**
- El POC valida toda la arquitectura

### ✅ También es ÉXITO si:
- "✓ E-ink display initialized"
- Control e-ink nativo funciona
- Refreshes visibles en pantalla
- **¡PERFECTO!**

---

## 🐛 Problemas Comunes

### "No hay tablet conectada"
**Solución:**
1. Verifica que el cable USB-C esté bien conectado
2. Asegúrate de haber aceptado el prompt "Allow USB debugging?"
3. Intenta otro puerto USB en la Mac
4. Ejecuta el script nuevamente

### "Compilación falló"
**Solución:**
```bash
cd /Users/david/AndroidXiboclienteink
./gradlew clean
./gradlew assembleDebug
./test_tablet.sh
```

### "Instalación falló"
**Solución:**
```bash
/tmp/platform-tools/adb uninstall com.xibo.eink
./test_tablet.sh
```

### App no abre
**Solución:**
```bash
# Ver logs
/tmp/platform-tools/adb logcat | grep -i error

# Reinstalar
/tmp/platform-tools/adb uninstall com.xibo.eink
./test_tablet.sh
```

---

## 📋 Checklist de Verificación

Marca cuando completes:

- [ ] Tablet conectada por USB
- [ ] USB debugging habilitado
- [ ] Prompt "Allow USB debugging?" aceptado
- [ ] Script ejecutado sin errores
- [ ] APK instalado correctamente
- [ ] App lanza en fullscreen
- [ ] UI visible en la tablet
- [ ] Botones responden a taps
- [ ] Test 1 completado (Full Refresh)
- [ ] Test 2 completado (Partial Refresh 10x)
- [ ] Test 3 completado (Clear Screen)
- [ ] Test 4 completado (Test Pattern 20x)
- [ ] Sin crashes ni errores

---

## 📸 Capturar Pantalla (Opcional)

Si quieres tomar screenshots:

```bash
# Screenshot
/tmp/platform-tools/adb shell screencap -p /sdcard/test.png
/tmp/platform-tools/adb pull /sdcard/test.png ~/Desktop/xibo_test.png

# Ver en Finder
open ~/Desktop/xibo_test.png
```

---

## 📝 Ver Logs Completos

El script guarda logs en `/tmp/xibo_test_YYYYMMDD_HHMMSS.log`

```bash
# Ver último log
ls -t /tmp/xibo_test_*.log | head -1 | xargs cat

# Buscar errores
ls -t /tmp/xibo_test_*.log | head -1 | xargs grep -i error

# Ver en tiempo real (mientras la app está corriendo)
/tmp/platform-tools/adb logcat -s XiboEink:D EinkController:V
```

---

## ✅ Después del Test

### Si TODO funciona:
1. ¡ÉXITO! 🎉
2. Documenta resultados
3. Toma screenshots
4. Comparte feedback

### Si hay problemas:
1. Guarda los logs
2. Toma screenshots del error
3. Abre un issue en GitHub:
   https://github.com/NUbem000/AndroidXiboclienteink/issues

---

## 🎯 Siguiente Paso

Una vez validado el POC:
- **Fase 2:** Integración con Xibo CMS
- **Fase 3:** Widgets y contenido
- **Fase 4:** Producción

---

## 💡 Comandos Útiles

```bash
# Ver dispositivos conectados
/tmp/platform-tools/adb devices

# Ver info del dispositivo
/tmp/platform-tools/adb shell getprop ro.product.model
/tmp/platform-tools/adb shell getprop ro.product.manufacturer

# Desinstalar app
/tmp/platform-tools/adb uninstall com.xibo.eink

# Lanzar app manualmente
/tmp/platform-tools/adb shell am start -n com.xibo.eink/.ui.activities.MainActivity

# Cerrar app
/tmp/platform-tools/adb shell am force-stop com.xibo.eink

# Ver memoria de la app
/tmp/platform-tools/adb shell dumpsys meminfo com.xibo.eink
```

---

## 🚀 ¡LISTO!

**Todo está preparado. Solo necesitas:**

1. Conectar la tablet
2. Ejecutar: `./test_tablet.sh`
3. Realizar los tests manuales
4. ¡Disfrutar! 🎉

**¿Preguntas?** ¡Pregunta lo que necesites!

**¿Listo?** ¡Conecta la tablet y ejecuta el script! 📱✨
