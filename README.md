# DigitalCourtServer

💧 A project built with the Vapor web framework for digital court proceedings.

## Getting Started

## Prerequisites
- Swift 5.10 or later
- PostgreSQL database

## Environment Variables

The following environment variables are required:

- `JWT_SECRET` - Secret key for JWT token signing
- `DATABASE_HOST` - PostgreSQL database host (default: localhost)
- `DATABASE_PORT` - PostgreSQL database port (default: 5432)
- `DATABASE_USERNAME` - PostgreSQL database username (default: postgres)
- `DATABASE_PASSWORD` - PostgreSQL database password (no default)
- `DATABASE_NAME` - PostgreSQL database name (default: digitalcourt)
- `DATABASE_URL` - Complete PostgreSQL database URL (optional - if provided, other DB variables are ignored)

## Local Development

### Option 1: Using Docker (Recommended)

1. Make sure Docker is installed and running on your system.
2. Start the services: