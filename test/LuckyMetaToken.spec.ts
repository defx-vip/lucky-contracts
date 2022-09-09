import {expect} from './shared/expect'
import {SignerWithAddress} from '@nomiclabs/hardhat-ethers/signers'
import {ethers, waffle} from 'hardhat'
import {Wallet, BigNumber} from 'ethers'
import {luckyMetaTokenFixture} from './shared/fixtures'
import {LuckyMetaToken} from '../typechain/LuckyMetaToken'

describe("LuckyMetaToken", () => {
    let user1: SignerWithAddress
    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let lmt: LuckyMetaToken
    const ten = BigNumber.from(10)
    before("create fixture loadder", async() => {
        let [owner] = await ethers.getSigners()
        user1 = owner
        let wallet: Wallet, other: Wallet
        [wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })
    beforeEach('deploy LuckyMetaToken', async () => {
        console.info(loadFixture)
        let fixture = await loadFixture(luckyMetaTokenFixture)
        lmt = fixture.token
    })

    it('test balanceOf', async() => {
        let total = ten.pow(18).mul(ten.pow(8));
        expect(await lmt.balanceOf(user1.address)).to.be.eq(total)
    })
})