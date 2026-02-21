---
name: solana-mobile-dev
description: Mobile-first Solana development playbook. Covers MWA 2.0 protocol, Expo/React Native and Kotlin/Jetpack Compose, dApp Store publishing, Seed Vault, Seeker device features, SKR token integration, iOS workarounds, and mobile testing strategies. Complements solana-dev for program and web client work.
user-invocable: true
---

# Solana Mobile Development Skill

## What this Skill is for
Use this Skill when the user asks for:
- Solana mobile dApp development (React Native / Expo / Kotlin)
- Mobile Wallet Adapter (MWA) connection and signing flows
- dApp Store publishing (APK packaging, Publisher Portal, CLI)
- Seeker device features (Seed Vault, SGT verification, SKR integration)
- iOS Solana app strategies (Safari Web Extensions, deeplinks, embedded wallets)
- Mobile testing (emulator, Mock MWA Wallet, physical device)
- Converting a web dApp to a mobile or PWA-wrapped Android app

For on-chain program development, web UI, or program-level testing, use `/solana-dev` instead.

## Default stack decisions (opinionated)

### 1) Framework selection
| Scenario | Use |
|----------|-----|
| Cross-platform mobile dApp | **Expo + React Native** (official template, fastest path) |
| Native Android performance | **Kotlin + Jetpack Compose** (direct MWA clientlib-ktx) |
| Existing web app → mobile | **PWA wrapped as TWA** (Trusted Web Activity for dApp Store) |
| Flutter project | **Espresso Cash SDK** (community-maintained, not official) |

### 2) MWA: protocol-kit first
- Use `@solana-mobile/mobile-wallet-adapter-protocol-kit` for `@solana/kit` types.
- Fall back to `@solana-mobile/mobile-wallet-adapter-protocol-web3js` only when
  integrating libraries that require web3.js objects.
- Use `@solana-mobile/mobile-wallet-adapter-protocol` (base) for framework-agnostic work.

### 3) Wallet Standard on web
- Use `@solana-mobile/wallet-standard-mobile` to register MWA as a Wallet Standard wallet.
- Call `registerMwa()` in the app root (non-SSR context).
- On mobile browsers: local connection via Android Intents.
- On desktop: optional remote connection via QR code (`remoteHostAuthority`).

### 4) iOS strategy (no MWA on iOS)
MWA requires Android Intents and local WebSocket servers — neither exist on iOS.

| Approach | When to use |
|----------|-------------|
| Safari Web Extension wallets (Phantom, Solflare) | Web app viewed in mobile Safari |
| In-app browser (Phantom, Solflare, Ultimate) | User opens your URL inside wallet app |
| Embedded wallets (Privy) | You need seamless onboarding without external wallet |
| Phantom deeplinks | Simple sign/send flows, Phantom-only users |

### 5) Required polyfills (React Native / Expo)
Solana JS libraries assume browser/Node APIs. Always install:

| Polyfill | Package | Import order |
|----------|---------|-------------|
| `getRandomValues` | `react-native-get-random-values` | **First** (before any Solana import) |
| `Buffer` | `buffer` | Second |
| `TextEncoder` | `text-encoding` | Third |

Import these at the very top of your app entry point, before any `@solana/*` imports.

### 6) Expo constraints
- **Expo Go does not work** — native MWA modules require a custom development build.
- **Use yarn** — the Expo template has compatibility issues with npm/npx/pnpm.
- Build with `npx expo prebuild` then `npx expo run:android` for dev builds.

### 7) dApp Store publishing
- **APK format only** — no AAB (Android App Bundle).
- **New signing key required** — cannot reuse a Google Play signing key.
- **On-chain NFTs** — Publisher NFT, App NFT, and Release NFT are minted to describe the submission.
- **Publisher Portal** (publish.solanamobile.com) for most developers.
- **`@solana-mobile/dapp-store-cli`** for CI/CD automation.

## Platform matrix

| Capability | Android | iOS |
|-----------|---------|-----|
| MWA (native wallet connection) | Full support | Not available |
| dApp Store publishing | Supported (APK) | Not applicable |
| Seed Vault (hardware keys) | Saga / Seeker only | Not available |
| Wallet Standard (web) | Via `wallet-standard-mobile` | Via Safari Web Extensions |
| React Native / Expo | Full MWA support | Standard RN (no MWA) |
| Kotlin native | Full support | Not applicable |
| PWA wrapping (TWA) | Supported | Not applicable |

