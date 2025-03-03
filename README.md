# MochaMingle
A decentralized platform for coffee enthusiasts to explore recipes, connect, and exchange brewing tips.

## Features
- Create and share coffee recipes 
- Rate and comment on recipes
- User profiles with reputation system
- Recipe ownership tracking
- Built on Stacks blockchain using Clarity

## Setup and Installation
1. Clone the repository
2. Install Clarinet (if not already installed)
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to run test suite

## Usage Examples
```clarity
;; Create a new recipe
(contract-call? .mocha-mingle create-recipe "Cold Brew" "Cold brew recipe..." u3)

;; Rate a recipe
(contract-call? .mocha-mingle rate-recipe u1 u5)

;; Add comment to recipe
(contract-call? .mocha-mingle add-comment u1 "Great recipe!")

;; Get recipe details
(contract-call? .mocha-mingle get-recipe u1)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
