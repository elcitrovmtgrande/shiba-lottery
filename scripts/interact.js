require('dotenv').config();

const {
  API_KEY,
  PRIVATE_KEY,
  SHIBA_LOTTERY_CONTRACT_ADDRESS,
  SHIBA_LOTTERY_2,
} = process.env;

const {
  ethers
} = require("hardhat");
const contract = require("../artifacts/contracts/ShibaLottery.sol/ShibaLottery.json");

// console.log(JSON.stringify(contract.abi));

const provider = new ethers.providers.AlchemyProvider(network = "goerli", API_KEY);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);
const shibaLotteryContract = new ethers.Contract(SHIBA_LOTTERY_CONTRACT_ADDRESS, contract.abi, signer);

async function main() {
  // Afficher le cash prize actuel
  const currentCashPrize = await shibaLotteryContract.getCashPrize();
  console.log("The current cashprize is: ", currentCashPrize);


  // const tx = await shibaLotteryContract.buyTicket();
  // await tx.wait();
  
  // console.log("Updating the message...");
  // const tx = await greetingMessagesContract.update("Hola y bienvenido");
  // await tx.wait();

  // const newMessage = await greetingMessagesContract.message();
  // console.log("The new message is: ", newMessage);
}
main();