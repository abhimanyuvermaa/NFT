// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 maxSupply=10;

    bool public allowListMintOpen = false;
    bool public publicMintOpen = false;

    mapping(address => uint256) private _tokenCount;
    constructor(address initialOwner)
        ERC721("MyToken", "MTK")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafkreigjq6fhsfwf33qz36kcxqttsxbcbjyaefpwy4bqfpkgta5d6ce7ra/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    function editMintWindows(
      bool _publicMintOpen,
      bool _allowListMintOpen
    ) external onlyOwner{
      publicMintOpen=_publicMintOpen;
      allowListMintOpen=_allowListMintOpen;
    }
    function allowListMint() public payable {
      require(allowListMintOpen,"allowList Mint is Closed");
      require(msg.value==0.001 ether,"Not Enough Funds");
      require(totalSupply() < maxSupply, "We Sold Out!");
      uint256 tokenId = _nextTokenId++;
      _safeMint(msg.sender, tokenId);
    }
    //Add Payment
    //Add limit to Supply
    function publicMint() public payable{
      require(publicMintOpen,"Public Mint is Closed");
        require(msg.value==0.01 ether,"Not Enough Funds");
        require(totalSupply() < maxSupply, "We Sold Out!");
        require(_tokenCount[msg.sender]<2,"You Cannot Hold more than two tokens");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _addr) external onlyOwner {
        // get the balance of the contract
        uint256 balalnce = address(this).balance;
        payable(_addr).transfer(balalnce);
    }

    // Populate the Allow List
    mapping(address => bool) public allowList;
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }
    /*
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    */
    // The following functions are overrides required by Solidity.


    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}