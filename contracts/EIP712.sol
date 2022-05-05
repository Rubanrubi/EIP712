// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract TestEIP714 is
    Initializable,
    UUPSUpgradeable,
    EIP712Upgradeable,
    OwnableUpgradeable
{
    using ECDSAUpgradeable for bytes32;

    bytes32 constant TRANSFER_TYPEHASH =
        keccak256(
            "Transfer(address seller,address tokenAddress,uint256 amount,address buyer)"
        );

    IERC20Upgradeable public token;

    struct Transfer {
        address seller;
        address tokenAddress;
        uint256 amount;
        address buyer;
    }

    function initialize() public initializer {
        __Ownable_init_unchained();
        __EIP712_init_unchained("Order", "1");
        token = IERC20Upgradeable(0x9fdfE0c1e02BA989ef80C86C4e3393B92314AC87);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function getTokens(
        Transfer memory data,
        address buyer,
        bytes calldata signature
    ) external {
        // verify signature
        bytes32 structHash = genBidOrderHash(data);
        bytes32 hashTypedData = _hashTypedDataV4(structHash);
        address signer = verifySignature(hashTypedData, signature);
        require(
            signer == buyer,
            "Exchange: Buy order is not signed by the buyer"
        );
        token.transferFrom(buyer, msg.sender, 10000000000000000000);
        // emit Transfer(buyer, msg.sender, 10000000000000000000);
    }

    function genBidOrderHash(Transfer memory data)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    TRANSFER_TYPEHASH,
                    data.seller,
                    data.tokenAddress,
                    data.amount,
                    data.buyer
                )
            );
    }

    function verifySignature(bytes32 hash, bytes calldata signature)
        internal
        pure
        returns (address)
    {
        return ECDSAUpgradeable.recover(hash, signature);
    }
}
