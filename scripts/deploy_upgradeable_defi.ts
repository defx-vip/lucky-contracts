import {ethers, upgrades } from 'hardhat'
const lmtAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
const nftAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
async function main() {
    const NewLuckyFi = await ethers.getContractFactory('NewLuckyFinanceUpgradeable')
    console.log("Deploying NewLuckyFinanceUpgradeable.....")
    const newLuckyFi = await upgrades.deployProxy(NewLuckyFi, [lmtAddress, nftAddress], {initializer: 'initialize'})
    console.log('NewLuckyFi deployed to:', newLuckyFi.address)
}
main()