const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Chihiro", "Kaonashi", "Haku"], // Names
    [
      "https://i.imgur.com/etfleb0.jpeg", // Images
      "https://i.imgur.com/OyrlIuT.jpeg",
      "https://i.imgur.com/1u8ly30.jpeg",
    ],
    [100, 200, 300], // HP values
    [25, 50, 100] // Attack damage values
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  // Gets the value of the NFT's URI.
  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI:", returnedTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
