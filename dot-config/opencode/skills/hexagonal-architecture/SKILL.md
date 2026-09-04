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
5. **Infrastructure is separate** — Logging, config, and cross-cutting concerns live in `infra/`, not domain

## Python Project Setup

### Initialize with uv

```bash
# Create project directory
mkdir my-project && cd my-project

# Initialize uv project (no package - just scripts and dependencies)
uv init --no-package

# Create project structure
mkdir -p domain/models domain/errors domain/ports domain/workflows
mkdir -p infra adapters tests/unit tests/integration tests/e2e tests/fixtures/fakes
touch domain/__init__.py domain/models/__init__.py domain/errors/__init__.py
touch domain/ports/__init__.py domain/workflows/__init__.py
touch infra/__init__.py adapters/__init__.py tests/__init__.py
touch main.py
```

### Justfile

```just
# justfile - Project commands

# Default: show available commands
default:
    @just --list

# Run the application
run:
    uv run python main.py

# Watch logs (platform-specific)
logs *args:
    @echo "Logs not configured for this project type"
    @echo "Configure in your project's justfile"

# Run all tests
test:
    uv run pytest tests/ -v

# Run unit tests only
test-unit:
    uv run pytest tests/unit/ -v

# Run integration tests
test-integration:
    uv run pytest tests/integration/ -v

# Run end-to-end tests
test-e2e:
    uv run pytest tests/e2e/ -v

# Run tests with coverage
test-coverage:
    uv run pytest tests/ --cov=domain --cov=infra --cov=adapters --cov-report=term-missing

# Lint code
lint:
    uv run ruff check .

# Format code
format:
    uv run ruff format .

# Type check
typecheck:
    uv run pyright

# Run all checks (lint + typecheck + test)
check: lint typecheck test

# Clean generated files
clean:
    find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    rm -rf .pytest_cache .ruff_cache .mypy_cache htmlcov .coverage

# Add a dependency
add *args:
    uv add {{ args }}

# Add a dev dependency
dev-add *args:
    uv add --dev {{ args }}

# Sync dependencies
sync:
    uv sync

# Update dependencies
update:
    uv lock --upgrade
    uv sync
```

### Platform-Specific Justfiles

**Flutter/Dart Project:**
```just
# flutter-app/justfile

set dotenv-load

# Run the Flutter app
run:
    flutter run

# Watch logs from connected device
logs:
    flutter logs

# Run tests
test:
    flutter test

# Run tests with coverage
test-coverage:
    flutter test --coverage
    genhtml coverage/lcov.info -o coverage/html
    open coverage/html/index.html

# Lint
lint:
    flutter analyze

# Format
format:
    dart format .

# Build for release
build-apk:
    flutter build apk --release

build-ios:
    flutter build ios --release

# Clean
clean:
    flutter clean
    rm -rf build/ .dart_tool/

# Get dependencies
get:
    flutter pub get

# Run integration tests
test-integration:
    flutter test integration_test/
```

**Embedded/MicroPython Project:**
```just
# embedded/justfile

set dotenv-load

# Serial port (default, override with PORT=/dev/ttyUSB0)
PORT := env_var_or_default("PORT", "/dev/tty.usbmodem*")
BAUD := env_var_or_default("BAUD", "115200")

# Watch serial logs (macOS/Linux)
logs:
    @echo "Connecting to serial port..."
    @echo "Press Ctrl+A then Ctrl+X to exit"
    picocom -b {{BAUD}} $(ls {{PORT}} 2>/dev/null | head -1)

# Alternative: use miniterm
logs-miniterm:
    python -m serial.tools.miniterm $(ls {{PORT}} 2>/dev/null | head -1) {{BAUD}}

# Alternative: use screen (macOS)
logs-screen:
    screen $(ls {{PORT}} 2>/dev/null | head -1) {{BAUD}}

# Upload code to device (MicroPython)
upload file:
    ampy --port $(ls {{PORT}} 2>/dev/null | head -1) put {{file}}

# Upload entire project
upload-project:
    @for file in *.py; do \
        echo "Uploading $$file..."; \
        ampy --port $(ls {{PORT}} 2>/dev/null | head -1) put $$file; \
    done

# Run code on device (MicroPython)
run file:
    ampy --port $(ls {{PORT}} 2>/dev/null | head -1) run {{file}}

# Clear device storage
clear:
    ampy --port $(ls {{PORT}} 2>/dev/null | head -1) remove main.py 2>/dev/null || true
    ampy --port $(ls {{PORT}} 2>/dev/null | head -1) remove boot.py 2>/dev/null || true

# Run tests (on PC, not device)
test:
    uv run pytest tests/ -v

# Lint
lint:
    uv run ruff check .

# Format
format:
    uv run ruff format .
```

**FastAPI/Web Project:**
```just
# api/justfile

set dotenv-load

# Run with hot reload
run:
    uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Watch logs (uvicorn output)
logs:
    uv run uvicorn main:app --host 0.0.0.0 --port 8000 --log-level debug

# Run tests
test:
    uv run pytest tests/ -v

# Run tests with hot reload
test-watch:
    uv run pytest tests/ -v --tb=short -q

# Run tests with coverage
test-coverage:
    uv run pytest tests/ --cov=domain --cov=infra --cov=adapters --cov-report=term-missing --cov-report=html

# Lint
lint:
    uv run ruff check .

# Format
format:
    uv run ruff format .

# Typecheck
typecheck:
    uv run pyright

# Database migrations (if using SQLAlchemy/Alembic)
migrate:
    uv run alembic upgrade head

# Generate migration
migration message:
    uv run alembic revision --autogenerate -m "{{message}}"

# Open API docs
docs:
    open http://localhost:8000/docs
```

**Worker/Background Jobs:**
```just
# worker/justfile

set dotenv-load

# Run worker with hot reload
run:
    uv run watchfiles 'uv run python worker.py' .

# Watch logs
logs:
    uv run python worker.py --verbose

# Run tests
test:
    uv run pytest tests/ -v

# Lint
lint:
    uv run ruff check .

# Format
format:
    uv run ruff format .
```

### Central Justfile (with logs)

```just
# workspace/justfile - Orchestrate all projects

set dotenv-load

# List all projects
list:
    @echo "Available projects:"
    @echo "  api      - Main API server"
    @echo "  worker   - Background worker"
    @echo "  flutter  - Flutter mobile app"
    @echo "  embedded - MicroPython device"
    @just --list

# Run all projects in parallel
dev:
    @parallel --line-buffered \
        just api/run \
        just worker/run

# Watch all logs in parallel
logs:
    @parallel --line-buffered \
        just api/logs \
        just flutter/logs \
        just embedded/logs

# Run all tests
test:
    @just api/test
    @just worker/test
    @just flutter/test
    @just embedded/test

# Run all tests in parallel
test-parallel:
    @parallel --line-buffered \
        just api/test \
        just worker/test \
        just flutter/test \
        just embedded/test

# Lint all projects
lint:
    @parallel --line-buffered \
        just api/lint \
        just worker/lint \
        just flutter/lint \
        just embedded/lint

# Format all projects
format:
    @parallel --line-buffered \
        just api/format \
        just worker/format \
        just flutter/format \
        just embedded/format

# Typecheck all projects
typecheck:
    @parallel --line-buffered \
        just api/typecheck \
        just worker/typecheck \
        just flutter/typecheck \
        just embedded/typecheck

# Run all checks on all projects
check:
    @just api/check
    @just worker/check
    @just flutter/check
    @just embedded/check

# Clean all projects
clean:
    @parallel --line-buffered \
        just api/clean \
        just worker/clean \
        just flutter/clean \
        just embedded/clean

# Add dependency to specific project
add project *args:
    @just {{project}}/add {{args}}

# Sync all dependencies
sync:
    @parallel --line-buffered \
        just api/sync \
        just worker/sync

# Build all projects
build:
    @parallel --line-buffered \
        just api/build \
        just flutter/build-apk

# Deploy specific project
deploy project:
    @just {{project}}/deploy

# Upload code to embedded device
upload project file:
    @just {{project}}/upload {{file}}

# Upload entire project to device
upload-project project:
    @just {{project}}/upload-project

# Project-specific commands (delegate to project justfiles)
api *args:
    @just --justfile projects/api/justfile {{args}}

worker *args:
    @just --justfile projects/worker/justfile {{args}}

flutter *args:
    @just --justfile projects/flutter/justfile {{args}}

embedded *args:
    @just --justfile projects/embedded/justfile {{args}}
```

### pyproject.toml

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "Hexagonal architecture project"
requires-python = ">=3.11"
dependencies = []

[tool.uv]
dev-dependencies = [
    "pytest>=8.0",
    "pytest-cov>=5.0",
    "ruff>=0.5",
    "pyright>=1.1",
]

[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "A", "C4", "SIM", "TCH"]

[tool.pyright]
typeCheckingMode = "strict"
pythonVersion = "3.11"

[tool.pytest.ini_options]
testpaths = ["tests"]
```

## Multi-Project Orchestration

For workspaces with multiple hexagonal architecture projects:

### Workspace Structure

```
workspace/
├── justfile              # Central orchestration
├── projects/
│   ├── api/
│   │   ├── justfile      # Project-specific commands
│   │   ├── pyproject.toml
│   │   └── ...
│   ├── worker/
│   │   ├── justfile
│   │   ├── pyproject.toml
│   │   └── ...
│   └── shared/
│       ├── justfile
│       ├── pyproject.toml
│       └── ...
└── README.md
```

### Central Justfile

```just
# workspace/justfile - Orchestrate all projects

set dotenv-load

# List all projects
list:
    @echo "Available projects:"
    @echo "  api      - Main API server"
    @echo "  worker   - Background worker"
    @echo "  shared   - Shared utilities"
    @just --list

# Run all projects in parallel
dev:
    @parallel --line-buffered \
        just api/run \
        just worker/run

# Run all tests
test:
    @just api/test
    @just worker/test
    @just shared/test

# Run all tests in parallel
test-parallel:
    @parallel --line-buffered \
        just api/test \
        just worker/test \
        just shared/test

# Lint all projects
lint:
    @parallel --line-buffered \
        just api/lint \
        just worker/lint \
        just shared/lint

# Format all projects
format:
    @parallel --line-buffered \
        just api/format \
        just worker/format \
        just shared/format

# Typecheck all projects
typecheck:
    @parallel --line-buffered \
        just api/typecheck \
        just worker/typecheck \
        just shared/typecheck

# Run all checks on all projects
check:
    @just api/check
    @just worker/check
    @just shared/check

# Clean all projects
clean:
    @parallel --line-buffered \
        just api/clean \
        just worker/clean \
        just shared/clean

# Add dependency to specific project
add project *args:
    @just {{project}}/add {{args}}

# Sync all dependencies
sync:
    @parallel --line-buffered \
        just api/sync \
        just worker/sync \
        just shared/sync

# Build all projects
build:
    @parallel --line-buffered \
        just api/build \
        just worker/build \
        just shared/build

# Deploy specific project
deploy project:
    @just {{project}}/deploy

# Project-specific commands (delegate to project justfiles)
api *args:
    @just --justfile projects/api/justfile {{args}}

worker *args:
    @just --justfile projects/worker/justfile {{args}}

shared *args:
    @just --justfile projects/shared/justfile {{args}}
```

### Project Justfile (e.g., api/justfile)

```just
# projects/api/justfile

set dotenv-load

# Run the API server
run:
    uv run python main.py

# Run all tests
test:
    uv run pytest tests/ -v

# Run unit tests
test-unit:
    uv run pytest tests/unit/ -v

# Lint
lint:
    uv run ruff check .

# Format
format:
    uv run ruff format .

# Typecheck
typecheck:
    uv run pyright

# All checks
check: lint typecheck test

# Build
build:
    uv build

# Deploy
deploy:
    echo "Deploying api..."
    # Add deployment commands here

# Clean
clean:
    find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    rm -rf .pytest_cache .ruff_cache dist *.egg-info
```

## Architecture Layers

### 1. Domain (Inner Core)

Pure, isolated rules and decisions. Zero external dependencies.

**Small projects (single files):**
```
domain/
├── models.py     # Pure data structures representing business concepts
├── errors.py     # Custom business-rule exceptions
├── ports.py      # Interfaces defining required I/O (Repositories, Gateways)
└── workflows.py  # Orchestrate flow using domain models and ports
```

**Larger projects (folders):**
```
domain/
├── models/
│   ├── document.py
│   └── user.py
├── errors/
│   ├── document_errors.py
│   └── validation_errors.py
├── ports/
│   ├── repository.py
│   └── logger.py
└── workflows/
    ├── create_document.py
    └── update_document.py
```

### 2. Infrastructure (Cross-Cutting Concerns)

Separate folder for logging, config, caching, and other infrastructure. Never in domain.

```
infra/
├── logging.py    # LoggerPort implementation (Console, Sentry, JSON)
├── config.py     # Environment loading, secrets management
├── caching.py    # CachePort implementation (Redis, IndexedDB, in-memory)
├── metrics.py    # MetricsPort implementation (Prometheus, Datadog)
├── events.py     # EventPublisherPort implementation (Kafka, RabbitMQ, MQTT)
└── auth.py       # JWT decode, token validation (rules stay in domain)
```

### 3. Adapters (Outer Ring)

- **Driven Adapters** (Implement Ports): SQLAlchemy, Firestore, Stripe, Console/Sentry
- **Driving Adapters** (Trigger Domain): FastAPI/Flask routes, React hooks, Flutter widgets, Tauri commands, ISRs

### 4. Main Entry (Composition Root)

The wiring layer where everything comes together. Reads config from `infra/config.py`, creates adapters, injects dependencies.

## Request Flow

```
User → Driving Adapter → Convert DTO to Domain Model → Port → Workflow → Domain Logic → Port → Driven Adapter → External Service
                                                                                                                      ↓
