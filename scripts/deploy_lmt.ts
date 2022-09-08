import {ethers, upgrades } from 'hardhat'

async function main() {
    const LuckyMetaToken = await ethers.getContractFactory('LuckyMetaToken')
    console.log("Deploying LuckyMetaToken.....")
    const luckyMetaToken = await LuckyMetaToken.deploy();
    console.log('LuckyMetaToken deployed to:', luckyMetaToken.address)
}
main()