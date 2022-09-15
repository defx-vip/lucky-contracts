import {ethers, upgrades } from 'hardhat'
const BOX_ADDRESS = "0xc8F70bD743E032E1d277087de3bBA377AEEfFd4f"
async function main() {
    const NewLuckyNFT = await ethers.getContractFactory('NewLuckyNFT')
    console.log("Deploying NFT.....")
    const newLuckyNFT = await NewLuckyNFT.deploy(BOX_ADDRESS);
    console.log('NewLuckyNFT deployed to:', newLuckyNFT.address)
    //0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
}
main()