import {ethers, upgrades } from 'hardhat'
import {LuckyMetaToken} from '../typechain/LuckyMetaToken'
async function main() {
    const LuckyMetaToken = await ethers.getContractFactory('LuckyMetaToken')
    const lmt = LuckyMetaToken.attach("0x5FbDB2315678afecb367f032d93F642f64180aa3") as LuckyMetaToken
    console.log(await lmt.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"))
}

main()