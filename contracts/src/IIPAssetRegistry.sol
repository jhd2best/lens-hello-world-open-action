// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Global IP Asset Registry Interface
interface IIPAssetRegistry {
    struct RegisterIPAssetParams {
        address owner;
        uint8 ipOrgAssetType;
        string name;
        bytes32 hash;
        string mediaUrl;
    }

    /// @notice Emits when a new IP asset is registered.
    /// @param ipAssetId_ The global IP asset identifier.
    /// @param name_ The assigned name for the IP asset.
    /// @param ipOrg_ The registering governing body for the IP asset.
    /// @param registrant_ The initial individual registrant of the IP asset.
    /// @param hash_ The content hash associated with the IP asset.
    event Registered(
        uint256 ipAssetId_,
        string name_,
        address indexed ipOrg_,
        address indexed registrant_,
        bytes32 hash_
    );

    function registerIPAsset(
        address ipOrg_,
        RegisterIPAssetParams calldata params_,
        uint256 licenseId_,
        bytes[] calldata preHooksData_,
        bytes[] calldata postHooksData_
    ) external returns (uint256, uint256);

    function transferIPAsset(
        address ipOrg_,
        address from_,
        address to_,
        uint256 ipAssetId_,
        bytes[] calldata preHooksData_,
        bytes[] calldata postHooksData_
    ) external;
}