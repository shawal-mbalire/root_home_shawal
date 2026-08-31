---
name: hexagonal-architecture
description: Implement Ports and Adapters (Hexagonal Architecture) to separate dependencies from business logic. Use when building maintainable, testable applications with clean domain boundaries across any platform (Python, TypeScript, Flutter, Rust, C++, Embedded). Covers domain modeling, ports/adapters pattern, dependency injection, cross-cutting concerns, multi-stack implementations, and testing strategies.
references:
  - https://github.com/shawal-mbalire/shawal_stack/blob/main/hexagonal_architecture.md
  - https://github.com/shawal-mbalire/shawal_stack/blob/main/architecture-diagram.md
  - https://github.com/shawal-mbalire/shawal_stack/blob/main/shawal_multi_stack.md
---

# Hexagonal Architecture (Ports and Adapters)

Separate dependencies from business logic to ease swapping them out and enable blazing-fast testing.

## Core Principles

1. **Domain is king** — Pure business logic with zero knowledge of external libraries, frameworks, or infrastructure
2. **Dependencies point inward** — Adapters depend on Domain, never the reverse
3. **Ports define contracts** — Interfaces (Protocols/ABCs) that the Domain needs fulfilled
4. **Adapters implement I/O** — Specific implementations of external libraries

## Architecture Layers

### 1. Domain (Inner Core)

Pure, isolated rules and decisions. Zero external dependencies.

```
domain/
├── models/       # Pure data structures representing business concepts
├── errors/       # Custom business-rule exceptions
├── ports/        # Interfaces defining required I/O (Repositories, Gateways)
└── use_cases/    # Orchestrate flow using domain models and ports
```

### 2. Adapters (Outer Ring)

- **Driven Adapters** (Implement Ports): SQLAlchemy, Firestore, Stripe, Console/Sentry
- **Driving Adapters** (Trigger Domain): FastAPI/Flask routes, React hooks, Flutter widgets, Tauri commands, ISRs

### 3. Main Entry (Composition Root)

The wiring layer where everything comes together. Reads config, creates adapters, injects dependencies.

## Request Flow

```
User → Driving Adapter → Convert DTO to Domain Model → Port → Use Case → Domain Logic → Port → Driven Adapter → External Service
                                                                                                                    ↓
User ← Driving Adapter ← Convert to DTO/Response ← Domain Model ← Result ← Adapter Response ←────────────────────┘
```

## Cross-Cutting Concerns

| Concern | Domain Port | Adapter Implementation |
|---------|-------------|------------------------|
| Logging | `LoggerPort` | Console (local), Sentry/JSON (prod) |
| Config | Args to functions | `os.getenv()` in main.py only |
| Caching | Decorator pattern | Redis/IndexedDB wrapping adapter |
| Auth | User model in domain | JWT decode in API adapter |
| Telemetry | `MetricsPort` | Prometheus/Datadog adapter |
| Events | `EventPublisherPort` | Kafka/RabbitMQ/MQTT adapter |

## Multi-Stack Implementations

### Python (Backend)

```python
from typing import Protocol
from dataclasses import dataclass

@dataclass
class Document:
    id: str
    content: str

class DocumentRepository(Protocol):
    def save(self, doc: Document) -> None: ...

class FirestoreDocAdapter(DocumentRepository):
    def __init__(self, collection_name: str):
        self.db = firestore.Client()
        self.collection = self.db.collection(collection_name)

    def save(self, doc: Document) -> None:
        self.collection.document(doc.id).set({"content": doc.content})

def create_document(doc_id: str, content: str, repo: DocumentRepository) -> Document:
    doc = Document(id=doc_id, content=content)
    repo.save(doc)
    return doc

# Composition Root
firestore_repo = FirestoreDocAdapter("documents")

@app.post("/docs/{doc_id}")
def api_create_document(doc_id: str, content: dict):
    return create_document(doc_id, content["text"], repo=firestore_repo)
```

### TypeScript/React (Frontend)

```typescript
// Port
export interface CartRepository {
  saveCart(cart: Cart): Promise<void>;
}

// Driven Adapter
export class LocalStorageCartAdapter implements CartRepository {
  async saveCart(cart: Cart): Promise<void> {
    localStorage.setItem('cart', JSON.stringify(cart));
  }
}

// Use Case
export class AddToCartUseCase {
  constructor(private cartRepo: CartRepository) {}

  async execute(productId: string, quantity: number) {
    await this.cartRepo.saveCart(cart);
    return cart;
  }
}

// Driving Adapter (React Hook)
function useCartController(addToCartUseCase: AddToCartUseCase) {
  const [cartState, setCartState] = useState<Cart | null>(null);

  const handleAdd = async (productId: string) => {
    const updatedCart = await addToCartUseCase.execute(productId, 1);
    setCartState(updatedCart);
  };
  return { cartState, handleAdd };
}
```

