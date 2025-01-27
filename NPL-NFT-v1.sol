// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LPN is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address[] public whitelistAddresses;
    mapping(address => bool) public isWhitelist;
    uint256 public platformFee = 30000000000000000;
    uint256 public platformFeeForWhitelist = 10000000000000000;
    uint256 public maxNftCapforInitial = 5000;
    IERC20 tokenAddress = IERC20(0x2f7E923b9ad9435aC1C8B338dED8577338C24E93);

    constructor() ERC721("LPN", "LPN") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setPlatformFee(
        uint256 _platformFee,
        uint256 _platformFeeForWhitelist
    ) public onlyOwner {
        require(
            _platformFee != uint256(0) ||
                _platformFeeForWhitelist != uint256(0),
            "INVALID_AMOUNT_FEE"
        );
        platformFee = _platformFee;
        platformFeeForWhitelist = _platformFeeForWhitelist;
    }

    function setMaxNftCapforInitial(uint256 maxNumber) public onlyOwner {
        require(maxNumber != uint256(0), "INVALID_MAX_AMOUNT");
        maxNftCapforInitial = maxNumber;
    }

    function addWhiteList(address userAddress) public onlyOwner {
        require(userAddress != address(0), "INVALID_USER_ADDRESS");
        isWhitelist[userAddress] = true;
        whitelistAddresses.push(userAddress);
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function initialBuy(uint256 initialPrice, uint256 tokenId) public {
        require(initialPrice >= platformFee, "INVALID_FEE");
        tokenAddress.transferFrom(_msgSender(), address(this), initialPrice);
        require(tokenAddress.transfer(owner(), initialPrice));
        require(tokenId <= maxNftCapforInitial, "REACHED_TO_MAX_CAP");
        transferFrom(ownerOf(tokenId), address(this), tokenId);
        transferFrom(address(this), _msgSender(), tokenId);
    }

    function intialMintForWhiteList(uint256 mintFee, uint256 tokenId) public {
        require(isWhitelist[_msgSender()], "ONLY_WHITELIST_USER");
        require(mintFee >= platformFeeForWhitelist, "INVALID_FEE");
        tokenAddress.transferFrom(_msgSender(), address(this), mintFee);
        tokenAddress.transfer(owner(), mintFee);
        require(tokenId <= maxNftCapforInitial, "REACHED_TO_MAX_CAP");
        transferFrom(ownerOf(tokenId), address(this), tokenId);
        transferFrom(address(this), _msgSender(), tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
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
