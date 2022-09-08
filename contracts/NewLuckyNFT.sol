// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/ILuckyAll.sol";
import "./library/Random.sol";
import "./WhiteList.sol";
contract NewLuckyNFT is ERC721URIStorage, ERC721Enumerable, WhiteList{
    using Random for uint256;

   
    
    string public baseURI;
    string public endingPrefix;

    uint256 private nftCount;
    uint256 private mintedRare = 0;
    uint256 constant RARE_MAX = 10000;
    mapping(uint256 => uint256) private rarity; // norm = 2, rare = 1
    mapping(address => uint256[]) private mintedIdsOneTime;
    mapping(uint256 => uint256) public nftStartTime;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 private randomNum;
    uint256 private pointer;
    

    ITicket private ticket; 

    event Mint(address indexed minter, uint tokenId);

    constructor(address _ticket) ERC721("LuckyMetaNFT", "tLuckyNFT"){
        ticket = ITicket(_ticket);
        nftCount = 1;
    }
    
    function showRarity(uint256 _tokenId) public view returns (uint256) {
        return rarity[_tokenId];
    }

    function showNextIds() public view returns (uint256) {
        return nftCount;
    }

    function showMintedRare() public view returns (uint256) {
        return mintedRare;
    }

    function mintFromTicket(uint256 _ticketId) public operator(_ticketId) {
        uint256 _rand = random(20);
        ticket.transferFrom(msg.sender, DEAD, _ticketId);
        _safeMint(msg.sender, nftCount);
        if (_rand == 10 && mintedRare <= RARE_MAX ) {
            rarity[nftCount] = 1;
            mintedRare ++;
        } else {
            rarity[nftCount] = 2;
        }
        nftStartTime[nftCount] = block.timestamp;
        nftCount ++;
    }

    function showMintedIdsOneTime(address _owner) public view returns (uint256[] memory _mintedIds) {
        _mintedIds= mintedIdsOneTime[_owner];
    }

    function batchMintFromTicket(uint256[] memory _ticketIds) public {
        delete mintedIdsOneTime[msg.sender];
        for (uint256 i = 0; i < _ticketIds.length; i++) {
            mintedIdsOneTime[msg.sender].push(nftCount);
            mintFromTicket(_ticketIds[i]);
        }
    }

    function setBaseURI(string memory __baseURI) external onlyOwner {
            baseURI = __baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721,ERC721URIStorage) returns (string memory) {
         return string(abi.encodePacked(baseURI, '/', Strings.toString(tokenId), endingPrefix));
    }

    function safeMint(address _toAddress,uint256 tokenId) public whiteListed {
         rarity[tokenId] = 2;
         nftStartTime[tokenId] = block.timestamp;
         _safeMint(_toAddress, tokenId);
    }


    function _burn(uint256 tokenId) internal virtual override(ERC721,ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from,address to,uint256 tokenId) internal virtual override(ERC721Enumerable,ERC721) {
        super._beforeTokenTransfer(from,to,tokenId);
    }

   
    function giveNFT(address from,address to, uint256[] calldata _tokenIds) public virtual  {
        for(uint256 i = 0; i < _tokenIds.length; i++){
            uint256 tokenId=_tokenIds[i];
            require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
            _transfer(from, to, tokenId);
        }
    }

    function random(uint256 _range) internal returns (uint256) {
        uint256 time_base = uint256(uint64(block.timestamp));
        uint256 addr_base = uint256(uint64(uint160(msg.sender)));
        uint256 hash_base = uint256(uint64(uint256(blockhash(block.number - 1))));
        uint256 _seed = uint256(uint64(time_base * addr_base * hash_base));
        uint256[] memory _randomArray = _seed.genSeedsUint64(_range);
        randomNum = _randomArray[pointer % _range];
        pointer++;
        return randomNum;
    }

    modifier operator(uint256 _ticketId) {
        require(ticket.ownerOf(_ticketId) == msg.sender || isWhiteListed[msg.sender], "LuckyNft: caller is not operator.");
        _;
    }

    modifier whiteListed() {
        require(isWhiteListed[msg.sender], "ERC721: minter caller is not owner nor approved");
        _;
    }

    

}
