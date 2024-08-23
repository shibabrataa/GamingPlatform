// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameToken {
    string public name = "GameToken";
    string public symbol = "GTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    address public owner;

    constructor() {
        owner = msg.sender;
        _mint(owner, 1000000 * 10 ** uint256(decimals));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function _mint(address account, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }
}

contract GameNFT {
    string public name = "GameNFT";
    string public symbol = "GNFT";
    
    struct NFT {
        address owner;
        uint256 id;
    }

    uint256 private _nextTokenId = 1;
    mapping(uint256 => NFT) public nftInfo;
    mapping(address => uint256[]) public ownedNFTs;
    mapping(uint256 => address) private _tokenOwners;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function mint(address to) external onlyOwner {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        nftInfo[tokenId] = NFT(to, tokenId);
        ownedNFTs[to].push(tokenId);
        _tokenOwners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function totalSupply() external view returns (uint256) {
        return _nextTokenId - 1;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return _tokenOwners[tokenId];
    }

    function transfer(address from, address to, uint256 tokenId) external {
        require(_tokenOwners[tokenId] == from, "Not the owner");
        require(from != to, "Cannot transfer to yourself");

        // Update ownership
        _tokenOwners[tokenId] = to;
        nftInfo[tokenId].owner = to;

        // Remove tokenId from sender's list
        uint256 indexToRemove;
        for (uint256 i = 0; i < ownedNFTs[from].length; i++) {
            if (ownedNFTs[from][i] == tokenId) {
                indexToRemove = i;
                break;
            }
        }
        ownedNFTs[from][indexToRemove] = ownedNFTs[from][ownedNFTs[from].length - 1];
        ownedNFTs[from].pop();

        // Add tokenId to receiver's list
        ownedNFTs[to].push(tokenId);

        emit Transfer(from, to, tokenId);
    }
}

contract GamingPlatform {
    GameToken public gameToken;
    GameNFT public gameNFT;

    event RewardClaimed(address indexed player, uint256 tokenAmount, uint256 nftId);

    constructor(address _gameToken, address _gameNFT) {
        gameToken = GameToken(_gameToken);
        gameNFT = GameNFT(_gameNFT);
    }

    function playGame() external {
        // Simulate gameplay: Reward 100 tokens and mint 1 NFT
        uint256 rewardAmount = 100;
        uint256 nftId = _mintNFT(msg.sender);

        gameToken.mint(msg.sender, rewardAmount);

        emit RewardClaimed(msg.sender, rewardAmount, nftId);
    }

    function _mintNFT(address to) private returns (uint256) {
        uint256 tokenId = gameNFT.totalSupply() + 1;
        gameNFT.mint(to);
        return tokenId;
    }
}

