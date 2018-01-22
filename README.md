# ethereum-auctions

Smart contracts for auctioning off either ERC20 tokens or ERC821/ERC721 non-fungible tokens in exchange for either Ether or ERC20 tokens.  
ERC20 tokens can be tracked with either a full word or 24 bytes for reduced gas costs. Use the latter if the total supply is low enough to allow this.  
Make sure to choose the number of blocks the auction is extended by after every bid as one high enough to prevent miners from ignoring bids for purposes of manipulating the auction.  
Setting a threshold which is fixed or a fraction of the current bid is possible, which is useful for preventing the auction from going on forever.  
Mind that the contract does not protect against siphoning tokens by the ERC20 token contract itself, as it calls it to check balance. This shouldn't be a problem, since you're trusting that contract to behave properly anyway.  

  
Auction is the base contract. Combine one of NFTAuction or TokenAuction with one of EtherBidAuction, WordTokenBidAuction or TwentyFourByteTokenBidAuction according to your needs.  