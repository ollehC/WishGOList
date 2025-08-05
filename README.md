# WishGO List

## Quick Start

1. **Read CLAUDE.md first** - Contains essential rules for Claude Code
2. Follow the pre-task compliance checklist before starting any work
3. Use proper module structure under `src/main/flutter/`
4. Commit after every completed task

## Project Overview

**WishGO List** is a cross-platform Flutter shopping wishlist app for iOS and Android that helps users manage items they want to buy with the following features:

- Save product URLs, extract images and source info
- Record reasons for purchase
- Organize, categorize, and tag items
- Manage the full process from pre-purchase to post-purchase
- Track orders manually

### Free Tier Features
- Add items via URL with OpenGraph auto-fetch (image + title)
- Manual edits: product name, price, notes
- Status: To Buy / Purchased / Dropped
- Tagging (max 5 tags)
- Card/List View (Pinterest-like UI)
- Local storage, no login required
- 1 collection folder
- Manual order/tracking number entry (max 2 entries)

### Premium Features
- Price tracking + drop alerts (via API)
- Unlimited tags & multiple custom lists
- Upload custom images & change UI theme (dark mode, icons)
- Export (CSV, PDF, Google Sheet)
- Firebase Firestore sync
- *Desire Level* (1–5 hearts)
- Batch operations
- Unlimited order tracking (future AfterShip/17track API support)
- Shopping analytics: trends, totals, visual charts

## Flutter Project Structure

Choose the structure that fits your project:

**Standard Flutter App:** Full application structure with modular organization following Flutter best practices

## Development Guidelines

- **Always search first** before creating new files
- **Extend existing** functionality rather than duplicating  
- **Use Task agents** for operations >30 seconds
- **Single source of truth** for all functionality
- **Flutter-specific structure** - works with Dart/Flutter ecosystem
- **Scalable** - start simple, grow as needed
- **Cross-platform** - supports both iOS and Android# Auto-backup test
# Hook script syntax fixed
