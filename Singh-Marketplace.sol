// SPDX-License-Identifier: MIT
pragma solidity^ 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./singhCoinNFT.sol";

contract singhNFTMarketPlace is Ownable{

    using SafeMath for uint;

    uint platFormFee;
    address public feeCollector;
    // address singhNFT;

    struct nftForSell{
        address seller;
        address buyer;
        uint price;
        bool sold;
    }

    mapping (address => mapping (uint => nftForSell)) public forSell;
    mapping (address => mapping (uint => nftForSell)) public forSellwithSingh;
    mapping (string => address) public tokenType;

    event sell(address nftContractAdd, address seller, uint tokenId, uint price);
    event buy(address nftContractAdd, address seller, address buyer,uint tokenId, uint price);

    function setPlatFormFee(uint fee) external onlyOwner {
        platFormFee = fee.mul(100).div(1000);
    }

    function setToken(string memory tokenName, address tokenAdd) external onlyOwner {
        tokenType[tokenName] = tokenAdd;
    }

    function getplatFormFee() external view returns (uint){
        return platFormFee;
    }

    function setFeecollector(address collector) external onlyOwner {
        feeCollector = collector;
    }

    // function setSinghNFTAdd(address NFT) external onlyOwner {
    //     singhNFT = NFT;
    // }

    function sellWithBNB(address nftContractAdd, uint tokenId, uint price) external {
        require(msg.sender == IERC721(nftContractAdd).ownerOf(tokenId), "Invalid Token Owner");
        forSell[nftContractAdd][tokenId].seller = msg.sender;
        forSell[nftContractAdd][tokenId].buyer = address(0);
        forSell[nftContractAdd][tokenId].price = price;
        forSell[nftContractAdd][tokenId].sold = false;

        emit sell(nftContractAdd, forSellwithSingh[nftContractAdd][tokenId].seller, tokenId, price);
    }

    function buyNFTbyBNB(address nftContractAdd, uint tokenId, uint price) external payable {
        require(forSell[nftContractAdd][tokenId].price == msg.value, "Invalid Price");
        require(forSell[nftContractAdd][tokenId].sold == false, "NFT Already Sold");
        
        forSell[nftContractAdd][tokenId].buyer = msg.sender;
        forSell[nftContractAdd][tokenId].sold = true;

        address creatorAdd = singhCoinNFT(nftContractAdd).getCreator(tokenId);
        uint royalty = singhCoinNFT(nftContractAdd).getRoyalty(tokenId);
        uint royaltyAmount = price.mul(royalty).div(100);
        uint fee = price.mul(platFormFee).div(100);
        uint amountToPay = price.sub(royaltyAmount).sub(fee);
        address ownerNFT = forSell[nftContractAdd][tokenId].seller;

        payable(creatorAdd).transfer(royaltyAmount);
        payable(feeCollector).transfer(fee);
        payable(ownerNFT).transfer(amountToPay);
        IERC721(nftContractAdd).transferFrom(forSell[nftContractAdd][tokenId].seller, msg.sender, tokenId);

        emit buy(nftContractAdd, forSellwithSingh[nftContractAdd][tokenId].seller, forSellwithSingh[nftContractAdd][tokenId].buyer, tokenId, price);
    }


    function changePrice(address nftContractAdd, uint tokenId, uint newPrice) external {
        require(msg.sender == IERC721(nftContractAdd).ownerOf(tokenId), "Invalid Token Owner");
        require(forSell[nftContractAdd][tokenId].sold == false, "NFT Already Sold");
        require(forSell[nftContractAdd][tokenId].seller == msg.sender);
        forSell[nftContractAdd][tokenId].price = newPrice;
    }

    function removeFormSell(address nftContractAdd, uint tokenId) external {
        require(msg.sender == IERC721(nftContractAdd).ownerOf(tokenId), "Invalid Token Owner");
        require(forSell[nftContractAdd][tokenId].sold == false, "NFT Already Sold");
        require(forSell[nftContractAdd][tokenId].seller == msg.sender);
        forSell[nftContractAdd][tokenId].seller = address(0);
        forSell[nftContractAdd][tokenId].buyer = address(0);
        forSell[nftContractAdd][tokenId].sold = false;
        forSell[nftContractAdd][tokenId].price = 0;
    }

    function sellWithSingh(address nftContractAdd, uint tokenId, uint price) external {
        require(msg.sender == IERC721(nftContractAdd).ownerOf(tokenId), "Invalid Token Owner");
        forSellwithSingh[nftContractAdd][tokenId].seller = msg.sender;
        forSellwithSingh[nftContractAdd][tokenId].buyer = address(0);
        forSellwithSingh[nftContractAdd][tokenId].price = price;
        forSellwithSingh[nftContractAdd][tokenId].sold = false;

        emit sell(nftContractAdd, forSellwithSingh[nftContractAdd][tokenId].seller, tokenId, price);
    }

    function buyNFT(string memory tokenName,address nftContractAdd, uint tokenId, uint price) external  {
        require(forSellwithSingh[nftContractAdd][tokenId].price == price, "Invalid Price");
        require(forSellwithSingh[nftContractAdd][tokenId].sold == false, "NFT Already Sold");

        forSellwithSingh[nftContractAdd][tokenId].buyer = msg.sender;
        forSellwithSingh[nftContractAdd][tokenId].sold = true;


        address creatorAdd = singhCoinNFT(nftContractAdd).getCreator(tokenId);
        uint royalty = singhCoinNFT(nftContractAdd).getRoyalty(tokenId);
        uint royaltyAmount = price.mul(royalty).div(100);
        uint fee = price.mul(platFormFee).div(100);
        uint amountToPay = price.sub(royaltyAmount).sub(fee);
        address NFTowner = forSellwithSingh[nftContractAdd][tokenId].seller;

        ERC20 token = ERC20 (tokenType[tokenName]);

        token.transferFrom(msg.sender, feeCollector, fee);
        token.transferFrom(msg.sender, creatorAdd, royaltyAmount);
        token.transferFrom(msg.sender, NFTowner, amountToPay);
        IERC721(nftContractAdd).safeTransferFrom(forSellwithSingh[nftContractAdd][tokenId].seller, msg.sender, tokenId);

        emit buy(nftContractAdd, forSellwithSingh[nftContractAdd][tokenId].seller, forSellwithSingh[nftContractAdd][tokenId].buyer, tokenId, price);
    }

    function changePriceForSingh(address nftContractAdd, uint tokenId, uint newPrice) external {
        require(msg.sender == IERC721(nftContractAdd).ownerOf(tokenId), "Invalid Token Owner");
        require(forSellwithSingh[nftContractAdd][tokenId].sold == false, "NFT Already Sold");
        require(forSellwithSingh[nftContractAdd][tokenId].seller == msg.sender);
        forSellwithSingh[nftContractAdd][tokenId].price = newPrice;
    }

    function removeFromSellbySingh(address nftContractAdd, uint tokenId) external {
        require(msg.sender == IERC721(nftContractAdd).ownerOf(tokenId), "Invalid Token Owner");
        require(forSell[nftContractAdd][tokenId].sold == false, "NFT Already Sold");
        require(forSell[nftContractAdd][tokenId].seller == msg.sender);
        forSellwithSingh[nftContractAdd][tokenId].seller = address(0);
        forSellwithSingh[nftContractAdd][tokenId].buyer = address(0);
        forSellwithSingh[nftContractAdd][tokenId].sold = false;
        forSellwithSingh[nftContractAdd][tokenId].price = 0;
    }

    function setForAuction(address nftContractAdd, uint tokenId, uint miniPrice) external {
        require(msg.sender == IERC721(nftContractAdd).ownerOf(tokenId), "Invalid Token Owner");
        forSellwithSingh[nftContractAdd][tokenId].seller = msg.sender;
        forSellwithSingh[nftContractAdd][tokenId].buyer = address(0);
        forSellwithSingh[nftContractAdd][tokenId].price = miniPrice;
        forSellwithSingh[nftContractAdd][tokenId].sold = false;

        emit sell(nftContractAdd, forSellwithSingh[nftContractAdd][tokenId].seller, tokenId, miniPrice);
    }

    function acceptBid(string memory tokenName, address nftContractAdd, uint tokenId, uint price, address bidderAdd) external {
        require(msg.sender == IERC721(nftContractAdd).ownerOf(tokenId), "Invalid Token Owner");
        require(forSellwithSingh[nftContractAdd][tokenId].sold == false, "your NFT Already Sold");
        require(forSellwithSingh[nftContractAdd][tokenId].seller == msg.sender, "Invalid Seller");
        require(forSellwithSingh[nftContractAdd][tokenId].price <= price, "Please Check Price");

        ERC20 token = ERC20(tokenType[tokenName]);

        forSellwithSingh[nftContractAdd][tokenId].buyer = bidderAdd;
        forSellwithSingh[nftContractAdd][tokenId].sold = true;

        address creatorAdd = singhCoinNFT(nftContractAdd).getCreator(tokenId);
        uint royalty = singhCoinNFT(nftContractAdd).getRoyalty(tokenId);
        uint royaltyAmount = price.mul(royalty).div(100);
        uint fee = price.mul(platFormFee).div(100);
        uint amountToPay = price.sub(royaltyAmount).sub(fee);

        token.transferFrom(bidderAdd, forSellwithSingh[nftContractAdd][tokenId].seller, amountToPay);
        token.transferFrom(bidderAdd, feeCollector, fee);
        token.transferFrom(bidderAdd, creatorAdd, royaltyAmount);
        IERC721(nftContractAdd).transferFrom(msg.sender, bidderAdd, tokenId);

        emit buy(nftContractAdd, forSellwithSingh[nftContractAdd][tokenId].seller, forSellwithSingh[nftContractAdd][tokenId].buyer, tokenId, price);
    }

}