## Operating procedure

### 1. Classify the task
- **Cross-platform Expo app** — use the official Expo template
- **Native Android app** — Kotlin + Jetpack Compose scaffold
- **Web app needing mobile wallet support** — add `wallet-standard-mobile`
- **PWA → dApp Store** — TWA wrapping + Digital Asset Links
- **iOS support** — pick an iOS strategy from the table above

### 2. Pick the right building blocks

**React Native / Expo:**
| Need | Package |
|------|---------|
| MWA with Kit types | `@solana-mobile/mobile-wallet-adapter-protocol-kit` |
| MWA with web3.js types | `@solana-mobile/mobile-wallet-adapter-protocol-web3js` |
| MWA base protocol | `@solana-mobile/mobile-wallet-adapter-protocol` |
| Wallet adapter plugin | `@solana-mobile/wallet-adapter-mobile` |
| Wallet Standard (web) | `@solana-mobile/wallet-standard-mobile` |
| Expo template | `@solana-mobile/solana-mobile-expo-template` |

**Kotlin / Android native:**
| Need | Dependency |
|------|-----------|
| MWA client | `com.solanamobile:mobile-wallet-adapter-clientlib-ktx:2.0.3` |
| Solana web3 | `com.solanamobile:web3-solana:0.2.5` |
| RPC calls | `com.solanamobile:rpc-core:0.2.7` |
| Seed Vault (wallet devs only) | `com.solanamobile:seedvault-wallet-sdk:0.4.0` |

### 3. Implement with mobile-specific correctness

**MWA session pattern (the core pattern for all mobile wallet interactions):**
```javascript
import { transact } from '@solana-mobile/mobile-wallet-adapter-protocol-web3js';

await transact(async (wallet) => {
  // 1. Authorize (or reauthorize with cached token)
  const auth = await wallet.authorize({
    cluster: 'devnet',
    identity: {
      name: 'My dApp',
      uri: 'https://mydapp.com',
      icon: 'favicon.ico',
    },
  });

  // 2. Sign
  const signed = await wallet.signTransactions({
    transactions: [transaction],
  });

  // 3. Send (or use signAndSendTransactions for atomic sign+send)
});
```

Always be explicit about:
- **Authorization caching** — persist auth tokens across sessions to avoid re-prompting
- **Cluster** — specify `mainnet-beta`, `devnet`, or `testnet` in authorize calls
- **Identity** — provide `name`, `uri`, and `icon` for wallet UI display
- **Error handling** — MWA can reject (user declines, wallet not found, session timeout)
- **Fee payer + recent blockhash** — same as web, but obtained within the `transact` session

### 4. Test

| Method | When to use |
|--------|-------------|
| **Android Emulator + Mock MWA Wallet** | Unit testing MWA flows without a physical device |
| **Physical Android + real wallet** | Integration testing (Phantom, Solflare, Ultimate) |
| **Devnet** | On-chain testing without real SOL |
| **Expo custom dev build** | Required — Expo Go cannot run native MWA modules |

Mock MWA Wallet setup:
- Install from `solana-mobile/mock-mwa-wallet` on the emulator
- Emulator **must** have authentication (PIN/biometric) set up or connection will fail

### 5. Publish to dApp Store
1. Build a signed release APK (not AAB)
2. Generate a **new** signing key (do not reuse Google Play key)
3. Prepare assets: 512x512 icon, 1200x600 banner
4. Go to publish.solanamobile.com or use `@solana-mobile/dapp-store-cli`
5. Comply with dApp Store policies (crypto features are unrestricted)

### 6. Deliverables expectations
When you implement changes, provide:
- Exact files changed + diffs
- Commands to install, build, and run on emulator/device
- Platform notes (Android-only, iOS workaround needed, etc.)
- A short "risk notes" section for anything touching signing, fees, or token transfers

## Seeker device features

### Seed Vault
- Hardware-backed key storage in a Trusted Execution Environment (TEE)
- Stores up to 8 seeds, each with unique password + optional biometrics
- **For wallet developers only** — dApp developers interact via MWA, not Seed Vault directly

### Seeker Genesis Token (SGT)
- Unique NFT minted once per Seeker device
- Use for: anti-Sybil verification, exclusive features, device ownership proof
- Verify on backend with Sign-In-With-Solana + SGT check

