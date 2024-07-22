// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

interface IMoMoToken {
    function generateMomo(address to, uint256 amount, bytes32 seed) external;
}

contract MoMoMinter {
    uint256 public constant MAX_BOXES_PER_TX = 500;
    uint256 public constant MAX_BOXES_UNLOCKING = 10;
    address public momoTokenAddress;

    struct Box {
        bool isLocked;
        uint256 amount;
    }

    mapping(address => Box[]) public userBoxes;

    event BoxAdded(address indexed to, uint256 amount);
    event BoxUnlocked(address indexed to, uint256 amount);

    function setMoMoTokenAddress(address momoTokenAddress_) external {
        momoTokenAddress = momoTokenAddress_;
    }

    function addBoxs(address to_, uint256 amount_) external {
        require(
            amount_ <= MAX_BOXES_PER_TX,
            "Exceeds maximum boxes per transaction"
        );

        for (uint256 i = 0; i < amount_; i++) {
            userBoxes[to_].push(Box(true, 1)); // Supondo que cada caixa tenha uma quantidade de 1 para simplicidade
        }

        emit BoxAdded(to_, amount_);
    }

    function unlockBoxes(address to_, uint256[] memory boxIndices) external {
        require(
            boxIndices.length <= MAX_BOXES_UNLOCKING,
            "Exceeds maximum boxes that can be unlocked per transaction"
        );

        bytes32 blockHash = blockhash(block.number - 1); // Usando o hash do bloco anterior

        for (uint256 i = 0; i < boxIndices.length; i++) {
            uint256 boxIndex = boxIndices[i];
            require(
                boxIndex < userBoxes[to_].length,
                "Box index out of bounds"
            );
            Box storage box = userBoxes[to_][boxIndex];
            require(box.isLocked, "Box is already unlocked");

            // Generate a random seed based on the block hash and user's BSC public address
            bytes32 seed = keccak256(abi.encodePacked(blockHash, to_));

            // Recalculate the block hash each time a box is unlocked
            blockHash = keccak256(abi.encodePacked(blockHash));

            box.isLocked = false;
            IMoMoToken(momoTokenAddress).generateMomo(to_, box.amount, seed);

            emit BoxUnlocked(to_, box.amount);
        }
    }

    function getLockedBoxes(
        address to_
    ) external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < userBoxes[to_].length; i++) {
            if (userBoxes[to_][i].isLocked) {
                count++;
            }
        }

        uint256[] memory lockedBoxes = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < userBoxes[to_].length; i++) {
            if (userBoxes[to_][i].isLocked) {
                lockedBoxes[index] = i;
                index++;
            }
        }

        return lockedBoxes;
    }

    function getUnlockedBoxes(
        address to_
    ) external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < userBoxes[to_].length; i++) {
            if (!userBoxes[to_][i].isLocked) {
                count++;
            }
        }

        uint256[] memory unlockedBoxes = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < userBoxes[to_].length; i++) {
            if (!userBoxes[to_][i].isLocked) {
                unlockedBoxes[index] = i;
                index++;
            }
        }

        return unlockedBoxes;
    }

    function getTotalBoxes(address to_) external view returns (uint256) {
        return userBoxes[to_].length;
    }
}
