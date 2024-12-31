# TokenGovernance: A Token-Based Governance System

## Overview
TokenGovernance is a smart contract written in Clarity that enables decentralized, token-based governance. Users can propose motions, cast votes, and track outcomes in a transparent and tamper-proof manner. The system supports proposal submission, voting, and decision-making within defined timeframes.

## Features
- **Motion Submission:** Submit proposals with detailed descriptions and a specific expiry timeframe.
- **Voting Mechanism:** Participants can approve or reject motions, ensuring community involvement.
- **Decision Transparency:** Track proposals and voting outcomes through on-chain records.
- **Admin Controls:** Contract owner can manage expired motions.

## Data Structures

### Constants
- **`CONTRACT_OWNER`:** The address of the contract owner.
- **Error Codes:**
  - `ERR_NOT_AUTHORIZED` (u100): Unauthorized action.
  - `ERR_ALREADY_SUBMITTED` (u101): Vote already submitted.
  - `ERR_MOTION_NOT_FOUND` (u102): Motion does not exist.
  - `ERR_MOTION_EXPIRED` (u103): Motion has expired.
  - `ERR_INVALID_NAME` (u104): Motion name is invalid.
  - `ERR_INVALID_DETAILS` (u105): Motion details are invalid.
  - `ERR_INVALID_TIMEFRAME` (u106): Timeframe is invalid.

### Maps
- **`motions`:** Stores details of motions including name, details, submitter, vote counts, and expiry block.
- **`decisions`:** Stores voting decisions keyed by participant and motion ID.

### Variables
- **`motion-counter`:** Tracks the number of motions submitted.

## Functions

### Read-Only Functions
- **`get-motion (motion-id uint):** Retrieve the details of a specific motion.
- **`get-decision (participant principal, motion-id uint):** Retrieve a participant's decision on a motion.
- **`is-motion-active (motion-id uint):** Check if a motion is still active.

### Private Functions
- **`validate-text-length (text (string-ascii 280), min uint, max uint):** Validates the length of a text input.

### Public Functions

#### Motion Management
- **`submit-motion (name (string-ascii 50), details (string-ascii 280), timeframe uint):**
  - Allows users to submit a new motion.
  - Validates the motion name, details, and expiry timeframe.
  - Stores the motion with an expiry block calculated from the current block height and timeframe.

#### Voting
- **`cast-vote (motion-id uint, approve-bool bool):**
  - Allows users to vote on a motion.
  - Ensures the motion is active and the participant has not already voted.
  - Updates the motion's approve or reject count based on the vote.

#### Admin Actions
- **`end-motion (motion-id uint):**
  - Allows the contract owner to manually close a motion after its expiry.
  - Ensures the motion is expired and sets its expiry block to the current block height.

## Workflow

### 1. Submit a Motion
1. A participant calls `submit-motion` with a motion name, detailed description, and expiry timeframe.
2. The system assigns a unique ID to the motion and records it on-chain.

### 2. Cast a Vote
1. A participant calls `cast-vote` with the motion ID and their decision (approve or reject).
2. The system validates the motion and records the vote.

### 3. End a Motion
1. After the expiry block, the contract owner can call `end-motion` to close the motion.

## Error Handling
- The contract uses `asserts!` to enforce permissions and validate inputs.
- Comprehensive error codes help identify specific issues.

## Development
This smart contract is built using Clarity, the smart contract language for the Stacks blockchain.

### Prerequisites
- [Stacks Blockchain](https://stacks.co/)
- A Clarity-compatible development environment.

### Deployment
1. Clone the repository.
2. Deploy the contract to a Stacks testnet or mainnet.
3. Interact with the contract using Clarity tools or a custom front-end.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

---
For questions or contributions, please open an issue or submit a pull request on the repository.