### SKR Token
- Governance/utility token of the Solana Mobile ecosystem
- Supports governance, staking, and dApp Store curation
- `.skr` domain resolution available via AllDomains

### Detecting Seeker users
Use the recipe at docs.solanamobile.com/recipes/general/detecting-seeker-users
to conditionally enable Seeker-specific features.

## Key references

### Official documentation
- Solana Mobile Docs: https://docs.solanamobile.com
- MWA Spec: https://solana-mobile.github.io/mobile-wallet-adapter/spec/spec.html
- Expo Setup: https://docs.solanamobile.com/react-native/expo
- Kotlin Setup: https://docs.solanamobile.com/android-native/setup
- dApp Store Publishing: https://docs.solanamobile.com/dapp-publishing/overview
- Publisher Portal: https://publish.solanamobile.com

### GitHub repositories
- Main SDK: https://github.com/solana-mobile/solana-mobile-stack-sdk
- MWA Protocol: https://github.com/solana-mobile/mobile-wallet-adapter
- Expo Template: https://github.com/solana-mobile/solana-mobile-expo-template
- Kotlin Scaffold: https://github.com/solana-mobile/solana-kotlin-compose-scaffold
- Mock MWA Wallet: https://github.com/solana-mobile/mock-mwa-wallet
- dApp Publishing: https://github.com/solana-mobile/dapp-publishing
- Seed Vault SDK: https://github.com/solana-mobile/seed-vault-sdk
- Tutorial Apps: https://github.com/solana-mobile/tutorial-apps
- Sample Apps: https://github.com/solana-mobile/react-native-samples
- Safari Extension Wallet: https://github.com/solana-mobile/SolanaSafariWalletExtension
- MWA Wallet Registry: https://github.com/solana-mobile/mobile-wallet-adapter-registry
- Official Mobile Dev Skill: https://github.com/solana-mobile/solana-mobile-dev-skill

### Tutorials and courses
- Intro to Solana Mobile: https://solana.com/developers/courses/mobile/intro-to-solana-mobile
- Building with Expo: https://solana.com/developers/courses/mobile/solana-mobile-dapps-with-expo
- MWA Deep Dive: https://solana.com/developers/courses/mobile/mwa-deep-dive
- QuickNode RN Guide: https://www.quicknode.com/guides/solana-development/dapps/build-a-solana-mobile-app-on-android-with-react-native
- Blueshift Mobile Fundamentals: https://learn.blueshift.gg/en/courses/mobile-dapp-fundamentals
- Blueshift dApp Store Publishing: https://learn.blueshift.gg/en/courses/dapp-store-publishing

### Polyfill guides
- web3.js: https://docs.solanamobile.com/react-native/polyfill-guides/web3-js
- Anchor: https://docs.solanamobile.com/react-native/polyfill-guides/anchor
- spl-token: https://docs.solanamobile.com/react-native/polyfill-guides/spl-token

### NPM packages
- `@solana-mobile/mobile-wallet-adapter-protocol` — base MWA protocol
- `@solana-mobile/mobile-wallet-adapter-protocol-kit` — MWA with @solana/kit types (v0.2.1)
- `@solana-mobile/mobile-wallet-adapter-protocol-web3js` — MWA with web3.js types (v2.2.5)
- `@solana-mobile/wallet-adapter-mobile` — wallet-adapter plugin (v2.2.5)
- `@solana-mobile/wallet-standard-mobile` — MWA as Wallet Standard wallet
- `@solana-mobile/solana-mobile-expo-template` — Expo template (v3.0.0)
- `@solana-mobile/dapp-store-cli` — dApp Store publishing CLI (v0.15.0)

## Progressive disclosure (companion docs, add when needed)
- MWA 2.0 protocol deep dive: [mwa-protocol.md](mwa-protocol.md)
- Expo setup and gotchas: [expo-setup.md](expo-setup.md)
- iOS workarounds: [ios-workarounds.md](ios-workarounds.md)
- dApp Store publishing flow: [dapp-store-publishing.md](dapp-store-publishing.md)
- Seed Vault integration (wallet devs): [seed-vault.md](seed-vault.md)
- Kotlin / Jetpack Compose patterns: [kotlin-native.md](kotlin-native.md)
- PWA to TWA wrapping: [pwa-wrapping.md](pwa-wrapping.md)
