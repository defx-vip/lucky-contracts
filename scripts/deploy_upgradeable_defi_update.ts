import {ethers, upgrades } from 'hardhat'
const lmtAddress = "0xB8bDB98AF8C987336B9476Fd8a98BdF190b6f10E"
const nftAddress = "0x4Ab310524bA99b579c998C624A43eE0FD2DF800f"
const NewLucky_ADDRESS = "0xb4381D6cB960d452127C8ed2eC85Fe351b3bdc68"
async function main() {
    const NewLuckyFi = await ethers.getContractFactory('NewLuckyFinanceUpgradeable')
    console.log("Update NewLuckyFinanceUpgradeable.....")
    const box = await upgrades.upgradeProxy(NewLucky_ADDRESS, NewLuckyFi);
    console.log("Box upgraded");
}
main()