User ← Driving Adapter ← Convert to DTO/Response ← Domain Model ← Result ← Adapter Response ←───────────────────────┘
```

## Cross-Cutting Concerns

| Concern | Domain Port | Infra Module | Adapter Implementation |
|---------|-------------|--------------|------------------------|
| Logging | `LoggerPort` | `infra/logging.py` | Console (local), Sentry/JSON (prod) |
| Config | Args to functions | `infra/config.py` | `os.getenv()` centralized here |
| Caching | Decorator pattern | `infra/caching.py` | Redis/IndexedDB wrapping adapter |
| Auth | User model in domain | `infra/auth.py` | JWT decode in API adapter |
| Telemetry | `MetricsPort` | `infra/metrics.py` | Prometheus/Datadog adapter |
| Events | `EventPublisherPort` | `infra/events.py` | Kafka/RabbitMQ/MQTT adapter |

## Multi-Stack Implementations

### Python (Backend)

```python
# domain/models/document.py
from dataclasses import dataclass
from enum import StrEnum

class DocumentStatus(StrEnum):
    DRAFT = "draft"
    PUBLISHED = "published"
    ARCHIVED = "archived"

@dataclass(frozen=True)
class Document:
    document_identifier: str
    content: str
    status: DocumentStatus = DocumentStatus.DRAFT

    @classmethod
    def create(cls, content: str) -> "Document":
        import uuid
        return cls(
            document_identifier=str(uuid.uuid4()),
            content=content,
            status=DocumentStatus.DRAFT,
        )

# domain/errors/document_errors.py
from dataclasses import dataclass

@dataclass(frozen=True)
class EmptyContentError(Exception):
    message: str = "Document content cannot be empty"

@dataclass(frozen=True)
class DocumentNotFoundError(Exception):
    document_identifier: str
    message: str = "Document not found"

# domain/ports/repository.py
from typing import Protocol

class DocumentRepository(Protocol):
    def save(self, document: Document) -> None: ...
    def find_by_identifier(self, document_identifier: str) -> Document | None: ...

# domain/ports/logger.py
from typing import Protocol

class LoggerPort(Protocol):
    def log_information(self, message: str) -> None: ...
    def log_error(self, message: str) -> None: ...

# domain/workflows/create_document.py
from domain.models.document import Document
from domain.ports.repository import DocumentRepository
from domain.ports.logger import LoggerPort
from domain.errors.document_errors import EmptyContentError

def create_document_workflow(
    content: str,
    document_repository: DocumentRepository,
    logger: LoggerPort,
) -> Document:
    if not content.strip():
        raise EmptyContentError()

    document = Document.create(content=content)
    document_repository.save(document)
    logger.log_information(f"Document created with identifier {document.document_identifier}")
    return document

# infra/config.py
import os
from dataclasses import dataclass

@dataclass(frozen=True)
class FirestoreConfiguration:
    collection_name: str = "documents"

    @classmethod
    def from_environment(cls) -> "FirestoreConfiguration":
        return cls(
            collection_name=os.getenv("FIRESTORE_COLLECTION", "documents"),
        )

@dataclass(frozen=True)
class LoggingConfiguration:
    log_level: str = "INFO"

    @classmethod
    def from_environment(cls) -> "LoggingConfiguration":
        return cls(
            log_level=os.getenv("LOG_LEVEL", "INFO"),
        )

# infra/logging.py
import logging
from domain.ports.logger import LoggerPort

class ConsoleLogger(LoggerPort):
    def __init__(self) -> None:
        self.logger = logging.getLogger(__name__)

    def log_information(self, message: str) -> None:
        self.logger.info(message)

    def log_error(self, message: str) -> None:
        self.logger.error(message)

# adapters/firestore_adapter.py
from google.cloud import firestore
from domain.ports.repository import DocumentRepository
from domain.models.document import Document

class FirestoreDocumentAdapter(DocumentRepository):
    def __init__(self, collection_name: str) -> None:
        self.firestore_client = firestore.Client()
        self.collection = self.firestore_client.collection(collection_name)

    def save(self, document: Document) -> None:
        self.collection.document(document.document_identifier).set({
            "content": document.content,
            "status": document.status.value,
        })

    def find_by_identifier(self, document_identifier: str) -> Document | None:
        document_reference = self.collection.document(document_identifier).get()
        if document_reference.exists:
            document_data = document_reference.to_dict()
            return Document(
                document_identifier=document_identifier,
                content=document_data["content"],
                status=DocumentStatus(document_data["status"]),
            )
        return None

# main.py (Composition Root)
from adapters.firestore_adapter import FirestoreDocumentAdapter
from infra.logging import ConsoleLogger
from infra.config import FirestoreConfiguration, LoggingConfiguration
from domain.workflows.create_document import create_document_workflow

def main() -> None:
    firestore_configuration = FirestoreConfiguration.from_environment()
    document_repository = FirestoreDocumentAdapter(firestore_configuration.collection_name)
    logger = ConsoleLogger()

    @app.post("/documents/{document_identifier}")
    def api_create_document(document_identifier: str, request_body: dict) -> dict:
        document = create_document_workflow(
            content=request_body["content"],
            document_repository=document_repository,
            logger=logger,
        )
        return {
            "document_identifier": document.document_identifier,
            "content": document.content,
            "status": document.status.value,
        }
```

### TypeScript/React (Frontend)

```typescript
// domain/models/Cart.ts
export interface Cart {
  items: CartItem[];
  total: number;
}

export interface CartItem {
  productId: string;
  quantity: number;
  price: number;
}

// domain/ports/CartRepository.ts
export interface CartRepository {
  saveCart(cart: Cart): Promise<void>;
  getCart(): Promise<Cart | null>;
}

// domain/ports/Logger.ts
export interface Logger {
  info(message: string): void;
  error(message: string): void;
}

// domain/use_cases/AddToCartUseCase.ts
import { Cart, CartItem } from '../models/Cart';
import { CartRepository } from '../ports/CartRepository';
import { Logger } from '../ports/Logger';

export class AddToCartUseCase {
  constructor(
    private cartRepo: CartRepository,
    private logger: Logger
  ) {}

  async execute(productId: string, quantity: number, price: number): Promise<Cart> {
    const existingCart = await this.cartRepo.getCart() || { items: [], total: 0 };
    const existingItem = existingCart.items.find(i => i.productId === productId);

    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      existingCart.items.push({ productId, quantity, price });
    }

    existingCart.total = existingCart.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    await this.cartRepo.saveCart(existingCart);
    this.logger.info(`Added ${quantity} of product ${productId} to cart`);
    return existingCart;
  }
}

// infra/config.ts
export const config = {
  storageKey: process.env.REACT_APP_STORAGE_KEY || 'cart',
  logLevel: process.env.REACT_APP_LOG_LEVEL || 'info',
};

// infra/logging.ts
import { Logger } from '../domain/ports/Logger';

export class ConsoleLogger implements Logger {
  info(message: string): void {
    console.log(`[INFO] ${message}`);
  }

  error(message: string): void {
    console.error(`[ERROR] ${message}`);
  }
}

// adapters/LocalStorageCartAdapter.ts
import { CartRepository } from '../domain/ports/CartRepository';
import { Cart } from '../domain/models/Cart';
import { config } from '../infra/config';

export class LocalStorageCartAdapter implements CartRepository {
  async saveCart(cart: Cart): Promise<void> {
    localStorage.setItem(config.storageKey, JSON.stringify(cart));
  }

  async getCart(): Promise<Cart | null> {
    const data = localStorage.getItem(config.storageKey);
    return data ? JSON.parse(data) : null;
  }
}

