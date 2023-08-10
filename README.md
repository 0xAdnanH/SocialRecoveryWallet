# Social Recovery Wallet

The Social Recovery Wallets are the next great type of wallets as pointed by [Vitalik's post](https://vitalik.ca/general/2021/01/11/recovery.html). It offers the ability to choose guardians who can recover access to the wallet if the owner loses access to their account.

## Goals of the Project

The project's objectives are:

- **Enhance User Experience in Smart Contract Wallets:** Recognizing that many individuals lose access to their private keys and consequently their accounts, the project aims to enhance user experience by implementing a social recovery mechanism. This mechanism allows friends and designated services to recover access on behalf of the owner in case of access loss.

## Technicalities of the Project

- **Smart Contract Wallet Re-usability After Recovery:** Even after guardians recover ownership for the owner, the smart contract wallet remains reusable for subsequent recovery attempts. Guardian votes are reset upon each successful recovery, preserving the wallet's effectiveness for future use.

- **Usage of EnumerableSet from OpenZeppelin Library:** The project leverages the `EnumerableSet` data structure from the OpenZeppelin library. This smart contract library aids in managing elements within an array using mappings with underlying structs. This helps in efficiently tracking guardian addresses and numbers within the wallet contract.

- **Voting Mechanism for Guardians:** Initially set by the owner, guardians have the ability to vote for a specific address to pass ownership of the wallet. These votes remain independent for each successful recovery, ensuring transparency and accuracy in the recovery process.

**Note:** Social recovery wallets are crucial in the context of decentralized applications and wallets, as highlighted by Vitalik Buterin. This project is aimed at exploring and implementing such mechanisms to improve user access recovery in a decentralized environment. This project serves an educational purpose, it is not intended for production deployment.


## Installation

### Cloning the Repository

To begin with the Social Recovery Wallet project, clone the repository and install its dependencies:

```bash
$ git clone https://github.com/0xAdnanH/SocialRecoveryWallet.git
$ cd ./SocialRecoveryWallet
$ npm install
```


### Instructions

#### Compile

To Compile the contract run:

```bash
$ npx hardhat compile
```

#### Tests

To run the unit tests:

```bash
$ npx hardhat test
```
