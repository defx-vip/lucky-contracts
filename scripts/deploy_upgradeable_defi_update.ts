import {ethers, upgrades } from 'hardhat'
const NewLucky_ADDRESS = "0xB52EDb80B726a09447EEff2cfCDbCE7d7466442c"
async function main() {
    const NewLuckyFi = await ethers.getContractFactory('NewLuckyFinanceUpgradeable')
    console.log("Update NewLuckyFinanceUpgradeable.....")
    const box = await upgrades.upgradeProxy(NewLucky_ADDRESS, NewLuckyFi);
    console.log("Box upgraded");
}
main()