### TypeScript/Angular

```typescript
// Driven Adapter
@Injectable()
export class HttpUserAdapter implements UserRepository {
  constructor(private http: HttpClient) {}

  async getUser(id: string): Promise<User> {
    const dto = await firstValueFrom(this.http.get<UserDto>(`/api/users/${id}`));
    return mapDtoToDomain(dto);
  }
}

// Composition Root (app.config.ts)
export const appConfig: ApplicationConfig = {
  providers: [{ provide: UserRepository, useClass: HttpUserAdapter }]
};
```

### Flutter/Dart (Mobile)

```dart
// Port
abstract class LocationPort {
  Future<Coordinates> getCurrentLocation();
}

// Driven Adapter
class GeolocatorAdapter implements LocationPort {
  @override
  Future<Coordinates> getCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    return Coordinates(lat: pos.latitude, lng: pos.longitude);
  }
}

// Driving Adapter (Riverpod)
final locationProvider = AsyncNotifierProvider<LocationNotifier, Coordinates>(LocationNotifier.new);

class LocationNotifier extends AsyncNotifier<Coordinates> {
  late final TrackLocationUseCase _useCase;

  @override
  Future<Coordinates> build() async {
    _useCase = TrackLocationUseCase(GetIt.I<LocationPort>());
    return await _useCase.execute();
  }
}
```

### Tauri/Rust (Desktop)

Two hexagons talking via IPC:

**Frontend (TypeScript):**
```typescript
import { invoke } from '@tauri-apps/api/core';

export class TauriFileStorageAdapter implements FileStoragePort {
  async saveFile(content: string): Promise<void> {
    await invoke('save_file_command', { payload: content });
  }
}
```

**Backend (Rust):**
```rust
#[tauri::command]
fn save_file_command(
    payload: String,
    state: tauri::State<AppDIState>
) -> Result<(), String> {
    core_domain::save_document(&payload, &state.file_repository)
}
```

### MicroPython (Embedded ESP32)

```python
# Port
class RelayPort:
    def turn_on(self) -> None: pass
    def turn_off(self) -> None: pass

# Pure Domain (testable on PC)
class PumpController:
    def __init__(self, pump_relay: RelayPort):
        self.pump = pump_relay
        self.is_active = False

    def toggle_irrigation(self):
        if self.is_active:
            self.pump.turn_off()
        else:
            self.pump.turn_on()
        self.is_active = not self.is_active

# Driven Adapter (Hardware)
class ESP32RelayAdapter(RelayPort):
    def __init__(self, pin_number: int):
        self.pin = Pin(pin_number, Pin.OUT)

    def turn_on(self) -> None:
        self.pin.value(1)

    def turn_off(self) -> None:
        self.pin.value(0)

# Composition Root
water_pump = ESP32RelayAdapter(pin_number=14)
controller = PumpController(pump_relay=water_pump)
button.irq(trigger=Pin.IRQ_FALLING, handler=lambda p: controller.toggle_irrigation())
```

## Testing Strategy

| Layer | Test Type | Approach |
|-------|-----------|----------|
| Domain | Unit Tests | Pass Fake Adapters (in-memory) into Use Cases. Runs in milliseconds. |
| Adapters | Integration Tests | Test against real test databases/services. |
| Main | End-to-End Tests | Hit API adapters with real HTTP requests. |

```python
class FakeOrderRepo(OrderPort):
    def __init__(self):
        self.db = {}
        
    def save(self, order: Order):
        self.db[order.id] = order

def test_create_order():
    fake_repo = FakeOrderRepo()
    create_order({"id": "123"}, repo=fake_repo)
    assert "123" in fake_repo.db
```

## Golden Rules for Multi-Platform

1. **The DTO Boundary** — Adapters must translate external formats (JSON, SQL rows, raw bytes) into Pure Domain Models before passing them inward
2. **Never import external frameworks in Domain** — No `import { Component }` in Angular, no `package:flutter` in Dart, no `#include <Arduino.h>` in C++
3. **Mocking is Universal** — All platforms use Interfaces for Ports, enabling pure in-memory Mocks in any language

## When to Use

- Complex business logic that needs isolation from frameworks
- Applications requiring multiple data sources or external services
- Systems where testability and maintainability are priorities
- Projects where you may swap infrastructure (databases, APIs, frameworks)
- Multi-platform apps sharing domain logic across backend/frontend/mobile/embedded

## Decision Checklist

```
Building a new feature?
├─ Define Domain Models first
├─ Create Ports for any external dependency
├─ Implement Use Cases using only Ports
├─ Build Adapters for infrastructure
└─ Wire everything in Main/Composition Root
```