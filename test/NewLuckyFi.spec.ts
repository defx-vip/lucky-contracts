import {expect} from './shared/expect'
import {SignerWithAddress} from '@nomiclabs/hardhat-ethers/signers'
import {ethers, waffle} from 'hardhat'
import {Wallet, BigNumber} from 'ethers'
import {newLuckyFiFixture} from './shared/fixtures'
import {LuckyMetaToken} from '../typechain/LuckyMetaToken'
import {NewLuckyNft} from '../typechain/NewLuckyNft'
import {NewLuckyFinanceUpgradeable} from '../typechain/NewLuckyFinanceUpgradeable'
const ten = BigNumber.from(10)
describe("NewLuckyFi", () => {
    let user1: SignerWithAddress, user2: SignerWithAddress
    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let lmt: LuckyMetaToken
    let nft: NewLuckyNft
    let fi: NewLuckyFinanceUpgradeable
    const ten = BigNumber.from(10);
    before("create fixture loadder", async() => {
        [user1, user2] = await ethers.getSigners()
        let wallet: Wallet, other: Wallet
        [wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })
    beforeEach('deploy NewLuckyFi', async () => {
        console.info(loadFixture)
        let fixture = await loadFixture(newLuckyFiFixture)
        lmt = fixture.token
        nft = fixture.newLuckyNft
        fi = fixture.newLuckyFi
        await nft.addWhiteList(user1.address);
        await nft.setApprovalForAll(fi.address, true)
        await nft.connect(user2).setApprovalForAll(fi.address, true)
        await lmt.transfer(fi.address, ten.pow(20))
    })

    it('test mint nft', async() => {
        await  nft.safeMint(user1.address, 1)
        expect(await nft.balanceOf(user1.address)).to.be.equal(1)
        console.info(await nft.nftStartTime(1))
    })

    it('test linkNft', async () => {
        await nft.safeMint(user1.address, 1)
        await fi.batchLinkNft()
        expect((await fi.nftInfo(1))._isLink).to.equal(true)
    })

    it('test depositeNft', async () => {
        await nft.safeMint(user1.address, 1)
        await fi.batchLinkNft()
        await fi.depositeNft(1)
        expect((await fi.showDepositeIds())[0]).to.be.equal(1)
        expect(await fi.totalHashToken()).to.be.equal(ten.pow(8))
        // let now = parseInt((new Date().getTime() / 1000) + "")
        // let l = now + 10
        // while(now <= l) {
        //     now = parseInt((new Date().getTime() / 1000) + "")
        // }
        expect(await fi.showExpBonus()).to.be.equal(0)
    })
    it('test withdrawNftAll', async () => {
        await nft.safeMint(user1.address, 1)
        await fi.batchLinkNft()
        await fi.depositeNft(1)
        expect((await fi.showDepositeIds())[0]).to.be.equal(1)
        expect(await fi.totalHashToken()).to.be.equal(ten.pow(8))
        await fi.withdrawNftAll()
        expect(await fi.totalHashToken()).to.be.equal(0)
        expect((await fi.showDepositeIds()).length).to.be.equal(0)
    })

    it('test getBounds', async () => {
        await nft.safeMint(user1.address, 1)
        await nft.safeMint(user1.address, 3)
        await fi.batchLinkNft()
      

        await nft.safeMint(user2.address, 2)
        await fi.connect(user2).batchLinkNft()

        await fi.depositeNft(1)
        await fi.depositeNft(3)
        await fi.connect(user2).depositeNft(2)

        expect(await fi.totalHashToken()).to.be.equal(ten.pow(8).mul(3))
        let now = parseInt((new Date().getTime() / 1000) + "")
        let l = now + 10
        while(now <= l) {
            now = parseInt((new Date().getTime() / 1000) + "")
        }
        await nft.safeMint(user2.address,  100)
        console.info(await fi.showExpBonus())
        console.info(await fi.connect(user2).showExpBonus())
    })
})