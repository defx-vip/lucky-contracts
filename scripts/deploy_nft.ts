import {ethers, upgrades } from 'hardhat'
const lmtAddress = "0xB8bDB98AF8C987336B9476Fd8a98BdF190b6f10E"
async function main() {
    const NewLuckyNFT = await ethers.getContractFactory('NewLuckyNFT')
    console.log("Deploying NFT.....")
    const newLuckyNFT = await NewLuckyNFT.deploy(lmtAddress);
    console.log('NewLuckyNFT deployed to:', newLuckyNFT.address)
    //0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
}
main()