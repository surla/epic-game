// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";
import "./libraries/Base64.sol";

// Contract inherits from ERC721. The standard NFT contract.
contract MyEpicGame is ERC721 {
	struct CharacterAttributes {
		uint characterIndex;
		string name;
		string imageURI;
		uint hp;
		uint maxHp;
		uint attackDamage;
	}

	// The tokenId is the NFTs unique identifier.
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	CharacterAttributes[] defaultCharacters;

	mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

	mapping(address => uint256) public nftHolders;

	constructor(
		string[] memory characterNames,
		string[] memory characterImageURIs,
		uint[] memory characterHp,
		uint[] memory characterAttackDmg
	) ERC721("Heroes", "HERO")
	{
		for(uint i = 0; i < characterNames.length; i += 1) {
			defaultCharacters.push(CharacterAttributes({
				characterIndex: i,
				name: characterNames[i],
				imageURI: characterImageURIs[i],
				hp: characterHp[i],
				maxHp: characterHp[i],
				attackDamage: characterAttackDmg[i]
			}));

			CharacterAttributes memory c = defaultCharacters[i];
			console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
		}
			// Increment tokenIds so that first NFT has an ID of 1.
			_tokenIds.increment();
	}

	// Function to mint NFT based on the characterId
	function mintCharacterNFT(uint _characterIndex) external {
		uint256 newItemId = _tokenIds.current();

		// Assigns the tokenId to the caller's wallet address.
		_safeMint(msg.sender, newItemId);

		// Map the tokenId => their character attributes.
		nftHolderAttributes[newItemId] = CharacterAttributes({
			characterIndex: _characterIndex,
			name: defaultCharacters[_characterIndex].name,
			imageURI: defaultCharacters[_characterIndex].imageURI,
			hp: defaultCharacters[_characterIndex].hp,
			maxHp: defaultCharacters[_characterIndex].hp,
			attackDamage: defaultCharacters[_characterIndex].attackDamage
		});

		console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

		// See who owns what NFT.
		nftHolders[msg.sender] = newItemId;

		// Increment the tokenId for the next person that uses it.
		_tokenIds.increment();
	}

	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

		string memory strHp = Strings.toString(charAttributes.hp);
		string memory strMaxHp = Strings.toString(charAttributes.maxHp);
		string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

		string memory json = Base64.encode(
    bytes(
      string(
        abi.encodePacked(
          '{"name": "',
          charAttributes.name,
          ' -- NFT #: ',
          Strings.toString(_tokenId),
          '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
          charAttributes.imageURI,
          '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
          strAttackDamage,'} ]}'
        )
      )
    ));

  	string memory output = string(
    	abi.encodePacked("data:application/json;base64,", json)
  	);
  
  	return output;
	}
}


