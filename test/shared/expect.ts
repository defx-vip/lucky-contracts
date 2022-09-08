import { expect, use } from 'chai'
import chaiAsPromised = require("chai-as-promised")
import { solidity } from 'ethereum-waffle'
import { format } from 'prettier'


use(solidity)
use(chaiAsPromised)

export { expect }