// adapters/useCartController.ts (Driving Adapter)
import { useState } from 'react';
import { AddToCartUseCase } from '../domain/use_cases/AddToCartUseCase';
import { Cart } from '../domain/models/Cart';

export function useCartController(addToCartUseCase: AddToCartUseCase) {
  const [cartState, setCartState] = useState<Cart | null>(null);

  const handleAdd = async (productId: string, price: number) => {
    const updatedCart = await addToCartUseCase.execute(productId, 1, price);
    setCartState(updatedCart);
  };

  return { cartState, handleAdd };
}
```

### TypeScript/Angular

```typescript
// domain/ports/UserRepository.ts
export interface UserRepository {
  getUser(id: string): Promise<User>;
  saveUser(user: User): Promise<void>;
}

// infra/logging.ts
import { Logger } from '../domain/ports/Logger';

export class SentryLogger implements Logger {
  info(message: string): void {
    Sentry.captureMessage(message, 'info');
  }

  error(message: string): void {
    Sentry.captureException(new Error(message));
  }
}

// adapters/HttpUserAdapter.ts (Driven Adapter)
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
import { UserRepository } from '../domain/ports/UserRepository';
import { User } from '../domain/models/User';

interface UserDto {
  id: string;
  name: string;
  email: string;
}

function mapDtoToDomain(dto: UserDto): User {
  return { id: dto.id, name: dto.name, email: dto.email };
}

@Injectable()
export class HttpUserAdapter implements UserRepository {
  constructor(private http: HttpClient) {}

  async getUser(id: string): Promise<User> {
    const dto = await firstValueFrom(this.http.get<UserDto>(`/api/users/${id}`));
    return mapDtoToDomain(dto);
  }

  async saveUser(user: User): Promise<void> {
    await firstValueFrom(this.http.put(`/api/users/${user.id}`, user));
  }
}

// main.ts (Composition Root - app.config.ts)
import { ApplicationConfig } from '@angular/core';
import { HttpUserAdapter } from './adapters/HttpUserAdapter';
import { UserRepository } from './domain/ports/UserRepository';
import { SentryLogger } from './infra/logging';
import { Logger } from './domain/ports/Logger';

export const appConfig: ApplicationConfig = {
  providers: [
    { provide: UserRepository, useClass: HttpUserAdapter },
    { provide: Logger, useClass: SentryLogger },
  ]
};
```

### Flutter/Dart (Mobile)

```dart
// domain/models/Coordinates.dart
class Coordinates {
  final double lat;
  final double lng;
  Coordinates({required this.lat, required this.lng});
}

// domain/ports/LocationPort.dart
abstract class LocationPort {
  Future<Coordinates> getCurrentLocation();
}

// domain/ports/LoggerPort.dart
abstract class LoggerPort {
  void info(String message);
  void error(String message);
}

// domain/use_cases/TrackLocationUseCase.dart
import '../ports/LocationPort.dart';
import '../ports/LoggerPort.dart';
import '../models/Coordinates.dart';

class TrackLocationUseCase {
  final LocationPort locationPort;
  final LoggerPort logger;

  TrackLocationUseCase(this.locationPort, this.logger);

  Future<Coordinates> execute() async {
    logger.info('Tracking location');
    final coords = await locationPort.getCurrentLocation();
    if (coords.lat == 0 && coords.lng == 0) {
      throw Exception('Invalid coordinates');
    }
    return coords;
  }
}

// infra/config.dart
import 'dart:io';

class AppConfig {
  static String get geolocatorApiKey => Platform.environment['GEOLOCATOR_API_KEY'] ?? '';
  static String get logLevel => Platform.environment['LOG_LEVEL'] ?? 'info';
}

// infra/logging.dart
import '../domain/ports/LoggerPort.dart';
import 'dart:developer' as developer;

class DeveloperLogger implements LoggerPort {
  @override
  void info(String message) {
    developer.log(message, level: 0);
  }

  @override
  void error(String message) {
    developer.log(message, level: 1000);
  }
}

// adapters/GeolocatorAdapter.dart (Driven Adapter)
import 'package:geolocator/geolocator.dart';
import '../domain/ports/LocationPort.dart';
import '../models/Coordinates.dart';

class GeolocatorAdapter implements LocationPort {
  @override
  Future<Coordinates> getCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    return Coordinates(lat: pos.latitude, lng: pos.longitude);
  }
}

// adapters/LocationNotifier.dart (Driving Adapter)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/TrackLocationUseCase.dart';
import '../models/Coordinates.dart';

final locationProvider = AsyncNotifierProvider<LocationNotifier, Coordinates>(LocationNotifier.new);

class LocationNotifier extends AsyncNotifier<Coordinates> {
  late final TrackLocationUseCase _useCase;

  @override
  Future<Coordinates> build() async {
    _useCase = TrackLocationUseCase(
      GetIt.I<LocationPort>(),
      GetIt.I<LoggerPort>(),
    );
    return await _useCase.execute();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _useCase.execute());
  }
}
```

### Tauri/Rust (Desktop)

Two hexagons talking via IPC:

**Frontend (TypeScript):**
```typescript
// domain/ports/FileStoragePort.ts
export interface FileStoragePort {
  saveFile(content: string): Promise<void>;
  readFile(path: string): Promise<string>;
}

// adapters/TauriFileStorageAdapter.ts (Driven Adapter)
import { invoke } from '@tauri-apps/api/core';
import { FileStoragePort } from '../domain/ports/FileStoragePort';

export class TauriFileStorageAdapter implements FileStoragePort {
  async saveFile(content: string): Promise<void> {
    await invoke('save_file_command', { payload: content });
  }

  async readFile(path: string): Promise<string> {
    return await invoke('read_file_command', { path });
  }
}
```

**Backend (Rust):**
```rust
// domain/src/lib.rs (Pure Rust Domain)
pub mod models {
    pub struct Document {
        pub id: String,
        pub content: String,
    }
}

pub mod ports {
    pub trait FileRepository {
        fn save(&self, doc: &models::Document) -> Result<(), String>;
        fn find_by_id(&self, id: &str) -> Result<Option<models::Document>, String>;
    }
}

pub mod use_cases {
    use super::{models::Document, ports::FileRepository};

    pub fn save_document(content: &str, repo: &dyn FileRepository) -> Result<(), String> {
        if content.is_empty() {
            return Err("Content cannot be empty".to_string());
        }
        let doc = Document {
            id: uuid::Uuid::new_v4().to_string(),
            content: content.to_string(),
        };
        repo.save(&doc)
    }
}

// src/main.rs (Composition Root + Driving Adapter)
use tauri::State;
use std::sync::Arc;

pub struct AppDIState {
    pub file_repository: Arc<dyn domain::ports::FileRepository>,
}

#[tauri::command]
fn save_file_command(
    payload: String,
    state: State<AppDIState>
) -> Result<(), String> {
    domain::use_cases::save_document(&payload, state.file_repository.as_ref())
}

#[tauri::command]
fn read_file_command(
    path: String,
    state: State<AppDIState>
) -> Result<String, String> {
    match state.file_repository.find_by_id(&path)? {
        Some(doc) => Ok(doc.content),
        None => Err("File not found".to_string()),
    }
}
```

### MicroPython (Embedded ESP32)

```python
# domain/ports/relay_port.py
class RelayPort:
    def turn_on(self) -> None: pass
    def turn_off(self) -> None: pass

# domain/ports/logger_port.py
class LoggerPort:
    def info(self, message: str) -> None: pass
    def error(self, message: str) -> None: pass

# domain/models/irrigation_state.py
class IrrigationState:
    def __init__(self):
        self.is_active = False

# domain/use_cases/pump_controller.py
from domain.ports.relay_port import RelayPort
from domain.ports.logger_port import LoggerPort
from domain.models.irrigation_state import IrrigationState

class PumpController:
    def __init__(self, pump_relay: RelayPort, logger: LoggerPort):
        self.pump = pump_relay
        self.logger = logger
        self.state = IrrigationState()

    def toggle_irrigation(self):
        if self.state.is_active:
            self.pump.turn_off()
            self.logger.info("Irrigation stopped")
        else:
            self.pump.turn_on()
            self.logger.info("Irrigation started")
        self.state.is_active = not self.state.is_active

# infra/config.py
import os

class EmbeddedConfig:
    RELAY_PIN = int(os.getenv("RELAY_PIN", "14"))
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

# infra/logging.py
from domain.ports.logger_port import LoggerPort
import machine

class SerialLogger(LoggerPort):
    def info(self, message: str) -> None:
        print(f"[INFO] {message}")

    def error(self, message: str) -> None:
        print(f"[ERROR] {message}")

# adapters/esp32_relay_adapter.py (Driven Adapter)
from machine import Pin
from domain.ports.relay_port import RelayPort

class ESP32RelayAdapter(RelayPort):
    def __init__(self, pin_number: int):
        self.pin = Pin(pin_number, Pin.OUT)

    def turn_on(self) -> None:
        self.pin.value(1)

    def turn_off(self) -> None:
        self.pin.value(0)

# main.py (Composition Root + Driving Adapter)
from adapters.esp32_relay_adapter import ESP32RelayAdapter
from infra.logging import SerialLogger
from infra.config import EmbeddedConfig
from domain.use_cases.pump_controller import PumpController

def main():
    water_pump = ESP32RelayAdapter(pin_number=EmbeddedConfig.RELAY_PIN)
    logger = SerialLogger()
    controller = PumpController(pump_relay=water_pump, logger=logger)

    button = Pin(0, Pin.IN, Pin.PULL_UP)
    button.irq(trigger=Pin.IRQ_FALLING, handler=lambda p: controller.toggle_irrigation())

if __name__ == "__main__":
    main()
```

## Testing Strategy

### Test Pyramid

| Layer | Test Type | Location | Speed | Dependencies |
|-------|-----------|----------|-------|--------------|
| Domain | Unit Tests | `tests/unit/` | Milliseconds | None (pure) |
| Adapters | Integration Tests | `tests/integration/` | Seconds | Real services |
| Main | End-to-End Tests | `tests/e2e/` | Minutes | Full stack |

### Test Directory Structure

**Small projects:**
```
tests/
├── fixtures.py           # Shared test data and factories
├── unit/
│   ├── conftest.py
│   └── test_*.py
├── integration/
│   ├── conftest.py
│   └── test_*.py
└── e2e/
    ├── conftest.py
    └── test_*.py
```

**Larger projects:**
```
tests/
├── fixtures/                  # Shared test data and factories
│   ├── __init__.py
│   ├── factories.py          # Domain model factories
│   ├── builders.py           # Test data builders
│   └── fakes/                # Fake implementations
│       ├── __init__.py
│       ├── fake_repos.py
│       ├── fake_loggers.py
│       └── fake_adapters.py
├── unit/
│   ├── conftest.py           # Python fixtures
│   └── test_*.py
├── integration/
│   ├── conftest.py
│   └── test_*.py
└── e2e/
    ├── conftest.py
    └── test_*.py
```

### Shared Fixtures (Python)

```python
# tests/fixtures/__init__.py
from .factories import DocumentFactory, CartFactory, OrderFactory
from .builders import DocumentBuilder, CartBuilder
from .fakes import FakeDocumentRepo, FakeLogger, FakeCartRepo

# tests/fixtures/factories.py
from domain.models.document import Document
from domain.models.cart import Cart, CartItem
from domain.models.order import Order
import uuid
import random

class DocumentFactory:
    @staticmethod
    def create(doc_id: str = None, content: str = None) -> Document:
        return Document(
            id=doc_id or str(uuid.uuid4()),
            content=content or f"Test content {random.randint(1, 1000)}"
        )

    @staticmethod
    def create_batch(count: int) -> list[Document]:
        return [DocumentFactory.create() for _ in range(count)]

class CartFactory:
    @staticmethod
    def create_empty() -> Cart:
        return Cart(items=[], total=0.0)

    @staticmethod
    def create_with_items(item_count: int = 3) -> Cart:
        items = [
            CartItem(
                productId=f"product-{i}",
                quantity=random.randint(1, 5),
                price=round(random.uniform(9.99, 99.99), 2)
            )
            for i in range(item_count)
        ]
        total = sum(item.price * item.quantity for item in items)
        return Cart(items=items, total=total)

class OrderFactory:
    @staticmethod
    def create(order_id: str = None, status: str = "pending") -> Order:
        return Order(
            id=order_id or str(uuid.uuid4()),
            status=status,
            items=CartFactory.create_with_items().items
        )

# tests/fixtures/builders.py
from domain.models.document import Document
from domain.models.cart import Cart, CartItem
from typing import Self

class DocumentBuilder:
    def __init__(self):
        self._id = "default-id"
        self._content = "default content"

    def with_id(self, id: str) -> Self:
        self._id = id
        return self

    def with_content(self, content: str) -> Self:
        self._content = content
        return self

    def build(self) -> Document:
        return Document(id=self._id, content=self._content)

class CartBuilder:
    def __init__(self):
        self._items: list[CartItem] = []

    def with_item(self, product_id: str, quantity: int = 1, price: float = 9.99) -> Self:
        self._items.append(CartItem(productId=product_id, quantity=quantity, price=price))
        return self

    def with_empty_cart(self) -> Self:
        self._items = []
        return self

    def build(self) -> Cart:
        total = sum(item.price * item.quantity for item in self._items)
        return Cart(items=self._items, total=total)

# tests/fixtures/fakes/__init__.py
from .fake_repos import FakeDocumentRepo, FakeCartRepo, FakeOrderRepo
from .fake_loggers import FakeLogger, FakeSilentLogger, FakeVerboseLogger
from .fake_adapters import FakeCacheAdapter, FakeEventPublisher

# tests/fixtures/fakes/fake_repos.py
from domain.models.document import Document
from domain.models.cart import Cart
from domain.models.order import Order
from typing import Optional

class FakeDocumentRepo:
    def __init__(self):
        self.db: dict[str, Document] = {}
        self.save_count = 0

    def save(self, doc: Document) -> None:
        self.db[doc.id] = doc
        self.save_count += 1

    def find_by_id(self, doc_id: str) -> Optional[Document]:
        return self.db.get(doc_id)

    def delete(self, doc_id: str) -> bool:
        if doc_id in self.db:
            del self.db[doc_id]
            return True
        return False

    def clear(self) -> None:
        self.db.clear()
        self.save_count = 0

