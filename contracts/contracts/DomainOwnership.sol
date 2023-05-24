// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DomainOwnership is ERC721 {
    struct Bid{
        address payable bidder;
        uint256 amount;
    }

    struct Auction {
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
    }

    IERC20 public token;
    mapping(string => Auction) public auctions;
    uint256 public nextTokenId = 1;
    uint256 public ownershipTime = 31_536_000;
    uint256 public auctionDuration = 604_800;
    uint256 public minimumProlongation = 86400;

    string public constant contractSymbol = "DDNSN";
    string public constant contractName = "DDNS Name";

    address payable owner;
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor(address _token) ERC721(contractName, contractSymbol) {
        owner = payable(msg.sender);
        token = IERC20(_token);
    }

    function startAuction(string memory _name) public onlyOwner {
        if (auctions[_name].tokenId != 0 && block.timestamp < auctions[_name].endTime){
            revert("Auction already exists");
        }
        uint256 tokenId = nextTokenId++;
        _mint(address(this), tokenId);
        auctions[_name] = Auction(tokenId, block.timestamp, block.timestamp+auctionDuration, address(0), 0);
    }

    function bid(string memory _name, uint256 _amount) public {
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance for bid");
        Auction storage auction = auctions[_name];
        require(block.timestamp < auction.endTime, "Auction has already ended");
        require(_amount > auction.highestBid, "Bid amount must be higher than current bid");
        if (auction.highestBidder != address(0)) {
            // Refund the previous highest bidder
            token.transfer(auction.highestBidder, auction.highestBid);
        }
        token.transferFrom(msg.sender, address(this), _amount);
        auction.highestBidder = msg.sender;
        auction.highestBid = _amount;
    }

    function endAuction(uint256 _tokenId, string memory _name) public onlyOwner {
        Auction storage auction = auctions[_name];
        require(block.timestamp > auction.endTime, "Auction has not yet ended");
        _transfer(address(this), auction.highestBidder, _tokenId);
    }

    struct Record {
        string info;
    }

    mapping(string => Record) private records;

    function setRecord(string memory name, string memory info) public {
        require(block.timestamp > auctions[name].endTime, "Auction still in progress");
        uint256 id = auctions[name].tokenId;
        require(_isApprovedOrOwner(_msgSender(), id), "Caller is not the owner or approved");

        Record storage data = records[name];
        data.info = info;
    }

    function getRecord(string memory name) public view returns (string memory) {
        return records[name].info;
    }
}