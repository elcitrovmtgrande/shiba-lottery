async function main() {
  const ShibaLottery = await ethers.getContractFactory("ShibaLottery");

  const shiba_lottery = await ShibaLottery.deploy(100000, 10, 20, '0x4f95c426C2Ee675269031A48dc52CBBAc6819Fc0');
  console.log("Contract deployed to address:", shiba_lottery.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });