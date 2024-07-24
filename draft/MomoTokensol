// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract MoMoToken is ERC721, ERC1155, Ownable {
    using SafeMath for uint256;

    enum Quality {
        Common,
        Uncommon,
        Unique,
        Rare,
        Epic,
        Legendary
    }

    struct MoMo {
        Quality quality;
        uint256 hashPower;
        string name;
        string message;
        bool canEditName;
        bool canAddMessage;
        string assetClass;
    }

    mapping(uint256 => MoMo) public momos;
    uint256 public nextTokenId;

    event MoMoCreated(
        uint256 tokenId,
        Quality quality,
        uint256 hashPower,
        string assetClass
    );

    constructor() public ERC721("MoMoToken", "MOMO") ERC1155("") {}

    function _generateRandomHashPower(
        Quality quality,
        bytes32 seed
    ) internal pure returns (uint256) {
        uint256 randomHashPower = uint256(seed);
        if (quality == Quality.Common) return 1;
        if (quality == Quality.Uncommon) return 2;
        if (quality == Quality.Unique) return 3;
        if (quality == Quality.Rare) return (randomHashPower % 31) + 10;
        if (quality == Quality.Epic) return (randomHashPower % 71) + 50;
        if (quality == Quality.Legendary) return (randomHashPower % 81) + 180;
    }

    function _determineQuality(bytes32 seed) internal pure returns (Quality) {
        uint256 randomValue = uint256(seed) % 10000;
        if (randomValue < 5000) return Quality.Common; // 50%
        if (randomValue < 8500) return Quality.Uncommon; // 35%
        if (randomValue < 9700) return Quality.Unique; // 12%
        if (randomValue < 9950) return Quality.Rare; // 2.5%
        if (randomValue < 10000) return Quality.Epic; // 0.5%
        return Quality.Legendary; // Extremamente raro
    }

    function _determineAssetClass(
        Quality quality
    ) internal pure returns (string memory) {
        if (
            quality == Quality.Common ||
            quality == Quality.Uncommon ||
            quality == Quality.Unique
        ) {
            return "BRC1155";
        } else {
            return "BRC721";
        }
    }

    function generateMoMo(
        address to,
        uint256 amount,
        bytes32 seed
    ) external onlyOwner {
        uint256 tokenId = nextTokenId++;
        Quality quality = _determineQuality(seed);
        uint256 hashPower = _generateRandomHashPower(quality, seed);
        bool canEditName = (quality == Quality.Rare && hashPower >= 30) ||
            quality >= Quality.Epic;
        bool canAddMessage = (quality == Quality.Epic && hashPower >= 80) ||
            quality == Quality.Legendary;
        string memory assetClass = _determineAssetClass(quality);

        momos[tokenId] = MoMo({
            quality: quality,
            hashPower: hashPower,
            name: "",
            message: "",
            canEditName: canEditName,
            canAddMessage: canAddMessage,
            assetClass: assetClass
        });

        if (keccak256(abi.encodePacked(assetClass)) == keccak256("BRC1155")) {
            // Implement the logic for minting ERC1155 token
            _mint(to, tokenId, amount, ""); // Mint ERC1155 token
        } else {
            _mint(to, tokenId); // Mint ERC721 token
        }

        emit MoMoCreated(tokenId, quality, hashPower, assetClass);
    }

    function setMomoName(uint256 tokenId, string memory name) external payable {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        MoMo storage momo = momos[tokenId];
        require(momo.canEditName, "Cannot edit name");
        momo.name = name;
    }

    function addMomoStory(
        uint256 tokenId,
        string memory story
    ) external payable {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        MoMo storage momo = momos[tokenId];
        require(momo.canAddMessage, "Cannot add message");
        momo.message = story;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721) {
        super.transferFrom(from, to, tokenId);
    }

    function getMomoSimpleByTokenId(
        uint256 tokenId
    ) external view returns (Quality, uint256) {
        MoMo storage momo = momos[tokenId];
        return (momo.quality, momo.hashPower);
    }

    function levelUp(
        uint256 tokenId,
        uint256[] memory protosV1V2V3,
        uint256[] memory amountsV1V2V3,
        uint256[] memory tokensV4V5
    ) external {
        // Implement level-up logic here
    }
}
