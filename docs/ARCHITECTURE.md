# ⚡ ElectricalAI Pro Architecture

## Philosophy

ElectricalAI Pro is designed using a modular architecture.

Every file should have one responsibility.

Large files should be divided into smaller modules.

The application should remain clean, readable, and easy to maintain.

---

# Project Structure

ElectricalAI-Pro/

backend/
Python API
AI
Calculators
Database

frontend/
Flutter

docs/

assets/

tests/

---

# Backend Responsibilities

The backend contains:

- NVIDIA AI communication
- Electrical calculators
- Material estimator
- Diagram analysis
- PDF search
- Project data
- Authentication (future)

---

# Frontend Responsibilities

The frontend contains:

- Mobile interface
- Desktop interface
- Navigation
- User interaction
- Settings
- Themes

The frontend should never contain business logic.

---

# AI Module

Responsible for:

- Chat
- Prompt management
- NVIDIA communication
- Conversation memory

---

# Calculator Module

Responsible for:

- Ohm's Law
- Voltage Drop
- Conduit Fill
- Box Fill
- Motor Calculations
- Transformer Calculations

Each calculator should exist in its own file.

---

# Documentation

Every major feature should be documented.

Complex code should include comments.

---

# Git Workflow

Build

Test

Commit

Never commit broken code.

---

# Coding Standards

- Follow PEP 8
- Descriptive function names
- Small functions
- Modular code
- Reusable components
- No duplicated code

---

# Project Goal

Create software that electricians trust.

Every feature should solve a real-world problem.