class FakeCartRepo:
    def __init__(self):
        self.carts: dict[str, Cart] = {}
        self.save_count = 0

    async def save_cart(self, cart: Cart) -> None:
        self.carts["default"] = cart
        self.save_count += 1

    async def get_cart(self) -> Optional[Cart]:
        return self.carts.get("default")

    def clear(self) -> None:
        self.carts.clear()
        self.save_count = 0

class FakeOrderRepo:
    def __init__(self):
        self.orders: dict[str, Order] = {}
        self.save_count = 0

    def save(self, order: Order) -> None:
        self.orders[order.id] = order
        self.save_count += 1

    def find_by_id(self, order_id: str) -> Optional[Order]:
        return self.orders.get(order_id)

    def find_by_status(self, status: str) -> list[Order]:
        return [o for o in self.orders.values() if o.status == status]

    def clear(self) -> None:
        self.orders.clear()
        self.save_count = 0

# tests/fixtures/fakes/fake_loggers.py
from domain.ports.logger_port import LoggerPort
from typing import Union

class FakeLogger(LoggerPort):
    def __init__(self):
        self.messages: list[tuple[str, str]] = []
        self.info_count = 0
        self.error_count = 0

    def info(self, message: str) -> None:
        self.messages.append(("info", message))
        self.info_count += 1

    def error(self, message: str) -> None:
        self.messages.append(("error", message))
        self.error_count += 1

    def get_last_message(self) -> Union[tuple[str, str], None]:
        return self.messages[-1] if self.messages else None

    def clear(self) -> None:
        self.messages.clear()
        self.info_count = 0
        self.error_count = 0

class FakeSilentLogger(LoggerPort):
    def info(self, message: str) -> None:
        pass

    def error(self, message: str) -> None:
        pass

class FakeVerboseLogger(LoggerPort):
    def __init__(self):
        self.messages: list[str] = []

    def info(self, message: str) -> None:
        self.messages.append(f"[VERBOSE-INFO] {message}")

    def error(self, message: str) -> None:
        self.messages.append(f"[VERBOSE-ERROR] {message}")

# tests/fixtures/fakes/fake_adapters.py
from domain.ports.cache_port import CachePort
from domain.ports.event_publisher_port import EventPublisherPort
from typing import Any, Optional

class FakeCacheAdapter:
    def __init__(self):
        self.store: dict[str, Any] = {}
        self.get_count = 0
        self.set_count = 0

    def get(self, key: str) -> Optional[Any]:
        self.get_count += 1
        return self.store.get(key)

    def set(self, key: str, value: Any, ttl: int = None) -> None:
        self.store[key] = value
        self.set_count += 1

    def delete(self, key: str) -> bool:
        if key in self.store:
            del self.store[key]
            return True
        return False

    def clear(self) -> None:
        self.store.clear()
        self.get_count = 0
        self.set_count = 0

class FakeEventPublisher:
    def __init__(self):
        self.events: list[dict[str, Any]] = []
        self.publish_count = 0

    def publish(self, event_type: str, payload: dict[str, Any]) -> None:
        self.events.append({"type": event_type, "payload": payload})
        self.publish_count += 1

    def get_events_by_type(self, event_type: str) -> list[dict[str, Any]]:
        return [e for e in self.events if e["type"] == event_type]

    def clear(self) -> None:
        self.events.clear()
        self.publish_count = 0
```

### Shared Fixtures (TypeScript)

```typescript
// tests/fixtures/factories.ts
import { Cart, CartItem } from '../../domain/models/Cart';
import { Order } from '../../domain/models/Order';

export class CartFactory {
  static createEmpty(): Cart {
    return { items: [], total: 0 };
  }

  static createWithItems(count: number = 3): Cart {
    const items: CartItem[] = Array.from({ length: count }, (_, i) => ({
      productId: `product-${i}`,
      quantity: Math.floor(Math.random() * 5) + 1,
      price: Math.round((Math.random() * 90 + 9.99) * 100) / 100,
    }));
    const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    return { items, total };
  }
}

export class OrderFactory {
  static create(orderId?: string, status: string = 'pending'): Order {
    return {
      id: orderId || crypto.randomUUID(),
      status,
      items: CartFactory.createWithItems().items,
    };
  }
}

// tests/fixtures/fakes.ts
import { CartRepository } from '../../domain/ports/CartRepository';
import { Logger } from '../../domain/ports/Logger';
import { Cart } from '../../domain/models/Cart';

export class FakeCartRepository implements CartRepository {
  private cart: Cart | null = null;
  public saveCount = 0;
  public getCount = 0;

  async saveCart(cart: Cart): Promise<void> {
    this.cart = cart;
    this.saveCount++;
  }

  async getCart(): Promise<Cart | null> {
    this.getCount++;
    return this.cart;
  }

  getSavedCart(): Cart | null {
    return this.cart;
  }

  clear(): void {
    this.cart = null;
    this.saveCount = 0;
    this.getCount = 0;
  }
}

export class FakeLogger implements Logger {
  public messages: { level: string; message: string; timestamp: Date }[] = [];
  public infoCount = 0;
  public errorCount = 0;

  info(message: string): void {
    this.messages.push({ level: 'info', message, timestamp: new Date() });
    this.infoCount++;
  }

  error(message: string): void {
    this.messages.push({ level: 'error', message, timestamp: new Date() });
    this.errorCount++;
  }

  getLastMessage(): { level: string; message: string } | undefined {
    return this.messages[this.messages.length - 1];
  }

  clear(): void {
    this.messages = [];
    this.infoCount = 0;
    this.errorCount = 0;
  }
}

// tests/fixtures/builders.ts
import { Cart, CartItem } from '../../domain/models/Cart';

export class CartBuilder {
  private items: CartItem[] = [];

  withItem(productId: string, quantity: number = 1, price: number = 9.99): this {
    this.items.push({ productId, quantity, price });
    return this;
  }

  withEmptyCart(): this {
    this.items = [];
    return this;
  }

  build(): Cart {
    const total = this.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    return { items: [...this.items], total };
  }
}

// tests/fixtures/setup.ts (Global test setup)
import { FakeCartRepository } from './fakes';
import { FakeLogger } from './fakes';

let fakeCartRepo: FakeCartRepository;
let fakeLogger: FakeLogger;

export function setupTestFixtures(): { cartRepo: FakeCartRepository; logger: FakeLogger } {
  fakeCartRepo = new FakeCartRepository();
  fakeLogger = new FakeLogger();
  return { cartRepo: fakeCartRepo, logger: fakeLogger };
}

export function clearAllFixtures(): void {
  fakeCartRepo?.clear();
  fakeLogger?.clear();
}

// tests/fixtures/index.ts (Barrel export)
export * from './factories';
export * from './fakes';
export * from './builders';
export * from './setup';
```

### Shared Fixtures (Flutter/Dart)

```dart
// test/fixtures/factories.dart
import 'package:your_app/domain/models/Coordinates.dart';
import 'package:your_app/domain/models/Cart.dart';

class CoordinatesFactory {
  static Coordinates create({
    double lat = 40.7128,
    double lng = -74.0060,
  }) {
    return Coordinates(lat: lat, lng: lng);
  }

