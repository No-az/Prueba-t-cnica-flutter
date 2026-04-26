# InterCommerce App

MVP de E-commerce en Flutter con Clean Architecture, Riverpod, GoRouter, Dio y SQLite.

---

## Arquitectura

El proyecto sigue **Clean Architecture** con separación estricta en tres capas:

```
lib/
├── core/
│   ├── di/           # GetIt — inyección de dependencias
│   ├── error/        # Failures (freezed sealed union)
│   ├── network/      # DioClient + interceptores, NetworkInfo
│   └── utils/        # Constants, Either<L,R>
│
├── domain/           # Capa de negocio puro — sin Flutter, sin Dart I/O
│   ├── entities/     # Product, CartItem, Cart
│   ├── repositories/ # Interfaces abstractas
│   └── usecases/     # GetProducts, AddToCart, UpdateCartItem, etc.
│
├── data/             # Implementaciones concretas
│   ├── datasources/
│   │   ├── remote/   # ProductRemoteDataSource (Dio → DummyJSON)
│   │   └── local/    # ProductLocalDataSource, CartLocalDataSource (SQLite)
│   ├── models/       # ProductModel, ProductsResponseModel (freezed + json)
│   └── repositories/ # ProductRepositoryImpl, CartRepositoryImpl
│
└── presentation/
    ├── providers/    # Riverpod StateNotifier (CatalogNotifier, CartNotifier)
    ├── router/       # GoRouter — rutas nominadas
    ├── pages/        # CatalogPage, ProductDetailPage, CartPage
    └── widgets/      # ProductCard, Shimmer, CartBadge
```

### Patrones clave

| Patrón | Aplicación |
|---|---|
| Clean Architecture | Capas data / domain / presentation desacopladas |
| Repository Pattern | `ProductRepository` abstrae remote + local |
| Dependency Inversion | DI via `GetIt`; las capas superiores dependen de interfaces |
| Either monad | `Either<Failure, T>` — manejo funcional de errores |
| Freezed sealed unions | `Failure` — errores tipados (network, server, timeout…) |
| Lazy Loading | Scroll infinito con paginación `skip/limit` |
| Offline Cache | SQLite persiste productos; cart sobrevive al cierre |

---

## Tecnologías

| Categoría | Librería |
|---|---|
| Navegación | `go_router` |
| Estado | `flutter_riverpod` + `riverpod_annotation` |
| Red | `dio` + interceptores |
| Inmutabilidad/JSON | `freezed` + `json_serializable` |
| Imágenes | `cached_network_image` |
| Base de datos | `sqflite` |
| Skeletons | `shimmer` |
| Inyección | `get_it` |
| Tests | `mocktail` |

---

## API

| Endpoint | Uso |
|---|---|
| `GET /products?limit=10&skip=0` | Listado paginado |
| `GET /products/search?q={query}` | Búsqueda |
| `GET /products/{id}` | Detalle |

---

## Instrucciones para ejecutar

### Requisitos previos
- Flutter 3.29+ (`flutter --version`)
- Android emulador o dispositivo físico

### Pasos

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Generar código (freezed + json_serializable + riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# 3. Ejecutar la app
flutter run

# 4. Ejecutar tests
flutter test

# 5. Generar APK release
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk
```

---

## Módulos implementados

### Módulo A — Catálogo
- Grid con `SliverGrid` y `ListView.builder`
- Shimmer/Skeleton durante fetch
- Scroll infinito (lazy loading) con `loadMore()`
- Caché offline en SQLite — funciona sin conexión

### Módulo B — Detalle de Producto
- Navegación con GoRouter y rutas nominadas (`/product/:id`)
- Imágenes con `cached_network_image` + placeholder shimmer
- Galería con `PageView` y dots indicadores
- Feedback visual + haptic en "Agregar al carrito" (`HapticFeedback.mediumImpact`)
- Animación de escala + cambio de icono al agregar

### Módulo C — Carrito
- Estado con `Riverpod StateNotifier`
- Persistencia SQLite — sobrevive al cierre
- Cálculo de subtotal, IVA (19%) y total en la entidad `Cart` (domain layer)
- Incrementar/decrementar cantidad, eliminar, vaciar carrito

---

## Respuestas a preguntas técnicas

### 1. Inversión de dependencia para cambiar SQLite → ObjectBox

La capa `domain` solo conoce la interfaz abstracta `CartRepository`. La implementación concreta `CartRepositoryImpl` depende de `CartLocalDataSource`, que a su vez es una interfaz. Para migrar a ObjectBox:

1. Crear `CartObjectBoxDataSource implements CartLocalDataSource`
2. Registrar en `injection.dart`: `sl.registerLazySingleton<CartLocalDataSource>(() => CartObjectBoxDataSource(...))`

La UI, los Providers y los UseCases **no cambian ni una línea** porque dependen de la abstracción, no del concreto.

### 2. Optimización de listas con miles de productos

- `SliverGrid`/`ListView.builder` con `itemBuilder` — solo renderiza items visibles
- `const` constructors en widgets que no cambian
- `RepaintBoundary` alrededor de cards complejas para aislar repaints
- Imágenes via `cached_network_image` con caché en disco
- **Flutter DevTools → Performance Overlay**: detecta frames > 16ms (60 fps). El "Raster thread" indica problemas de GPU (imágenes sin caché), el "UI thread" indica rebuilds excesivos.
- **Widget Rebuild Stats** en DevTools para identificar widgets que se rebuilden innecesariamente → resolver con `select()` en Riverpod o `Consumer` granular.

### 3. Seguridad de tokens y SSL Pinning

**Almacenamiento seguro de tokens:**
- `flutter_secure_storage` → usa Keychain (iOS) y Keystore/EncryptedSharedPreferences (Android). Nunca SharedPreferences plano.
- Guardar solo el token, nunca credenciales en claro.
- Combinar con `biometric` auth para apps sensibles.

**SSL Pinning:**
- Técnica que valida que el certificado del servidor coincide con una copia embebida en el APK, impidiendo ataques MITM aunque el atacante tenga un certificado CA válido.
- En Dio: configurar `SecurityContext` con el certificado del servidor o usar el paquete `dio_certificate_pinning`.

---

## Supuestos técnicos

1. La API DummyJSON no requiere autenticación — no se implementa token management.
2. El descuento se aplica sobre el precio base; el IVA (19%) se calcula sobre el precio con descuento.
3. El scroll infinito detiene la paginación cuando la respuesta devuelve menos de `pageSize` (10) items.
4. La búsqueda no pagina — devuelve todos los resultados de DummyJSON.
5. No se implementa checkout real — el botón muestra un SnackBar informativo.
