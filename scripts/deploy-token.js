async function main() {
  const ShibLotToken = await ethers.getContractFactory("ShibLotToken");

  const shib_lot_token = await ShibLotToken.deploy();
  console.log("Contract deployed to address:", shib_lot_token.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });