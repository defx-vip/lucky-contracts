import {ethers, upgrades } from 'hardhat'
const lmtAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
async function main() {
    const NewLuckyNFT = await ethers.getContractFactory('NewLuckyNFT')
    console.log("Deploying NFT.....")
    const newLuckyNFT = await NewLuckyNFT.deploy(lmtAddress);
    console.log('NewLuckyNFT deployed to:', newLuckyNFT.address)
    //0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
}
main()