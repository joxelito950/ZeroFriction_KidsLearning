ToddlerLogic 🚀 • Zero-Friction Kids Learning

Una aplicación móvil premium de desarrollo cognitivo diseñada específicamente para niños de 3 años. Este proyecto nace de la frustración real de un padre desarrollador ante el estado del mercado actual: aplicaciones infantiles saturadas de anuncios invasivos, mecánicas frenéticas o suscripciones mensuales costosas que rompen el flujo de atención y frustran a los niños.

ToddlerLogic ofrece un entorno seguro, limpio y de paz mental en un solo pago, enfocado en hitos reales de desarrollo (retención, emparejamiento y lógica) con una arquitectura de bajo mantenimiento técnico y coste de infraestructura cero ($0 USD/mes).

🌟 Estado del Arte & Factor Diferenciador

El mercado de aplicaciones infantiles en Google Play se divide en tres fallos críticos que este proyecto resuelve:

Categoría Actual

Problema

Solución ToddlerLogic

Apps Gratuitas (Ad-Supported)

Anuncios invasivos cada 60s, clics accidentales y frustración.

Cero anuncios invasivos. Entorno limpio, fluido y seguro.

SaaS Infantil (Suscripciones)

Barrera económica alta ($5-$10 USD mensuales recurrentes).

Freemium ético. Contenido base gratis y un único pago de por vida.

Pésimo Diseño Técnico

Apps pesadas (>300MB), rastreo de datos y consumo de batería.

Local-First & Ultraligera. <50MB, sin red y sin consumo en background.

📐 Arquitectura del Software

El proyecto se rige bajo los principios de Clean Architecture y la segregación de responsabilidades mediante Bounded Contexts (Dominios Hermanos). Esto garantiza desacoplamiento absoluto y escalabilidad sin fricciones.

                    Capa de Presentación (UI / Cubits)
         ┌──────────────────────────┴──────────────────────────┐
         ▼                                                     ▼
 ┌───────────────────────────────┐             ┌───────────────────────────────┐
 │  Dominio: Mecánicas de Juego  │             │   Dominio: Gestión Parental   │
 │   - Memory (Retención)        │  [Paralelo] │   - Control de tiempo diario  │
 │   - Shadow Match (Emparejar)  │             │   - Ajustes (Sonido, Dificultad)  │
 │   - Classification (Lógica)   │             │   - Límites de sesiones       │
 └───────────────┬───────────────┘             └───────────────┬───────────────┘
                 │                                             │
                 └──────────────┬──────────────────────────────┘
                                ▼
                 Capa de Datos (Persistencia / Hive)


Capas del Proyecto

Domain (Capa Central / Pura): Contiene las reglas de negocio puras, modelos de dominio (LevelState, UserProfile) e interfaces de contratos (IPersistenceRepository). Esta capa no depende de ningún framework ni librería externa (ni siquiera de Flutter).

Data (Capa de Infraestructura): Implementa los contratos definidos en el dominio (HivePersistenceRepository). Interactúa directamente con la persistencia local de Hive.

Presentation (Capa de UI y Estado): Orquesta los estados mediante Cubit. Es la encargada de consumir los repositorios a través de interfaces inyectadas y de repintar la UI de forma reactiva.

🛡️ Buenas Prácticas y Principios de Diseño

Local-First por Diseño: Toda la computación y la persistencia ocurren en el dispositivo local. La base de datos es local-first, garantizando latencia cero, tolerancia al modo avión y coste de servidores nulo.

Segregación de Dominios (Bounded Contexts): El dominio de las mecánicas de juego es completamente independiente del dominio de control parental. Los juegos no conocen las restricciones parentales directamente; es la capa de UI quien valida los accesos.

Inmutabilidad Estricta: Todos los estados y modelos (MemoryCard, MemoryGameState) utilizan propiedades final y mutaciones controladas mediante el método copyWith para evitar efectos secundarios (side-effects).

Inyección de Dependencias Rigurosa: El repositorio de datos se pasa por constructor a los Cubits como un contrato abstracto (IPersistenceRepository), facilitando el testeo unitario mediante mocks.

Principio de Responsabilidad Única (SRP): Cada widget y Cubit resuelve una única tarea cognitiva o funcional.

🛠️ Stack Tecnológico (Zero-Maintenance Stack)

Frontend & Engine: Flutter (Compilación nativa de alto rendimiento mediante Canvas/Skia, escalable a iOS).

Base de Datos Local: Hive (NoSQL embebida y ultra rápida para persistencia local de estados y perfiles).

