import {ethers} from 'hardhat'

import {LuckyMetaToken} from '../../typechain/LuckyMetaToken'
import {LuckyMetaTokenFactory} from '../../typechain/LuckyMetaTokenFactory'
import {LuckyTicket} from '../../typechain/LuckyTicket'
import {LuckyTicketFactory} from '../../typechain/LuckyTicketFactory'
import {NewLuckyNft} from '../../typechain/NewLuckyNFT'
import {NewLuckyNftFactory} from '../../typechain/NewLuckyNftFactory'
import {NewLuckyFi} from '../../typechain/NewLuckyFi'
import {NewLuckyFiFactory} from '../../typechain/NewLuckyFiFactory'

interface LuckyMetaTokenFixture {
    token : LuckyMetaToken
}

export async function luckyMetaTokenFixture(): Promise<LuckyMetaTokenFixture> {
    let signers = await ethers.getSigners();
    const factory = new LuckyMetaTokenFactory(signers[0])
    const token = await factory.deploy()
    return {token}
}

interface LuckyTicketFixture {
    luckyTicket: LuckyTicket
}

export async function luckyTicketFixture(): Promise<LuckyTicketFixture> {
    let signers = await ethers.getSigners()
    const factory = new LuckyTicketFactory(signers[0])
    const luckyTicket = await factory.deploy()
    const tokenFix = await luckyMetaTokenFixture()
    return {luckyTicket}
}

interface NewLuckyNftFixture {
    luckyTicket: LuckyTicket,
    newLuckyNft: NewLuckyNft
}

export async function luckyNewLuckyNftFixture(): Promise<NewLuckyNftFixture> {
    let signers = await ethers.getSigners()
    const luckyTicketFix = await luckyTicketFixture()
    const factory = new NewLuckyNftFactory(signers[0])
    const newLuckyNft = await factory.deploy(luckyTicketFix.luckyTicket.address)
    return {newLuckyNft, luckyTicket: luckyTicketFix.luckyTicket}
}

interface NewLuckyFiFixture {
    token : LuckyMetaToken,
    newLuckyNft: NewLuckyNft,
    newLuckyFi: NewLuckyFi,
    
}

export async function newLuckyFiFixture(): Promise<NewLuckyFiFixture> {
    let signers = await ethers.getSigners()
    const tokenFix = await luckyMetaTokenFixture()
    const nftFix = await luckyNewLuckyNftFixture()
    const factory = new NewLuckyFiFactory(signers[0])
    const newLuckyFi = await factory.deploy()
    await newLuckyFi.initialize(tokenFix.token.address, nftFix.newLuckyNft.address)
    return {
        newLuckyFi,
        token: tokenFix.token,
        newLuckyNft: nftFix.newLuckyNft
    }
}