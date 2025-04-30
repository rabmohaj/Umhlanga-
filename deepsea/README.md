
# Deep Sea Research Funding Protocol

A Clarity smart contract on the Stacks blockchain that facilitates **transparent sponsorship**, **resource management**, and **station governance** for deep-sea research projects. It enables donors to sponsor research initiatives, provides controlled resource allocation to eligible research stations, and ensures administrative oversight through a designated Chief Scientist.

---

## 🚀 Features

- 🧪 **Research Station Registry**: Chief Scientist can register and manage research stations with status updates.
- 💰 **Sponsorship Mechanism**: Public users can sponsor the research treasury with STX tokens.
- 📊 **Transparent Treasury Management**: Funds are recorded, tracked, and distributed securely.
- 🧑‍🔬 **Chief Scientist Role**: Holds administrative privileges over station registration, resource allocation, and protocol status.
- ⚠️ **Hazard Protocol Toggle**: Temporarily suspends operations during underwater hazards or security incidents.
- ✅ **Research Status Updates**: Keeps a record of each station’s progress (e.g., "ongoing", "completed").
- 🔐 **Governance**: Chief Scientist role can be transferred securely to a new address.

---

## 📁 Contract Overview

### ✅ Constants
| Constant | Description |
|---------|-------------|
| `ERR-NOT-AUTHORIZED` | Caller is not the Chief Scientist |
| `ERR-STATION-ALREADY-REGISTERED` | Station already exists |
| `ERR-STATION-NOT-REGISTERED` | No record of the given station |
| `ERR-RESOURCES-UNAVAILABLE` | Insufficient treasury funds |
| `ERR-SPONSORSHIP-TOO-SMALL` | Sponsor donation below minimum |
| `ERR-PROGRAM-PAUSED` | Contract functions are paused |
| `ERR-SPONSORSHIP-INVALID` | Invalid donation amount |
| `ERR-RESEARCH-STATUS-INVALID` | Invalid status (not predefined) |
| `ERR-INVALID-CHIEF-SCIENTIST-ADDRESS` | Invalid new scientist candidate |

---

## 📊 Data Structures

### 📌 Global Variables

| Variable | Type | Description |
|---------|------|-------------|
| `chief-scientist` | `principal` | Address of the current Chief Scientist |
| `research-treasury` | `uint` | Total STX funds available |
| `program-is-active` | `bool` | Toggle for global contract activity |
| `sponsorship-minimum` | `uint` | Minimum STX donation (default: 1 STX) |
| `hazard-protocol-active` | `bool` | Toggle for hazard-related suspension |

### 📌 Maps

#### `research-stations`
| Field | Type | Description |
|-------|------|-------------|
| `station-active` | `bool` | Indicates if the station is online |
| `resources-allocated` | `uint` | Total STX allocated |
| `last-allocation-block` | `uint` | Block height of last fund transfer |
| `research-status` | `string-ascii 20` | Project status: `pending`, `ongoing`, `completed`, `analyzed` |

#### `sponsor-registry`
| Field | Type | Description |
|-------|------|-------------|
| `total-contributions` | `uint` | Lifetime total of donor's contributions |
| `latest-contribution-block` | `uint` | Most recent donation block height |

---

## 🧑‍💼 Public Functions

### 🎯 Sponsorship
- **`(sponsor-deep-sea-research)`**  
  - Transfers STX to the contract and updates the treasury/sponsor records.

### 🛠️ Station Management
- **`(register-research-station station-address)`**  
  - Adds a new research station (Chief Scientist only).
- **`(allocate-resources station-address resource-amount)`**  
  - Transfers resources from the treasury to a station (Chief Scientist only).
- **`(update-research-status station-address new-status)`**  
  - Updates the current status of a station's research project.

### 🧩 Administrative
- **`(set-sponsorship-minimum new-minimum)`**  
  - Sets a new minimum required STX for sponsorships.
- **`(toggle-program-status)`**  
  - Toggles the `program-is-active` flag.
- **`(set-hazard-protocol-on)` / `(set-hazard-protocol-off)`**  
  - Enable/disable the hazard protocol lock.

### 🧭 Governance
- **`(change-chief-scientist new-chief-scientist-address)`**  
  - Assigns a new Chief Scientist (must not be the contract itself or current scientist).

---

## 🔍 Read-Only Functions

| Function | Returns | Purpose |
|---------|---------|---------|
| `get-chief-scientist` | `principal` | Returns current Chief Scientist address |
| `get-research-treasury` | `uint` | Returns treasury balance |
| `get-station-info station-address` | `(optional ...)` | Returns station details |
| `get-sponsor-info sponsor-address` | `(optional ...)` | Returns donor's sponsorship history |
| `check-program-status` | `bool` | Returns `true` if program is active and not under hazard lock |

---

## ✅ Validations

- **Sponsorship** must be:
  - Greater than 0 STX
  - Less than or equal to `1_000_000_000_000` STX (for sanity)
- **Research Status** must be one of:
  - `pending`, `ongoing`, `completed`, `analyzed`

---

## 🧪 Example Usage

```clarity
;; Chief scientist registers a station
(register-research-station 'SP3...STATION1)

;; A sponsor donates 2 STX
(sponsor-deep-sea-research)

;; Allocate 1 STX to the station
(allocate-resources 'SP3...STATION1 u1000000)

;; Update research status
(update-research-status 'SP3...STATION1 "completed")
```

---

## 🔒 Security Considerations

- Only the Chief Scientist can make administrative changes or allocate resources.
- The hazard protocol can be activated to pause critical operations during anomalies.
- All transfers are validated and use `try!`/`asserts!` to ensure safety and correctness.

---

## 🧱 Future Extensions

- Research progress rewards or NFTs
- DAO-style multi-sig governance for Chief Scientist role
- Integration with real-world sensor oracles (e.g., Chainlink)
- Station performance tracking and rating system

---