Gestión de Estado: BLoC / Cubit (Flujo de datos unidireccional y predecible).

Monetización: Google Play Billing Library (Delegación de compras integradas directamente en la infraestructura de Google).

📋 Matriz de Features (MVP Scope)

El MVP se compone de 4 módulos interactivos desconectados de la red:

Módulo 1: Retención (Memory Game): Cuadrícula de cartas boca abajo ($2\times2$ o $2\times3$). Desarrolla la memoria visual. Temáticas: Animales de la Granja (Gratis), Dinosaurios (Premium).

Módulo 2: Emparejamiento (Shadow Matching): Mecánica de arrastrar y soltar (drag & drop) de objetos coloridos hacia su silueta correspondiente.

Módulo 3: Lógica (Clasificación por Tamaño): Clasificar objetos en tres cestas: Grande, Mediano y Pequeño.

Módulo 4: Control Parental (Gatekeeper): Un desafío de lógica textual/matemática simple para adultos que bloquea el acceso a la tienda y configuraciones, evitando compras accidentales del niño.

⚙️ Reglas de Negocio & Seguridad

Reglas de Negocio

Persistencia del Premium: Al iniciar, la app lee la bandera local is_premium. Si es false, los niveles avanzados muestran un candado sutil. Al procesar el pago con éxito, la bandera cambia a true de por vida.

Restauración Nativa: Inclusión de un botón obligatorio para recuperar el acceso Premium al cambiar de dispositivo sin necesidad de crear credenciales de usuario.

UX del Error Amigable: No existen penalizaciones ni sonidos estridentes ante un fallo. Si el niño se equivoca, el objeto regresa a su origen con una animación suave, reforzando positivamente la persistencia.

Privacidad & Seguridad (Cumplimiento Estricto COPPA / GDPR)

Cero Permisos: La aplicación requiere exactamente 0 permisos en el AndroidManifest.xml (sin acceso a cámara, ubicación ni almacenamiento externo).

Sin Telemetría: No se recopilan IDs de dispositivos, nombres ni analíticas de comportamiento del menor.

💻 Guía de Instalación para Desarrollo

Sigue estos pasos para clonar el proyecto y levantar el entorno local en tu máquina:

1. Prerrequisitos

Tener instalado el SDK de Flutter (versión compatible con Dart $\ge$ 3.0.0). El SDK de Dart se configurará automáticamente con tu instalación de Flutter.

Verifica que tu entorno esté listo ejecutando:

flutter doctor


2. Clonar el repositorio y descargar dependencias

Clona este repositorio de forma local y descarga las librerías configuradas en el pubspec.yaml:

git clone [https://github.com/tu-usuario/toddler_logic.git](https://github.com/tu-usuario/toddler_logic.git)
cd toddler_logic
flutter pub get


3. Generación automática de código (Hive Adapters)

Dado que el proyecto utiliza el generador automático de código para los adaptadores de Hive (*.g.dart), debes ejecutar el compilador local. Los archivos generados están excluidos de Git por buenas prácticas:

flutter pub run build_runner build --delete-conflicting-outputs


4. Ejecutar las Pruebas Unitarias y de Integración

Antes de subir cualquier cambio, asegúrate de que todos los tests estén pasando con éxito:

flutter test


Para generar e inspeccionar un informe de cobertura de código sin que influyan los archivos autogenerados por el compilador:

flutter test --coverage
# Filtrar archivos autogenerados de Hive (.g.dart)
lcov --remove coverage/lcov.info '*.g.dart' -o coverage/filtered_lcov.info


5. Correr la aplicación

Conecta un emulador o un dispositivo físico y ejecuta:

flutter run


📁 Estructura del Proyecto

lib/
├── core/                  # Configuraciones globales, temas y utilidades locales
│   └── theme/             # Paleta de colores amigable, tipografía redondeada
├── data/                  # Capa de datos (Persistencia local)
│   ├── database/          # Configuración e inicialización segura de Hive
│   └── repositories/      # Implementación del repositorio de datos
├── domain/                # Modelos de negocio puros y abstracciones
│   ├── entities/          # LevelState, UserProfile (Modelos puros)
│   └── repositories/      # Interfaces de contratos (IPersistenceRepository)
├── presentation/          # Capa de UI y Gestión de Estado (Cubit)
│   ├── blocs/             # MemoryGameCubit, SettingsCubit
│   ├── screens/           # Tablero de juego, menús y portones parentales
│   └── widgets/           # Cartas animadas, diálogos no-invasivos
└── main.dart              # Punto de entrada de la aplicación


Diseñado con ❤️ por un papá desarrollador.