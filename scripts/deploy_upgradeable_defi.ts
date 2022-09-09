import {ethers, upgrades } from 'hardhat'
const lmtAddress = "0xB8bDB98AF8C987336B9476Fd8a98BdF190b6f10E"
const nftAddress = "0x4Ab310524bA99b579c998C624A43eE0FD2DF800f"
async function main() {
    const NewLuckyFi = await ethers.getContractFactory('NewLuckyFinanceUpgradeable')
    console.log("Deploying NewLuckyFinanceUpgradeable.....")
    const newLuckyFi = await upgrades.deployProxy(NewLuckyFi, [lmtAddress, nftAddress], {initializer: 'initialize'})
    console.log('NewLuckyFi deployed to:', newLuckyFi.address)
}
main()