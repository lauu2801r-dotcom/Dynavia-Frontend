# Dynavia — Frontend

Aplicación móvil del sistema Dynavia, una plataforma de coordinación dinámica de despeje vehicular para ambulancias en emergencias, basada en geolocalización en tiempo real.

**Stack:** Flutter · Dart · WebSockets · REST APIs · GPS

---

## ¿Qué hace esta app?

Dynavia es la interfaz móvil del sistema distribuido de coordinación vial. Tiene dos roles principales:

**Conductor de ambulancia:**
- Activa el modo emergencia con validación institucional
- Transmite ubicación GPS en tiempo real al servidor
- Recibe confirmación de semáforos sincronizados en su trayecto

**Conductor particular:**
- Recibe notificaciones personalizadas de despeje vial
- Ve instrucciones de hacia dónde moverse para liberar la vía
- Visualiza el estado de la emergencia cercana en tiempo real

---

## Flujo principal del sistema

1. Conductor de ambulancia activa modo emergencia desde la app
2. El sistema verifica la identidad institucional del conductor
3. Se transmite el GPS continuamente al backend
4. El sistema detecta vehículos en un radio de 300–500 metros
5. Se envían notificaciones de despeje a conductores cercanos
6. Los semáforos simulados se sincronizan automáticamente

---

## Stack técnico

- **Flutter 3.4+** — framework multiplataforma (Android/iOS)
- **Dart** — lenguaje principal
- **WebSockets** — comunicación en tiempo real con el backend
- **REST APIs** — integración con los microservicios de Dynavia
- **GPS / Geolocalización** — transmisión continua de ubicación

---

## Cómo correr el proyecto

### 1. Clonar el repositorio
```bash
git clone https://github.com/lauu2801r-dotcom/Dynavia-Frontend.git
cd Dynavia-Frontend
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar la URL del backend
En el archivo de configuración, ajusta la IP del servidor donde está corriendo el backend de Dynavia.

### 4. Correr la app
```bash
# En emulador Android
flutter run

# En navegador
flutter run -d chrome
```

> ⚠️ El backend debe estar corriendo con `docker-compose up` antes de iniciar la app.

---

## Contexto académico

Proyecto de la asignatura **Sistemas Distribuidos**  
Universidad Manuela Beltrán · Bogotá, Colombia · 2026  
Autoras: Laura Valentina González Rojas · Valery Teheran Bernett  
Docente: Juan José Osorio Tabares
