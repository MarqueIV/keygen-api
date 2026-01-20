# CLAUDE.md

This file provides guidance for Claude Code when working with the Keygen API codebase.

## Project Overview

Keygen is a fair source software licensing and distribution API built with Ruby on Rails. It provides license key validation, device activation, entitlements management, and software distribution (acting as a package registry for RubyGems, NPM, PyPI, OCI, and more).

**Editions**: CE (Community) and EE (Enterprise)
**Modes**: singleplayer (single-tenant) and multiplayer (multi-tenant)

## Tech Stack

- **Ruby**: 3.4.7 with YJIT enabled in production
- **Rails**: 8.x (API-only)
- **Database**: PostgreSQL 17+ with UUID primary keys
- **Cache/Jobs**: Redis + Sidekiq
- **Authorization**: ActionPolicy
- **API Format**: JSON:API specification

## Common Commands

### Development

```bash
bundle install                    # Install dependencies
bundle exec rails keygen:setup    # Full setup (db create, migrate, seed)
bundle exec rails db:migrate      # Run migrations
bundle exec rails server          # Start Rails server
bundle exec sidekiq               # Start background job worker
bundle exec rails console         # Rails console
```

### Testing

```bash
bundle exec rake test:setup                           # Setup test environment
bundle exec rake test                                 # Run all tests (RSpec + Cucumber)
bundle exec rake test:rspec                           # Run RSpec only
bundle exec rake test:rspec[spec/models/license_spec.rb]  # Run specific spec file
bundle exec rake test:rspec[spec/models]              # Run specs in directory
bundle exec rake test:cucumber                        # Run Cucumber features only
bundle exec rake test:cucumber[features/api/v1/licenses]  # Run specific feature directory
bundle exec rake test:cucumber[features/api/v1/licenses/actions/validations.feature:369]  # Run specific line
```

### Docker

```bash
docker compose up -d postgres redis    # Start dependencies
docker compose up web worker           # Start API and worker
```

## Project Structure

```
app/
├── controllers/api/v1/    # REST API controllers
├── models/                # ActiveRecord models with concerns
├── policies/              # ActionPolicy authorization
├── serializers/           # JSON:API response serializers
├── services/              # Business logic (LicenseValidationService, etc.)
├── workers/               # Sidekiq background jobs
└── validators/            # Custom validators

config/
├── routes.rb              # API routing
├── schedule.yml           # Sidekiq cron jobs
└── initializers/          # Gem configurations

spec/                      # RSpec tests
features/                  # Cucumber BDD tests
├── api/v1/
├── step_definitions/
└── support/

db/
├── migrate/               # Database migrations
└── schema.rb              # Current schema
```

## Code Conventions

- **Frozen string literals**: All Ruby files must start with `# frozen_string_literal: true`
- **Indentation**: 2 spaces
- **Strings**: Single quotes preferred unless interpolation needed
- **Naming**: CamelCase classes, snake_case methods/variables

## Architecture Patterns

### Controllers
- REST conventions with nested resources
- Inherit from `Api::V1::BaseController`
- Use `before_action` for authentication/authorization
- Render with JSON:API serializers

### Models
- Use concerns for shared behavior (Accountable, Environmental, Limitable, etc.)
- UUID primary keys via `uuid-ossp` extension
- State machines via AASM gem
- Encrypted attributes via Rails 8 Active Record Encryption

### Services
- Business logic lives in `app/services/`
- Key services: `LicenseValidationService`, `LicenseCheckoutService`, `MachineCheckoutService`
- Billing services in `app/services/billings/`

### Authorization
- ActionPolicy in `app/policies/`
- Permissions are granular (e.g., `license.read`, `license.create`)
- Context includes: account, environment, bearer, token

### API Design
- JSON:API format with `application/vnd.api+json` content type
- Versioned at `/v1/`
- Request migrations for backwards compatibility
- Nested resource relationships

## Testing Guidelines

- **RSpec**: Unit tests for models, policies, services
- **Cucumber**: Integration/BDD tests for API endpoints
- **Factories**: Use FactoryBot factories in `spec/factories/`
- Tests run in parallel (up to 14 parallel databases)
- CI matrix: 2 editions (CE/EE) x 2 modes = 4 test configurations

## Key Models

- `Account`: Tenant/organization
- `License`: Core license entity
- `Machine`: Device/machine tracking for activations
- `Policy`: License policy rules (expiration, limits, etc.)
- `User`: Account users
- `Token`: API authentication tokens
- `Release`/`Artifact`: Software distribution
- `EventLog`: Audit trail

## Environment Variables

Key variables (see `.env.sample` for full list):

- `SECRET_KEY_BASE`: Rails secret
- `DATABASE_URL`: PostgreSQL connection
- `REDIS_URL`: Redis connection
- `KEYGEN_EDITION`: `CE` or `EE`
- `KEYGEN_MODE`: `singleplayer` or `multiplayer`
- `ENCRYPTION_*_KEY`: Rails encryption keys

## Important Notes

- Never commit secrets or credentials
- Run tests before submitting PRs
- Database uses pgbouncer for connection pooling in production
- Background jobs are critical for webhooks, cleanup, and async operations
