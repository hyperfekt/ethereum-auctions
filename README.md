# ethereum-auctions

Smart contracts for auctioning off either ERC20 tokens or ERC821/ERC721 non-fungible tokens in exchange for either Ether or ERC20 tokens.
Bidding with tokens can either be done by granting the auction contract an allowance, or by transferring ERC777-compliant tokens directly to the auction contract.
Bids can be tracked with either a full word or 12 bytes for reduced gas costs. Use the latter if the total supply of the token is low enough to allow this (for Ether this is the case for the forseeable future).
Make sure to choose the number of blocks the auction is extended by after every bid as one high enough to prevent miners from ignoring bids for purposes of manipulating the auction.  
Setting an increment which is fixed or a fraction of the current bid is possible, this is useful for preventing the auction from going on forever.  

(Currently the factory is too large to be deployed within the gas limit of a single block. Splitting it up or enabling code reuse is being investigated.)