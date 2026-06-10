# ToddlerLogic 🚀 • Zero-Friction Kids Learning

[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20(Future)-blue?style=flat-square)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Architecture](https://img.shields.io/badge/architecture-Local--First%20%7C%20BLoC-orange?style=flat-square)]()
[![Permissions](https://img.shields.io/badge/permissions-0%20Required-success?style=flat-square)]()

Una aplicación móvil premium de desarrollo cognitivo diseñada específicamente para niños de 3 años. Este proyecto nace de la frustración real de un padre desarrollador ante el estado del mercado actual: aplicaciones infantiles saturadas de anuncios invasivos, mecánicas frenéticas o suscripciones mensuales costosas que rompen el flujo de atención y frustran a los niños.

**ToddlerLogic** ofrece un entorno seguro, limpio y de **paz mental en un solo pago**, enfocado en hitos reales de desarrollo (retención, emparejamiento y lógica) con una arquitectura de **bajo mantenimiento técnico** y coste de infraestructura cero ($0 USD/mes).

---

## 🌟 Estado del Arte & Factor Diferenciador

El mercado de aplicaciones infantiles en Google Play se divide en tres fallos críticos que este proyecto resuelve:

| Categoría Actual | Problema | Solución ToddlerLogic |
| :--- | :--- | :--- |
| **Apps Gratuitas (Ad-Supported)** | Anuncios invasivos cada 60s, clics accidentales y frustración. | **Cero anuncios invasivos.** Entorno limpio y seguro. |
| **SaaS Infantil (Suscripciones)** | Barrera económica alta (\$5-\$10 USD mensuales recurrentes). | **Freemium ético.** Contenido base gratis y un único pago de por vida. |
| **Pésimo Diseño Técnico** | Apps pesadas (>300MB), rastreo de datos y consumo de batería. | **Local-First & Ultraligera.** <50MB, sin red y sin consumo en background. |

---

## 🛠️ Stack Tecnológico (Zero-Maintenance Stack)

Diseñado para requerir el mínimo esfuerzo de mantenimiento técnico a largo plazo, evitando obsolescencia de APIs y dependencias complejas.

*   **Frontend & Engine:** `Flutter` (Compilación nativa de alto rendimiento mediante Canvas/Skia, escalable a iOS con mínimo esfuerzo).
*   **Base de Datos Local:** `Hive` / `ObjectBox` (NoSQL embebida y ultra rápida para persistencia local de estados y compras).
*   **Gestión de Estado:** `BLoC` / `Cubit` (Flujo de datos predecible, desacoplado de la UI para garantizar testing sencillo).
*   **Monetización:** `Google Play Billing Library` (Delegación total de la pasarela de pagos, impuestos y conversión de moneda local en la infraestructura de Google).

---

## 📋 Matriz de Features (MVP Scope)

El MVP se compone de 4 módulos interactivos desconectados de la red:
              ┌─────────────────────────────────┐
              │       Menú Principal (UI)       │
              └────────────────┬────────────────┘
                               │
     ┌─────────────────────────┼─────────────────────────┐
     ▼                         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Mod. Retención  │       │ Mod. Emparejar  │       │   Mod. Lógica   │
│ (Memory Game)   │       │ (Shadow Match)  │       │ (Classification)│
└─────────────────┘       └─────────────────┘       └─────────────────┘


1.  **Módulo 1: Retención (Memory Game):** Cuadrícula de cartas boca abajo ($2\times2$ o $2\times3$). Desarrolla la memoria visual. *Temáticas: Animales de la Granja (Gratis), Dinosaurios (Premium).*
2.  **Módulo 2: Emparejamiento (Shadow Matching):** Mecánica de arrastrar y soltar (*drag & drop*) de objetos coloridos hacia su silueta correspondiente. Desarrolla la motricidad fina y reconocimiento de patrones.
3.  **Módulo 3: Lógica (Clasificación por Tamaño):** Clasificar objetos en tres cestas: *Grande, Mediano y Pequeño*. Desarrolla el pensamiento comparativo abstracto.
4.  **Módulo 4: Control Parental (Gatekeeper):** Un desafío de lógica textual/matemática simple para adultos que bloquea el acceso a la tienda y configuraciones de la app, evitando compras accidentales del niño.

---

## ⚙️ Reglas de Negocio & Seguridad (Local-First)
---

## ⚙️ Reglas de Negocio & Seguridad (Local-First)

### Reglas de Negocio
*   **Persistencia del Premium:** Al iniciar, la app lee la bandera local `is_premium`. Si es `false`, los niveles avanzados muestran un candado sutil. Al procesar el pago con éxito a través de Google Play, la bandera cambia a `true` permanentemente.
*   **Restauración Nativa:** Inclusión de un botón obligatorio para consultar los recibos históricos de la cuenta de Google Play, permitiendo recuperar el acceso Premium al cambiar de dispositivo sin necesidad de crear usuarios o contraseñas.
*   **UX del Error Amigable:** No existen penalizaciones ni sonidos estridentes ante un fallo. Si el niño se equivoca, el objeto regresa a su origen con una animación suave, reforzando positivamente la persistencia.

### Privacidad & Seguridad (Cumplimiento Estricto COPPA / GDPR)
*   **Cero Permisos:** La aplicación requiere exactamente **0 permisos** en el `AndroidManifest.xml` (sin acceso a cámara, ubicación, contactos o almacenamiento externo).
*   **Sin Telemetría:** No se recopilan IDs de dispositivos, nombres, ni analíticas de comportamiento del menor. Todo el ciclo de vida de los datos nace y muere dentro del Sandbox del dispositivo.

---

## 🚀 Estrategia de Go-To-Market

Al ser un proyecto bootstrap/indie, el crecimiento se basa en canales orgánicos de alta confianza:

*   **Build in Public (Construir en Público):** Compartir el proceso de arquitectura, optimización de assets y testing con usuarios reales (mi propio hijo de 3 años) en redes profesionales como LinkedIn y X, generando una narrativa honesta de "padre ingeniero resolviendo un problema real".
*   **ASO (App Store Optimization) de Cola Larga:** Posicionamiento en la Play Store mediante palabras clave hiper-específicas ignoradas por las grandes corporaciones, orientadas a padres frustrados: *"juegos de lógica para niños de 3 años sin anuncios"*, *"juegos infantiles offline pago único"*.
*   **Comunidades de Crianza Respetuosa:** Participación activa y orgánica en subreddits de paternidad y foros de educación inicial, ofreciendo la app como una alternativa ética frente al software invasivo actual.

---

## 📁 Estructura del Proyecto (Propuesta)

```text
lib/
├── core/                  # Configuraciones globales, temas y utilidades locales
│   └── theme/             # Paleta de colores amigable, tipografía redondeada
├── data/                  # Capa de datos (Persistencia local)
│   ├── database/          # Configuración de Hive / ObjectBox
│   └── repositories/      # Manejo del estado de compras e historial de niveles
├── domain/                # Modelos de negocio puros (Entity)
│   └── models/            # CardModel, LevelModel, CategoryModel
├── presentation/          # Capa de UI y Gestión de Estado (BLoC)
│   ├── blocs/             # GameBloc, PurchaseBloc
│   ├── screens/           # MainMenuScreen, ParentGateScreen
│   └── widgets/           # DragAndDropTarget, MemoryCard, CustomDialog
└── main.dart              # Punto de entrada de la aplicación
Diseñado con ❤️ por un papá desarrollador.