  static Coordinates createRandom() {
    return Coordinates(
      lat: (DateTime.now().millisecond / 100) * 180 - 90,
      lng: (DateTime.now().microsecond / 1000) * 360 - 180,
    );
  }

  static Coordinates createInvalid() {
    return Coordinates(lat: 0, lng: 0);
  }
}

// test/fixtures/fakes.dart
import 'package:your_app/domain/ports/LocationPort.dart';
import 'package:your_app/domain/ports/LoggerPort.dart';
import 'package:your_app/domain/ports/CartRepository.dart';
import 'package:your_app/domain/models/Coordinates.dart';
import 'package:your_app/domain/models/Cart.dart';

class FakeLocationPort implements LocationPort {
  Coordinates? locationToReturn;
  int getCurrentLocationCount = 0;

  @override
  Future<Coordinates> getCurrentLocation() async {
    getCurrentLocationCount++;
    return locationToReturn ?? CoordinatesFactory.createInvalid();
  }

  void reset() {
    locationToReturn = null;
    getCurrentLocationCount = 0;
  }
}

class FakeLoggerPort implements LoggerPort {
  final List<String> messages = [];
  int infoCount = 0;
  int errorCount = 0;

  @override
  void info(String message) {
    messages.add('[INFO] $message');
    infoCount++;
  }

  @override
  void error(String message) {
    messages.add('[ERROR] $message');
    errorCount++;
  }

  String? getLastMessage() => messages.isEmpty ? null : messages.last;

  void reset() {
    messages.clear();
    infoCount = 0;
    errorCount = 0;
  }
}

class FakeCartRepository implements CartRepository {
  Cart? cartToReturn;
  int saveCartCount = 0;
  int getCartCount = 0;

  @override
  Future<void> saveCart(Cart cart) async {
    saveCartCount++;
  }

  @override
  Future<Cart?> getCart() async {
    getCartCount++;
    return cartToReturn;
  }

  void reset() {
    cartToReturn = null;
    saveCartCount = 0;
    getCartCount = 0;
  }
}

// test/fixtures/test_helpers.dart
import 'package:flutter_test/flutter_test.dart';
import 'fakes.dart';
import 'factories.dart';

class TestHelper {
  static FakeLocationPort createFakeLocation({
    Coordinates? location,
  }) {
    final fake = FakeLocationPort();
    fake.locationToReturn = location ?? CoordinatesFactory.create();
    return fake;
  }

  static FakeLoggerPort createFakeLogger() {
    return FakeLoggerPort();
  }

  static void verifyLoggerCalled(
    FakeLoggerPort logger, {
    int infoCount = 0,
    int errorCount = 0,
  }) {
    expect(logger.infoCount, infoCount);
    expect(logger.errorCount, errorCount);
  }
}

// test/fixtures/fixtures.dart (Barrel export)
export 'factories.dart';
export 'fakes.dart';
export 'test_helpers.dart';
```

### Domain Unit Tests (Using Fixtures)

**Python:**
```python
# tests/unit/test_create_document.py
import pytest
from domain.use_cases.create_document import create_document
from tests.fixtures import DocumentFactory, FakeDocumentRepo, FakeLogger

@pytest.fixture
def repo():
    return FakeDocumentRepo()

@pytest.fixture
def logger():
    return FakeLogger()

def test_create_document_success(repo, logger):
    doc = DocumentFactory.create(doc_id="123", content="Hello World")
    result = create_document(doc.id, doc.content, repo=repo, logger=logger)

    assert result.id == "123"
    assert "123" in repo.db
    assert logger.info_count == 1
    assert "123" in logger.messages[0][1]

def test_create_document_empty_content_raises(repo, logger):
    with pytest.raises(ValueError, match="empty"):
        create_document("123", "", repo=repo, logger=logger)

def test_create_document_increments_save_count(repo, logger):
    doc = DocumentFactory.create()
    create_document(doc.id, doc.content, repo=repo, logger=logger)

    assert repo.save_count == 1
```

**TypeScript:**
```typescript
// tests/unit/AddToCartUseCase.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { AddToCartUseCase } from '../../domain/use_cases/AddToCartUseCase';
import { CartFactory, FakeCartRepository, FakeLogger, CartBuilder } from '../fixtures';

describe('AddToCartUseCase', () => {
  let repo: FakeCartRepository;
  let logger: FakeLogger;
  let useCase: AddToCartUseCase;

  beforeEach(() => {
    repo = new FakeCartRepository();
    logger = new FakeLogger();
    useCase = new AddToCartUseCase(repo, logger);
  });

  it('should add item to empty cart', async () => {
    const cart = await useCase.execute('product-1', 2, 9.99);

    expect(cart.items).toHaveLength(1);
    expect(cart.items[0].productId).toBe('product-1');
    expect(cart.items[0].quantity).toBe(2);
    expect(cart.total).toBe(19.98);
    expect(logger.infoCount).toBe(1);
  });

  it('should increase quantity for existing item', async () => {
    await useCase.execute('product-1', 1, 9.99);
    const cart = await useCase.execute('product-1', 3, 9.99);

    expect(cart.items).toHaveLength(1);
    expect(cart.items[0].quantity).toBe(4);
    expect(cart.total).toBe(39.96);
  });

  it('should track save count', async () => {
    await useCase.execute('product-1', 1, 9.99);
    await useCase.execute('product-2', 2, 19.99);

    expect(repo.saveCount).toBe(2);
  });
});
```

**Flutter/Dart:**
```dart
// test/unit/track_location_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/domain/use_cases/TrackLocationUseCase.dart';
import 'package:your_app/fixtures/fixtures.dart';

void main() {
  group('TrackLocationUseCase', () {
    late FakeLocationPort locationPort;
    late FakeLoggerPort logger;
    late TrackLocationUseCase useCase;

    setUp(() {
      locationPort = FakeLocationPort();
      logger = FakeLoggerPort();
      useCase = TrackLocationUseCase(locationPort, logger);
    });

    tearDown(() {
      locationPort.reset();
      logger.reset();
    });

    test('returns coordinates when valid', () async {
      locationPort.locationToReturn = CoordinatesFactory.create(
        lat: 40.7128,
        lng: -74.0060,
      );

      final result = await useCase.execute();

      expect(result.lat, 40.7128);
      expect(result.lng, -74.0060);
      expect(logger.infoCount, 1);
      expect(locationPort.getCurrentLocationCount, 1);
    });

    test('throws exception for zero coordinates', () async {
      locationPort.locationToReturn = CoordinatesFactory.createInvalid();

      expect(() => useCase.execute(), throwsException);
    });

    test('logs tracking message', () async {
      locationPort.locationToReturn = CoordinatesFactory.create();

      await useCase.execute();

      expect(logger.messages.length, 1);
      expect(logger.messages.first, contains('Tracking location'));
    });
  });
}
```

**Rust:**
```rust
// domain/tests/save_document_test.rs
use domain::models::Document;
use domain::ports::FileRepository;
use domain::use_cases::save_document;
use std::collections::HashMap;
use std::cell::RefCell;

struct FakeFileRepository {
    storage: RefCell<HashMap<String, Document>>,
    save_count: RefCell<u32>,
}

impl FakeFileRepository {
    fn new() -> Self {
        Self {
            storage: RefCell::new(HashMap::new()),
            save_count: RefCell::new(0),
        }
    }

