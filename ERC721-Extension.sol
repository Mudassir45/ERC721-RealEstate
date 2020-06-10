pragma solidity ^0.6.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721Burnable.sol";

contract RealEstate is ERC721, ERC721Burnable {
    
    address public Owner;
    
    uint private tokenId;
    
    mapping (uint256 => address) tokenOwner;
    
    mapping (uint256 => uint256) startingValue;
    
    mapping (uint256 => bool) listedTokens;
    
    mapping (uint256 => uint256) highestBid;
    
    mapping (uint256 => address) highestBidder;
    
    mapping (uint256 => string) tokenIds;
    
    constructor() ERC721("RealEstateToken", "RET") public {
        Owner = msg.sender;
    } 
 
    function registerProperty(address payable _to, uint256 _startingValue, string memory  _tokenURI) public returns (uint256) {
        tokenId++;
        uint newTokenId = tokenId;
        _mint(_to, newTokenId);
        startingValue[newTokenId] = _startingValue;
        tokenOwner[newTokenId] = _to;
        tokenIds[newTokenId] = _tokenURI;
        highestBid[newTokenId] = _startingValue;
        return newTokenId;
    }
        
    function listingOfTokens(uint256 _tokenId) public returns(bool) {
        require(tokenOwner[_tokenId] == msg.sender, "Sorry! You are not the Owner of this Token");
        listedTokens[_tokenId] = true;
        return true;
    }
    
    function PlaceBid(uint256 _tokenId) public payable {
        require(listedTokens[_tokenId] == true, "Sorry! This Token is not for Sale");
        require(highestBid[_tokenId] < msg.value, "Sorry! Your Bid is lower then current Bid");
        
        if(highestBid[_tokenId] > startingValue[_tokenId]) {
            payable(highestBidder[_tokenId]).transfer(highestBid[_tokenId]);
            highestBidder[_tokenId] = msg.sender;
            highestBid[_tokenId] = msg.value;
        }
        
        else {
            highestBidder[_tokenId] = msg.sender;
            highestBid[_tokenId] = msg.value;
        }
    }
        function viewListedTokens(uint256 _tokenId) public view returns(bool) {
           require(listedTokens[_tokenId] == true, "Property not listed for Sale");
           return true;
        }
        
        function acceptBid(uint256 _tokenId) public payable {
            require(tokenOwner[_tokenId] == msg.sender, "Sorry! You are not the owner of this Token");
            payable(msg.sender).transfer(highestBid[_tokenId]);
            safeTransferFrom(msg.sender, highestBidder[_tokenId], _tokenId);
            tokenOwner[_tokenId] = highestBidder[_tokenId];
            delete highestBidder[_tokenId];
            delete highestBid[_tokenId];
            listedTokens[_tokenId] = false;
        }
        
        function rejectBid(uint256 _tokenId) public {
            payable(highestBidder[_tokenId]).transfer(highestBid[_tokenId]);
            delete highestBidder[_tokenId];
            delete highestBid[_tokenId];
            highestBid[_tokenId] = startingValue[_tokenId];
        }
        
        fallback() external payable {
            
        }
}