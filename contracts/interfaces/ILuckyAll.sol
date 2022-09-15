// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITicket {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external returns (address);
}

interface INft {
    function balanceOf(address owner) external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function safeMint(address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function showRarity(uint256 _tokenId) external view returns (uint256);
   
}

interface ILmt {
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function transfer(address to, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
}

interface ILuckFi {
    function nftInfo(uint256 _tokenId) external view returns (bool _isLink, uint256 _level, uint256 _rarity, bool _isDepos);
}