    fn save_count(&self) -> u32 {
        *self.save_count.borrow()
    }

    fn clear(&self) {
        self.storage.borrow_mut().clear();
        *self.save_count.borrow_mut() = 0;
    }
}

impl FileRepository for FakeFileRepository {
    fn save(&self, doc: &Document) -> Result<(), String> {
        self.storage.borrow_mut().insert(doc.id.clone(), doc.clone());
        *self.save_count.borrow_mut() += 1;
        Ok(())
    }

    fn find_by_id(&self, id: &str) -> Result<Option<Document>, String> {
        Ok(self.storage.borrow().get(id).cloned())
    }
}

#[test]
fn test_save_document_success() {
    let repo = FakeFileRepository::new();
    let result = save_document("Hello World", &repo);

    assert!(result.is_ok());
    assert_eq!(repo.storage.borrow().len(), 1);
    assert_eq!(repo.save_count(), 1);
}

#[test]
fn test_save_document_empty_content_fails() {
    let repo = FakeFileRepository::new();
    let result = save_document("", &repo);

    assert!(result.is_err());
    assert!(result.unwrap_err().contains("empty"));
    assert_eq!(repo.save_count(), 0);
}
```

**MicroPython:**
```python
# tests/unit/test_pump_controller.py
import pytest
from domain.use_cases.pump_controller import PumpController
from tests.fixtures.fakes import FakeRelayPort, FakeLoggerPort

@pytest.fixture
def relay():
    return FakeRelayPort()

@pytest.fixture
def logger():
    return FakeLoggerPort()

@pytest.fixture
def controller(relay, logger):
    return PumpController(relay, logger)

def test_toggle_irrigation_starts(controller, relay, logger):
    controller.toggle_irrigation()

    assert relay.is_on is True
    assert controller.state.is_active is True
    assert logger.info_count == 1
    assert "started" in logger.messages[0][1]

def test_toggle_irrigation_stops(controller, relay, logger):
    controller.toggle_irrigation()
    controller.toggle_irrigation()

    assert relay.is_on is False
    assert controller.state.is_active is False
    assert "stopped" in logger.messages[1][1]

def test_toggle_irrigation_logs_both_states(controller, logger):
    controller.toggle_irrigation()
    controller.toggle_irrigation()

    assert logger.info_count == 2
    assert "started" in logger.messages[0][1]
    assert "stopped" in logger.messages[1][1]
```

### Integration Tests (Using Fixtures)

```python
# tests/integration/conftest.py
import pytest
from adapters.firestore_adapter import FirestoreDocAdapter
from tests.fixtures import DocumentFactory, FakeDocumentRepo

@pytest.fixture(scope="session")
def firestore_adapter():
    adapter = FirestoreDocAdapter("test_documents")
    yield adapter
    # Cleanup after all tests

@pytest.fixture
def test_document():
    return DocumentFactory.create(doc_id="integration-test-123")

@pytest.fixture
def populated_repo():
    repo = FakeDocumentRepo()
    from tests.fixtures import DocumentFactory
    docs = DocumentFactory.create_batch(5)
    for doc in docs:
        repo.save(doc)
    return repo

# tests/integration/test_firestore_adapter.py
def test_firestore_save_and_retrieve(firestore_adapter, test_document):
    firestore_adapter.save(test_document)
    retrieved = firestore_adapter.find_by_id(test_document.id)
    assert retrieved is not None
    assert retrieved.content == test_document.content
```

### E2E Tests (Using Fixtures)

```python
# tests/e2e/conftest.py
import pytest
from fastapi.testclient import TestClient
from main import app
from tests.fixtures import DocumentFactory

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def sample_document():
    return DocumentFactory.create(doc_id="e2e-test-123", content="E2E test content")

# tests/e2e/test_api.py
def test_create_document_endpoint(client, sample_document):
    response = client.post(
        f"/docs/{sample_document.id}",
        json={"text": sample_document.content}
    )
    assert response.status_code == 200
    assert response.json()["id"] == sample_document.id

def test_create_multiple_documents(client):
    from tests.fixtures import DocumentFactory
    docs = DocumentFactory.create_batch(3)

    for doc in docs:
        response = client.post(f"/docs/{doc.id}", json={"text": doc.content})
        assert response.status_code == 200
```

## Golden Rules for Multi-Platform

1. **The DTO Boundary** — Adapters must translate external formats (JSON, SQL rows, raw bytes) into Pure Domain Models before passing them inward
2. **Never import external frameworks in Domain** — No `import { Component }` in Angular, no `package:flutter` in Dart, no `#include <Arduino.h>` in C++
3. **Mocking is Universal** — All platforms use Interfaces for Ports, enabling pure in-memory Mocks in any language
4. **Infrastructure Stays Separate** — Logging, config, caching go in `infra/`, never in domain
5. **Error Handling in Domain** — Business rule errors are domain exceptions; infrastructure errors are adapter concerns
6. **Composition Root is the Only Place** — Only `main.py` or equivalent reads env vars and creates concrete instances
7. **Fixtures Enable Reuse** — Shared test data, factories, and fakes live in `tests/fixtures/`, not scattered across tests
8. **uv for Python** — Use `uv init --no-package` for script-based projects, `uv add` for dependencies
9. **justfile for Commands** — Use `just` to manage project tasks (run, test, lint, format, typecheck)

## When to Use

- Complex business logic that needs isolation from frameworks
- Applications requiring multiple data sources or external services
- Systems where testability and maintainability are priorities
- Projects where you may swap infrastructure (databases, APIs, frameworks)
- Multi-platform apps sharing domain logic across backend/frontend/mobile/embedded

## Decision Checklist

```
Building a new feature?
├─ Define Domain Models first (pure data, no imports)
├─ Create Ports for any external dependency (Protocol/Interface)
├─ Implement Workflows using only Ports (zero infra imports)
├─ Create infra/ modules for cross-cutting concerns
├─ Build Adapters for specific infrastructure
├─ Create tests/fixtures/ with factories, builders, and fakes
├─ Write unit tests with Fake Adapters using shared fixtures
├─ Write integration tests for real Adapters
└─ Wire everything in Main/Composition Root
```

## Directory Structure

**Small projects:**
```
project/
├── domain/
│   ├── models.py
│   ├── errors.py
│   ├── ports.py
│   └── workflows.py
├── infra/
│   ├── config.py
│   └── logging.py
├── adapters/
│   └── firestore_adapter.py
├── tests/
│   ├── fixtures/
│   │   ├── factories.py
│   │   └── fakes.py
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── main.py
├── pyproject.toml
├── justfile
└── uv.lock
```

**Larger projects:**
```
project/
├── domain/
│   ├── models/
│   ├── errors/
│   ├── ports/
│   └── workflows/
├── infra/
│   ├── config.py
│   ├── logging.py
│   ├── caching.py
│   ├── metrics.py
│   ├── events.py
│   └── auth.py
├── adapters/
│   ├── firestore_adapter.py
│   ├── local_storage_adapter.py
│   └── redis_adapter.py
├── tests/
│   ├── fixtures/
│   │   ├── factories.py
│   │   ├── builders.py
│   │   └── fakes/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── main.py
├── pyproject.toml
├── justfile
└── uv.lock
```
