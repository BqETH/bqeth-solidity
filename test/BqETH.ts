import 'solidity-coverage'
import { FakeContract, smock } from '@defi-wonderland/smock';

// chai.should(); // if you like should syntax
// chai.use(smock.matchers);

// describe('MyContract', () => {
//     let myContractFake: FakeContract<BqETH>;

//     beforeEach(async () => {
//         myContractFake = await smock.fake('BQETH');
//     });

//     it('some test', () => {
//         myContractFake.bark.returns('woof');
//         myContractFake.bark.atCall(0).should.be.calledWith('Hello World');
//     });
// });
