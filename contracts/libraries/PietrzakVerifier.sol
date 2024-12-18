//SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./BigNumbers.sol";

library PietrzakVerifier {
    function r_value(
        BigNumber memory _x,
        BigNumber memory _y,
        BigNumber memory _u
    ) internal pure returns (uint8) {
        // Solvers use sha256 (Sha-2) and so do we
        // And they use the proper big endian byte configuration of the integers
        // s = (x.to_bytes(int_size, "big", signed=False) + y.to_bytes(int_size, "big", signed=False) + μ.to_bytes(int_size, "big", signed=False))
        // b = hashlib.sha256(s).digest()
        // return int.from_bytes(b[:1], "big")

        // We chop off the hash at 1 bytes because that's all we need for r
        bytes memory p = abi.encodePacked(_x.val, _y.val, _u.val);
        bytes32 s = sha256(p);
        uint8 r = uint8(s[0]);
        return r;
    }

    // This is called externally by modules that don't know
    // anything about the BigNumber data type, and therefore 
    // pass large integers as bytes
    function verifyProof(
        bytes memory N,
        bytes memory xi,
        uint256 d,
        bytes memory yi,
        uint8 index,
        bytes[] memory p
    ) internal view returns (bool) {
        // We must also check that input params are valid: x,y are square roots mod N and that the values match the puzzle's data
        // assert (math.gcd(puzzle[PUZZLE_X] - 1, puzzle[PUZZLE_MODULUS]) == 1)
        // assert (math.gcd(puzzle[PUZZLE_X] + 1, puzzle[PUZZLE_MODULUS]) == 1)

        // Make Bignumbers out of everything
        BigNumber memory bnN = BigNumbers.init(N, false);
        BigNumber memory bnxi = BigNumbers.init(xi, false);
        BigNumber memory bnyi = BigNumbers.init(yi, false);
        BigNumber[] memory proof = new BigNumber[](p.length);
        for (uint256 i = 0; i < p.length; i++) {
            proof[i] = BigNumbers.init(p[i], false);
        }

        return verifyProof(bnN, bnxi, d, bnyi, index, proof);
    }

    // This method verifies that proof p correctly asserts that xi^t mod N = yi
    function verifyProof(
        BigNumber memory N,
        BigNumber memory xi,
        uint256 d,
        BigNumber memory yi,
        uint8 index,
        BigNumber[] memory p
    ) private view returns (bool) {
        BigNumber memory ui = p[index];
        BigNumber memory ri = BigNumbers.mod(
            BigNumbers.init(r_value(xi, yi, ui), false), N);

        // AUDIT security/no-assign-params
        BigNumber memory new_xi = BigNumbers.modmul(BigNumbers.modexp(xi, ri, N), ui, N);
        BigNumber memory new_yi = BigNumbers.modmul(BigNumbers.modexp(ui, ri, N), yi, N);

        // Recursion
        if (index + 1 != p.length) {
            return verifyProof(N, new_xi, d - 1, new_yi, index + 1, p);
        }
        else {
            // When there are no more entries in the proof
            if (BigNumbers.eq(new_yi, 
                BigNumbers.modexp(new_xi, BigNumbers.shl(BigNumbers.one(), 2 ** d), N))) {
                // console.log("Proof is Valid");
                return true;
            } else {
                // console.log("Proof is invalid");
                return false;
            }
        }
    }
}
