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
    address cohart;
    address ownerNFT;
    
    struct split{
        address personA;
        uint PerA;
        address personB;
        uint PerB;
        address personC;
        uint PerC;
    }
    struct NFT{
        address minter;
        uint tokenID;
    }

    mapping(uint => NFT) public NFTrecord ;
    mapping(uint => uint) public NFTPrice;
    mapping(uint => split) public share;
    mapping(uint => address) public record;

    constructor() ERC721("cohart", "CHA") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        NFTrecord[tokenId].minter = msg.sender;
        NFTrecord[tokenId].tokenID = tokenId;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    function setCohartAddress(address _cohart) public onlyOwner{ //set address for Cohart add(where share the revenue)
        cohart =_cohart;
    }
    function setForsale(uint tokenId ,uint price) public {
        require(price > 0 , "Please set price");
        require(NFTrecord[tokenId].minter == msg.sender ,"Invalid user" );
        NFTPrice[tokenId] = price;
        record[tokenId] = msg.sender;
        ERC721(address(this)).transferFrom(msg.sender,address(this),tokenId);
    }
    function setPersonA(uint tokenId, address _personA ,uint perA) public {
        require(NFTrecord[tokenId].minter == msg.sender ,"You Are not Holder");
        if(currentSell <= 30){
            require(perA <= 45 ,"you Have to set less than 45");
            share[tokenId].personA = _personA;
            share[tokenId].PerA = perA;
        }else if (currentSell > 30 ) {
            require(perA <= 15 ,"you have to set less than 15");
            share[tokenId].personA = _personA;
            share[tokenId].PerA = perA;
        }

    }
    function setPersonB(uint tokenId, address _personB ,uint perB) public {
        require(NFTrecord[tokenId].minter == msg.sender ,"You Are not Holder");
        require(share[tokenId].personA != address(0), "First set PersonA");
         if(currentSell <= 30){
            require(perB <= 45 ,"you Have to set less than 45");
            uint lastper = 45 - share[tokenId].PerA  ;
            require(perB < lastper ,"please enter perfect percentage");
            require(perB <= lastper);
            share[tokenId].personB = _personB;
            share[tokenId].PerB = perB;
        }else if (currentSell > 30 ) {
            require(perB <= 15 ,"you have to set less than 15");
            uint lastper = 15 - share[tokenId].PerB;
            require(perB < lastper ,"please enter perfect percentage");
            share[tokenId].personB = _personB;
            share[tokenId].PerB = perB;
        }
    }
    function setPersonC(uint tokenId, address _personC ,uint perC) public {
        require(NFTrecord[tokenId].minter == msg.sender ,"You Are not Holder");
        require(share[tokenId].personB != address(0), "First set PersonB");
         if(currentSell <= 30){
            require(perC <= 45 ,"you Have to set less than 45");
            uint lastper = 45 - share[tokenId].PerB  ;
            require(perC < lastper ,"please enter perfect percentage");
            share[tokenId].personC = _personC;
            share[tokenId].PerC = perC;
        }else if (currentSell > 30 ) {
            require(perC <= 15 ,"you have to set less than 15");
            uint lastper = 15 - share[tokenId].PerB  ;
            require(perC < lastper ,"please enter perfect percentage");
            share[tokenId].personC = _personC;
            share[tokenId].PerC = perC;
        }
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    function buyNFT(uint tokenId) public payable{     
       require(NFTPrice[tokenId] >= msg.value ,"Please pay");
         if (currentSell <= 30) { // for testing change current no
            uint amountOfOnwer =  50* msg.value / 100;
            uint amountOfsplit =  5* msg.value / 100;
            uint forperson1 = share[tokenId].PerA * msg.value / 100;
            uint forperson2 = share[tokenId].PerB * msg.value / 100;
            uint forperson3 = share[tokenId].PerC * msg.value / 100;
            payable (record[tokenId]).transfer(amountOfOnwer);
            payable (cohart).transfer(amountOfsplit);
            if (share[tokenId].personA == address(0)){
                uint finalamount = 45*msg.value/100;
                payable (record[tokenId]).transfer(finalamount);
            }else if (share[tokenId].personA == share[tokenId].personA){
                payable (share[tokenId].personA).transfer(forperson1);
                payable (share[tokenId].personB).transfer(forperson2);
                payable (share[tokenId].personC).transfer(forperson3);
            }
            ERC721(address(this)).safeTransferFrom(address(this), msg.sender, tokenId);
         } else if (currentSell > 30) { // for testing change current no 
            uint amountOfOnwer = 80 * msg.value / 100;
            uint amountOfsplit =  5 * msg.value / 100 ;
            uint forperson1 = share[tokenId].PerA * msg.value / 100;
            uint forperson2 = share[tokenId].PerB * msg.value / 100;
            uint forperson3 = share[tokenId].PerC * msg.value / 100;
            payable (ownerOf(tokenId)).transfer(amountOfOnwer);
            payable (cohart).transfer(amountOfsplit);
           if (share[tokenId].personA == address(0)){
                uint finalamount = 15*msg.value/100;
                payable (record[tokenId]).transfer(finalamount);
            }else if (share[tokenId].personA == share[tokenId].personA){
                payable (share[tokenId].personA).transfer(forperson1);
                payable (share[tokenId].personB).transfer(forperson2);
                payable (share[tokenId].personC).transfer(forperson3);
            } 
            ERC721(address(this)).safeTransferFrom(address(this), msg.sender, tokenId);
         }
        currentSell ++;
    } 
    function withdrawFund() public onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
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