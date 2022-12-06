# Protocol

The Protocol-Engineering Department at ChainSafe Systems hosts all teams
that implement specifications of decentralized ledger technologies as well as
communication protocols. In general, protocols are clearly specified sets of
rules and regulations that determine how data is transmitted and processed,
as well as define the interfaces to access and manipulate even those.

## Overview
Currently, we are engaged with the following Protocols.

- Ethereum Consensus-Layer Specification
  - <https://github.com/ethereum/consensus-specs>
- Polkadot-Host Specification
  - <https://github.com/w3f/polkadot-spec>
- Filecoin Protocol Specification
  - <https://github.com/filecoin-project/specs>
- LibP2P Networking Specifications
  - <https://github.com/libp2p/specs>

We contribute to existing open-source libraries and also maintain our own protocol implementations in-house. Our three main teams are:

- Lodestar: Ethereum Consensus-Layer implementation in TypeScript
  - <https://github.com/ChainSafe/lodestar>
- Forest: Filecoin Full-Node implementation in Rust
  - <https://github.com/ChainSafe/forest>
- Gossamer: Polkadot-Host implementation in Go
  - <https://github.com/ChainSafe/gossamer>

## Lodestar

Lodestar is a collection of libraries that can be bundled into a fully-fledged
Ethereum consensus-layer client. <https://lodestar.chainsafe.io/>

Among others, the following libraries and projects were published along with
the Lodestar client.

- Inspect Ethereum Name Records
  - <https://enr-viewer.com>
  - <https://www.npmjs.com/package/@chainsafe/discv5>
- Serialize and deserialize data for Ethereum's SSZ standard
  - <https://www.simpleserialize.com/>
  - <https://www.npmjs.com/package/@chainsafe/ssz>
  - <https://www.npmjs.com/package/@chainsafe/lodestar-types>
- Generate BLS keypairs for Ethereum testnets
  - <https://www.bls-keygen.com/>
  - <https://www.npmjs.com/package/@chainsafe/bls>
  - <https://www.npmjs.com/package/@chainsafe/bls-hd-key>
  - <https://www.npmjs.com/package/@chainsafe/bls-keygen>
  - <https://www.npmjs.com/package/@chainsafe/bls-keystore>

ChainSafe Systems is also the main contributor and co-maintainer of the JavaScript
LibP2P implementation. <https://github.com/libp2p/js-libp2p>

## Forest

Forest is a highly efficient Rust implementation of the Filecoin specification.
<https://chainsafe.github.io/forest>

Even though the client is not yet feature complete, it provided the canonical
implementation of the Filecoin Virtual Machine and Builtin Actors used by
every other client on the Filecoin network.

- <https://github.com/filecoin-project/ref-fvm>
- <https://github.com/filecoin-project/builtin-actors>

Initially part of the Forest code, these projects and libraries are now
stand-alone components of the Filecoin network and are co-maintained by Filecoin
Foundation and the Forest team.

## Gossamer

Gossamer is a Polkadot host written in Go, a framework to build and run nodes
for different blockchain protocols compatible with the Polkadot ecosystem,
mainly but not limited to the Polkadot and Kusama relay chains. A Gossamer node
can act as an alternative full node for chains such as Polkadot or Kusama.
<https://chainsafe.github.io/gossamer>

The Polkadot host in Go is capable of running multi-node Polkadot relay-chains.
However, the client is not yet feature complete.
