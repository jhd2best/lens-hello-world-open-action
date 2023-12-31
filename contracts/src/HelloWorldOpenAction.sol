// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {HubRestricted} from 'lens/HubRestricted.sol';
import {Types} from 'lens/Types.sol';
import {IPublicationActionModule} from 'lens/IPublicationActionModule.sol';
import {LensModuleMetadata} from 'lens/LensModuleMetadata.sol';
import {IIPAssetRegistry} from './IIPAssetRegistry.sol';

contract HelloWorldOpenAction is HubRestricted, IPublicationActionModule, LensModuleMetadata {
    mapping(uint256 profileId => mapping(uint256 pubId => string initMessage)) internal _initMessages;
    IIPAssetRegistry internal _iPAssetRegistry;
    
    constructor(address lensHubProxyContract, address storyContract, address moduleOwner) HubRestricted(lensHubProxyContract) LensModuleMetadata(moduleOwner) {
        _iPAssetRegistry = IIPAssetRegistry(storyContract);
    }

    function supportsInterface(bytes4 interfaceID) public pure override returns (bool) {
        return interfaceID == type(IPublicationActionModule).interfaceId || super.supportsInterface(interfaceID);
    }

    function initializePublicationAction(
        uint256 profileId,
        uint256 pubId,
        address /* transactionExecutor */,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        string memory initMessage = abi.decode(data, (string));

        _initMessages[profileId][pubId] = initMessage;

        return data;
    }

    function processPublicationAction(
        Types.ProcessActionParams calldata params
    ) external override onlyHub returns (bytes memory) {
        string memory initMessage = _initMessages[params.publicationActedProfileId][params.publicationActedId];
        (string memory actionMessage) = abi.decode(params.actionModuleData, (string));

        bytes memory combinedMessage = abi.encodePacked(initMessage, " ", actionMessage);
        
        // register IP asset
        (uint256 globalId, uint256 localId) = _iPAssetRegistry.registerIPAsset(
            address(0x59d0f50a48F96Aa569a7b1db9Fe979e1fBC52020),
            IIPAssetRegistry.RegisterIPAssetParams(
                // todo
                address(this),
                0,
                string(combinedMessage),
                0x0000000000000000000000000000000000000000000000000000000000000000,
                "https://hey.xyz/posts/0x01d7db-0x025a"
            ),
            0,
            new bytes[](0),
            new bytes[](0)
        );

        // transfer IP asset to user
        _iPAssetRegistry.transferIPAsset(
            address(0x59d0f50a48F96Aa569a7b1db9Fe979e1fBC52020),
            address(this),
            params.transactionExecutor,
            globalId,
            new bytes[](0),
            new bytes[](0)
        );
        
        return combinedMessage;
    }
}