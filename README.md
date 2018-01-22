# ethereum-auctions

Smart contracts for auctioning off either ERC20 tokens or ERC821 non-fungible tokens in exchange for either Ether or ERC20 tokens.  
ERC20 tokens can either be tracked with a full word or 24 bytes for reduced gas costs. Use the latter if the total supply is low enough to allow this.  
Mind that the contract does not protect against siphoning tokens by the ERC20 token contract itself, as it calls it to check balance. This shouldn't be a problem, since you're trusting that contract to behave properly anyway.