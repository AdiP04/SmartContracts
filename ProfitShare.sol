// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract MyToken is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;
    using SafeMath for uint;

    Counters.Counter private _tokenIdCounter;

    uint  public currentSell;

    mapping(uint => uint) public NFTrecord ;

    constructor() ERC721("Cohart", "CHART") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri ,uint price) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        NFTrecord[tokenId] = price;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    function forSell(address from ,uint tokenId ,address to) public payable{   
        require(NFTrecord[tokenId] <= msg.value ,"Please pay");
         if (currentSell <= 30) { // for testing change current no
            uint amountOfOnwer =  50 * msg.value / 100;
            uint amountOfsplit =  50 * msg.value / 100;
            payable (ownerOf(tokenId)).transfer(amountOfOnwer);
            payable (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4).transfer(amountOfsplit); //put here shareing address
            super.transferFrom(from ,to,tokenId);
         } else if (currentSell > 30) { // for testing change current no 
            uint amountOfOnwer = 80 * msg.value / 100;
            uint amountOfsplit =  20 * msg.value / 100 ;
            payable (ownerOf(tokenId)).transfer(amountOfOnwer);
            payable (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4).transfer(amountOfsplit); //put here shareing address
            super.transferFrom(from ,to,tokenId);
         }
        currentSell ++;
    } 

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}