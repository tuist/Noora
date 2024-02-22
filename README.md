<img src="assets/header.svg"/>

Macker is an MIT-licensed and OCI-compliant virtualization tool for macOS environments.
It builds on Apple's powerful [Virtualization](https://developer.apple.com/documentation/virtualization) framework.


## Motivation

With the [Virtualization](https://developer.apple.com/documentation/virtualization) framework, Apple made virtualization a commodity upon which organizations and businesses could develop their virtualization solutions. However, the framework is a very low-level API, and it requires a lot of work to build a virtualization solution on top of it. Macker aims to provide a high-level API that resembles Docker's API and makes the solution compliant with the [OCI specification](https://github.com/opencontainers/image-spec). We developed it for some of our business products, and we are gifting this piece to the community.

> [!NOTE]
> The project is under active development

## Development

### Using Tuist

1. Clone the repository: `git clone https://github.com/tuist/macker.git`
2. Generate the project: `tuist generate`


### Using Swift Package Manager

1. Clone the repository: `git clone https://github.com/tuist/macker.git`
2. Open the `Package.swift` with Xcode