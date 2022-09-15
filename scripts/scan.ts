import {ethers, upgrades } from 'hardhat'
import {utils } from 'ethers'
import { writeFileSync, readFileSync } from 'fs'

const nftAddress = "0x9FfEe0B6450cb8F8A59cb46bAeB00133E49555bf"
const poolAddress = "0xDB3f65C45c46b771f200A92f355f44a099bffE53"
const newPoolAddress = "0xB52EDb80B726a09447EEff2cfCDbCE7d7466442c"


async function main() {
  
    const LuckyNFT = await ethers.getContractFactory('LuckyNFT')
    const luckyNFT = LuckyNFT.attach(nftAddress)

    const NewLuckyFinance = await ethers.getContractFactory("NewLuckyFinanceUpgradeable")
    const newLuckyFinance = NewLuckyFinance.attach(newPoolAddress)
    let filter  = luckyNFT.filters.Transfer(null, poolAddress)
    let startBlock = 30221131 
    //let startBlock = 30176086 
    let stepBlock = 1000
    //let lastBlock = 33101548
    let lastBlock = 30579089
    let ids = getIds()
        aa:
        while (startBlock <= lastBlock) {
            let endBlock = startBlock + stepBlock;
            if (endBlock > lastBlock) endBlock = lastBlock
            let list = await luckyNFT.queryFilter(filter, startBlock, endBlock)
            console.info(`list = ${list.length}`)
            console.info(`startBlock = ${startBlock}  endBlock = ${endBlock}`)
            try {
                for(var i =0; i < list.length; i++) {
                    let element = list[i]
                    let id = parseInt(element.topics[3]) 
                    
                    if ( !ids[id] ) {
                        console.info(`id = ${id} block = ${element.blockNumber}`)
                        let nftInfo = await newLuckyFinance.nftInfo(id)
                        if (!nftInfo._isLink) {
                            let timestamp = (await element.getBlock()).timestamp
                            const sendTransaction = async() => {
                                const transaction = await newLuckyFinance.upgradeLinkNft(id, timestamp, poolAddress)
                                // wait() has the logic to return receipt once the transaction is mined
                               const receipt = await transaction.wait()
                            }
                            await sendTransaction()
                        }
                        ids[id] = true
                    }
                }
                startBlock = endBlock + 1 
                writeFileSync(`id.json`, JSON.stringify(ids))
            } catch (error) {
                writeFileSync(`id.json`, JSON.stringify(ids))
                console.error(error)
                continue aa;
            }
           
        } 
   
    
}



function getIds() : any {
    let ids: Array<number> = new Array()
    const data = readFileSync('./id.json', 'utf8');
    return JSON.parse(data)
}
main()