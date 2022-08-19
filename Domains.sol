// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "../libraries/StringUtils.sol";
// We import another help function
import { Base64 } from "../libraries/Base64.sol";

import "hardhat/console.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract Domains is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public dotSomething;

    // We'll be storing our NFT images on chain as SVGs
    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" viewBox="0 0 95.856 100" version="1.0"><path d="M47.88 12.214c3.346 0 6.101-2.73 6.101-6.089C53.981 2.73 51.226 0 47.88 0c-3.371 0-6.102 2.73-6.102 6.125.001 3.359 2.731 6.089 6.102 6.089m9.749 1.97H38.033c-4.324 0-7.805 3.54-7.805 7.938V36.74c0 3.637 4.809 3.637 4.809 0V22.629h4.99v17.784c2.549.616 5.158 1.075 7.913 1.075 2.73 0 5.315-.459 7.853-1.051V22.629h4.954V36.74c0 3.661 4.809 3.661 4.809 0V22.206c-.001-4.023-3.166-8.022-7.927-8.022m13.363 31.932a40.858 40.858 0 0 1-23.148 7.152c-8.529 0-16.432-2.609-23.027-7.031l-5.171 7.684c8.046 5.461 17.76 8.626 28.198 8.626 10.512 0 20.273-3.201 28.344-8.698l-5.196-7.733z"/><path d="M80.875 61.966c-9.399 6.404-20.756 10.125-32.982 10.125-12.179 0-23.487-3.686-32.862-10.016l-5.22 7.527c10.85 7.369 23.971 11.67 38.082 11.67 14.135 0 27.256-4.325 38.154-11.694l-5.172-7.612z"/><path d="M90.685 77.685c-12.227 8.3-26.942 13.133-42.817 13.133-15.851 0-30.567-4.833-42.769-13.097L0 85.357C13.64 94.599 30.132 100 47.868 100a85.17 85.17 0 0 0 47.988-14.739l-5.171-7.576z"/>';
    string svgPartTwo = '</text></svg>';

    mapping (string => address) public domains;
    mapping (string => string) public records;

    constructor(string memory _dotSomething) payable ERC721('Registro de Nomes e Enderecos', 'RNE') {
        dotSomething = _dotSomething;
        console.log('%s name service deployes', _dotSomething);
    }

    function price(string memory name) public pure returns(uint) {
        uint length = StringUtils.strlen(name);
        require(length > 0);
        if (length <= 3) {
            return 5 * 10 ** 15;
        } else if (length <= 4) {
            return 4 * 10 ** 14;
        } else if (length <= 5) {
            return 3 * 10 ** 13;
        }  else if (length <= 6) {
            return 2 * 10 ** 12;
        } else {
            return 1 * 10 ** 11;
        }      
    }
    
    function register(string calldata name) public payable {
        require(domains[name] == address(0));

        uint256 _price = price(name);
        require(msg.value >= _price, "Not enough Matic paid");
        
        // Combine the name passed into the function  with the TLD
        string memory _name = string(abi.encodePacked(name, ".", dotSomething));
        // Create the SVG (image) for the NFT with the name
        string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);

        console.log("Registering %s.%s on the contract with tokenID %d", name, dotSomething, newRecordId);

        // Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
        string memory json = Base64.encode(
        abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "Um dominio .artesanato", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '","length":"',
            strLen,
            '"}'
        )
        );

        string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------------------------------------------");
        console.log("Final tokenURI", finalTokenUri);
        console.log("--------------------------------------------------------\n");

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        domains[name] = msg.sender;

        _tokenIds.increment();
    }

    function getAddress(string calldata name) public view returns (address) {
        return domains[name];
    }

    function setRecord(string calldata name, string calldata record) public {
        require(domains[name] == msg.sender);
        records[name] = record;
    }

    function getRecord(string calldata name) public view returns(string memory) {
        return records[name];
    }
}
