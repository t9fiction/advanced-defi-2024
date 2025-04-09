# Makefile for Foundry + Mainnet Forking

# Load .env variables
include .env
export

# Default target
all: build

# Run tests against forked mainnet
test:
	forge test

# Clean build artifacts
clean:
	forge clean

# Compile contracts
build:
	forge build

# Run scripts (example)
# make script FILE=script/MyScript.s.sol
script:
	forge script $(FILE) --fork-url $(FORK_URL)

# Example of setting a specific test file
# make testfile FILE=test/MyTest.t.sol
testfile:
	forge test --match-path $(FILE)

# Run the Mainnet Fork
# Usage: make fork
# This will start a local Ethereum node that forks the mainnet
fork:
	anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/swC3O83771NwEtdRW_EJeprCHcwioCl_