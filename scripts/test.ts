import {ethers, upgrades } from 'hardhat'
import {LuckyMetaToken} from '../typechain/LuckyMetaToken'
async function main() {
    const LuckyMetaToken = await ethers.getContractFactory('NewLuckyFinanceUpgradeable')
    const lmt = LuckyMetaToken.attach("0xB52EDb80B726a09447EEff2cfCDbCE7d7466442c") as LuckyMetaToken
    console.log(await lmt.users("0x18025093f8ad587bfD372305902142c594c7A15D"))
}

main()