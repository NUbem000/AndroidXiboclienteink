#!/bin/bash
# test_tablet.sh - Script simplificado para testing

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}Xibo E-ink - Test en Tablet${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Use ADB from tmp
ADB="/tmp/platform-tools/adb"

if [ ! -f "$ADB" ]; then
    echo -e "${RED}Error: ADB no encontrado${NC}"
    echo "Por favor ejecuta primero:"
    echo "  cd /tmp"
    echo "  curl -L -o platform-tools.zip https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
    echo "  unzip platform-tools.zip"
    exit 1
fi

echo -e "${GREEN}✓${NC} ADB encontrado"
echo ""

# Check devices
echo -e "${YELLOW}[1/6]${NC} Verificando conexión..."
DEVICES=$($ADB devices | grep -v "List" | grep "device$" | wc -l | tr -d ' ')

if [ "$DEVICES" -eq 0 ]; then
    echo -e "${RED}✗ No hay tablet conectada${NC}"
    echo ""
    echo "IMPORTANTE: Conecta tu tablet PB1041 por USB y asegúrate de:"
    echo "  1. Habilitar 'Opciones de desarrollador'"
    echo "     Settings > About > Tap 'Build number' 7 veces"
    echo "  2. Activar 'USB debugging'"
    echo "     Settings > Developer options > USB debugging"
    echo "  3. Aceptar el prompt 'Allow USB debugging?' en la tablet"
    echo ""
    echo "Luego ejecuta este script nuevamente:"
    echo "  ./test_tablet.sh"
    exit 1
fi

echo -e "${GREEN}✓${NC} Tablet conectada"
echo ""

# Get device info
MODEL=$($ADB shell getprop ro.product.model 2>/dev/null | tr -d '\r')
MANUFACTURER=$($ADB shell getprop ro.product.manufacturer 2>/dev/null | tr -d '\r')
ANDROID=$($ADB shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')

echo -e "${BLUE}Dispositivo:${NC} $MANUFACTURER $MODEL"
echo -e "${BLUE}Android:${NC} $ANDROID"
echo ""

# Check if Gradle exists
if [ ! -f "./gradlew" ]; then
    echo -e "${RED}Error: No estás en el directorio del proyecto${NC}"
    echo "Por favor ejecuta:"
    echo "  cd /Users/david/AndroidXiboclienteink"
    echo "  ./test_tablet.sh"
    exit 1
fi

# Build APK
echo -e "${YELLOW}[2/6]${NC} Compilando APK..."
./gradlew assembleDebug --quiet --warning-mode=none 2>&1 | grep -E "BUILD|FAILED" || true

APK="app/build/outputs/apk/debug/app-debug.apk"

if [ ! -f "$APK" ]; then
    echo -e "${RED}✗ Compilación falló${NC}"
    echo "Intenta manualmente:"
    echo "  ./gradlew clean assembleDebug"
    exit 1
fi

SIZE=$(du -h "$APK" | cut -f1)
echo -e "${GREEN}✓${NC} APK compilado: $SIZE"
echo ""

# Uninstall old version
echo -e "${YELLOW}[3/6]${NC} Preparando instalación..."
if $ADB shell pm list packages | grep -q "com.xibo.eink"; then
    echo "  Desinstalando versión anterior..."
    $ADB uninstall com.xibo.eink 2>/dev/null || true
fi
echo -e "${GREEN}✓${NC} Listo para instalar"
echo ""

# Install
echo -e "${YELLOW}[4/6]${NC} Instalando en tablet..."
$ADB install "$APK" 2>&1 | grep -E "Success|INSTALL_FAILED" || echo "Instalando..."

if $ADB shell pm list packages | grep -q "com.xibo.eink"; then
    echo -e "${GREEN}✓${NC} Instalación exitosa"
else
    echo -e "${RED}✗${NC} Instalación falló"
    exit 1
fi
echo ""

# Launch
echo -e "${YELLOW}[5/6]${NC} Lanzando aplicación..."
$ADB shell am start -n com.xibo.eink/.ui.activities.MainActivity 2>/dev/null

sleep 2

# Check if running
if $ADB shell pidof com.xibo.eink >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Aplicación ejecutándose"
else
    echo -e "${RED}✗${NC} Aplicación no inició"
fi
echo ""

# Start logging
echo -e "${YELLOW}[6/6]${NC} Capturando logs..."
echo -e "${BLUE}=================================${NC}"
echo ""

LOGFILE="/tmp/xibo_test_$(date +%Y%m%d_%H%M%S).log"
echo "Guardando en: $LOGFILE"
echo ""

# Clear and start logcat
$ADB logcat -c
$ADB logcat -s EinkController:V XiboEink:D MainActivity:D AndroidRuntime:E > "$LOGFILE" &
LOGCAT_PID=$!

echo -e "${GREEN}Aplicación lista para probar!${NC}"
echo ""
echo -e "${YELLOW}===========================================${NC}"
echo -e "${YELLOW}TESTS MANUALES EN LA TABLET:${NC}"
echo -e "${YELLOW}===========================================${NC}"
echo ""
echo "Realiza estos tests en la pantalla de la tablet:"
echo ""
echo -e "${BLUE}Test 1:${NC} Tap 'Full Refresh'"
echo "        Esperado: Pantalla flash, contador = 1"
echo ""
echo -e "${BLUE}Test 2:${NC} Tap 'Partial Refresh' 10 veces"
echo "        Esperado: Updates rápidos, auto-refresh al final"
echo ""
echo -e "${BLUE}Test 3:${NC} Tap 'Clear Screen'"
echo "        Esperado: Pantalla blanca limpia"
echo ""
echo -e "${BLUE}Test 4:${NC} Tap 'Test Pattern' 20 veces"
echo "        Esperado: Alterna blanco/negro"
echo ""
echo -e "${YELLOW}===========================================${NC}"
echo ""
echo "Monitoreando logs por 60 segundos..."
echo "Presiona Ctrl+C para terminar antes"
echo ""

# Wait and show some logs
sleep 3
tail -20 "$LOGFILE" 2>/dev/null || echo "Esperando logs..."

# Monitor for 60 seconds
sleep 57

# Stop logcat
kill $LOGCAT_PID 2>/dev/null || true

echo ""
echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}Testing completado!${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Show summary
echo "Resumen de logs:"
grep -c "E-ink" "$LOGFILE" 2>/dev/null && echo "  - Mensajes e-ink encontrados" || echo "  - No se detectó dispositivo e-ink"
grep -c "refresh" "$LOGFILE" 2>/dev/null && echo "  - Operaciones de refresh registradas" || true
grep -c "ERROR\|FATAL" "$LOGFILE" 2>/dev/null && echo "  - ERRORES encontrados (revisar log)" || echo "  - Sin errores críticos"
echo ""
echo "Log completo: $LOGFILE"
echo ""
echo "Para ver el log:"
echo "  cat $LOGFILE"
echo ""
echo "Para ver solo errores:"
echo "  grep -i error $LOGFILE"
echo ""
echo -e "${GREEN}¡Pruebas completadas!${NC}"
echo ""
