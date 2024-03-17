//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./StakingLove.sol";
import "./interface/IERC721.sol";

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

contract NFTStaker {
    StakingLove immutable stakingLove = StakingLove(0x594283B91cFC145509d320A6a8723b36E9a41155);

    constructor() {
        if (block.chainid != 8453) revert("can only deploy on base");
    }

    function createStakingPool(IERC721Metadata createPoolFor) public {
        (string memory name, string memory symbol) = _getNameAndSymbol(createPoolFor);

        bytes32 validationSalt = keccak256("RANDOM_VALUE");
        uint256 totalSupply = 200_000_000_000 ether;

        // bytes32 commitmentHash = stakingLove.calculateCommitmentHash(name, validationSalt);

        stakingLove.createPool({
            _nft: address(createPoolFor),
            name: name,
            sym: symbol,
            totalSupply: totalSupply,
            // 4% team alloc
            teamBps: 400,
            liquidityLockPeriodInSeconds: 420,
            salt: validationSalt,
            proof: _getProof()
        });
    }

    function _getNameAndSymbol(IERC721Metadata nftToStake)
        internal
        view
        returns (string memory stakingTokenName, string memory stakingTokenSymbol)
    {
        string memory name;
        string memory symbol;

        try nftToStake.name() returns (string memory _name) {
            name = _name;
        } catch (bytes memory) {
            revert("Token does not support metadata");
        }
        try nftToStake.symbol() returns (string memory _symbol) {
            symbol = _symbol;
        } catch (bytes memory) {
            revert("Token does not support metadata");
        }

        stakingTokenName = string.concat("Staked ", name);
        stakingTokenSymbol = string.concat(unicode"🥩-", symbol);
    }

    function _getProof() internal pure returns (bytes memory proof) {
        proof =
            hex"0ee56435420086f6ecb3788b8e1b9ae6ee138ef2c731ad6ed68897c0ff848f580d435f7d297aba71405e13e50586cb1ada87b37b92407153a37e2707d342078a133c946e7e2f346967ef47155b7aebb4b3ca81a342e372a0f93ad4519a28db4e25547747b2f1c7951052cdbc3089bf626560472cfb0b74b3597609cd2a1828d52e4b47a096039950a9595d1669827c6d9b58ce82e26c7c6f9524431d565a45712ab508385c2bf2782266adaf91aa3d1832f3ff8b4a2d37f0a7a89312bacfceab1436c4bbde5004ed6ae55c71039fc03afd79bd23cee370e37bee3d60193ed44408e70f6de3cafcec4b2609fc3d3f92e7b1a5bd32b5bf4e9f826ddd592f6afa002f793815fde974adb45a365f7eed2c56db2dada397be25064d6c7a28a1ff7b980baaf4046f4ee7657da538efb65c022255521723697c0a5cb7ce37c7524f79fd2f491ac2f18d03a337d2581108b1bd3060443608d24fa5ca203245e2c71e67b01745f26f87f30e3a458e6d5fdd2bf2e72201e2bbc3a8fd0b67b87cbd0baebe9400feeaa85920514c3af36b5bf616e05ef1e6392dc4ce2f0aa93da2436a9b8cbe1a1b4a045f15fd73f718f3be8cedb94dc6bf5e28c855f17243edae99838b51271da625a42533d47e3f684ff163cad5c414bbe641135acc6299984f2ac28577882eb39c10eceef48d9bb72bb19e3559b85f032a3283d5fb14cb39220d6c97ee231df38bef9324cef49ab5aba4a4d219225172ac4e01175d7710481493d5ae776226c2a6e24bbdb977f3434e45a5d6f4ff5d30ff5fba1fa630401dbf2aea9722b71da627211c62a4e43e285fefa8645fa8be5dff146a417aa758d48cc45b6a60d40f5d3e714195a209bf015db1e0ef4f5b118232d6a50f831d6716b5c5950e58392178aa3b5fe6eefdf37b443b5bdfb7771e13a955ff0a8e93ad29c55b1bd8769c2c83cf59d9824c3ad4c3d0c3b43b622dbc799e39ed7cc4800b3df4d2c8290a952d34a8f15e1baf476cd9ac714e17a746e9e4ff4e1ea2b770c516223b012d7ac227065b552c4cca6f0d68969d3876e8c13b058e32c6852cf7a40bfe747f762da32a6778fc8cec50d29e5233e7b5473b8f231f7d237955f46e5cece32c26d3d83201ebf9f2f80f076eb2b4dec9c823340c46cef39979a978910f8f8399c316938a3023bccbe624ac06012f0829a4693fc13fbaaabc4541c5f8e8a6b8d371ec49212a675b3fdd44a49d8f71ecaba800b16fb0a9b41231f46d7ff594737747b0199a1fae6be813fab8dd7fbea74d6b1dc294d5eb07e99decc328eddfdfb60a8eac562799e60bf1fce431e38435cf07b35ee0373e0472235881527dd26e2cd6b2f9f925836f2e6aae9738a9469db705f44ca22ecde5169358924fe6da2d0a0a3cf2d923fc2ce10cce3736c4642fa61b4df4e67fc003d6c01b08854dbb1c32def709852c3786e5cbc3e73c0cd840de6fe3cb0cb697a4c0f2c540e337f5ca152fa7e0f111646de2fa93a744d45b19ce6cc1b1087356c4a8ed0d21bf18e813e56d0994062676b01fb38fe751a263d43f1183845d53b91ad951d983e966caa272c3277b4f14acfcf7b20ad510470c4edde5e3e28c05b24e0d25d91d4db2291dd219d7bbfa160b8aadb6d002a5093a7c0120366186ef75737fc30578675fc0503f44e507ba07c8b0ae9ef8070e7486ddc4e2553a3a842239d6ec7e3ef2bcc4b7a67d7a64b608a619a5943007d72c2412dac297960821099599788c45f143853dd56ef9c53c1381f1b887aa34941c7f656b090ad6a3c5cd4b17a943d15b4742aca7bf76988b001edfe4594b72c3a09c0b05530e522be63552c7bd4fcedceac2e7689fe5490b192dee12ccc72512afad2145a56428d8d42754973c7f53e4006c7b1ed8fed90110cd8e77eba6bbec15b2909a6b718d4e288b353ab387e74a78d5e4300d955e850a60eb937ea009689b5e7d06831c4da35ad84d1e90a853ee51064a3351f886480b3e548a73d80a3152fbb21c635ea970f7bfa8e11cb65aecd7c6d0624377e6ce0c1bbd8169100afa0a98e73243a1053e94a704a3a8c461eb5e87569134f747540cf926785e480bc2c2361c4823e3610c318e606634d268e9e547dcc02676a7da0983829c8968089fe3c147f0a2d9f1d5bdf0f15c049a4cefca45c404607925c21946797325757cbeb163677b656783a71a625abcb176040adcad75f2ae85d986269009f3b5a8e0cb6c4e9b23988beb57f585d8ed3569a7afae99ce968a92c79315c6dbd34b161b67825cd4fb4bb31ccefd292a316be313859bdb2b1338a1b7101c89a1d6fb993fdc2bb80423504278a6f22d39bd721df98cdd672865cbfb356025b3bc836750ce36b52414f39786146a3be59282904954a18adfac86e65131f32fdc1a9cb81e902d9c67e172567afbd098677a89a7157e412a8d22e3c617b72b05c1a3ab0131bd04e46febdf4dafb8bea41637ffe66e60f3a948c698020d25f10307c5085d7c07f8688233b1e2cf46256fd30759aa0712069021f8f62f805aea2086a8fb6b2fb7d88dd8861bd81550c905dfda14f627194a1fad4c7d968cfec02913d38450b9d8d09fe09e4630ebed307eace464bb5f047a392c85cc3f94c0382c17fb850c78f39398abbb0c0491fae7f0032af083a398aa065fe0f493760f2b10a740c05173b7b3c79233e091c1b6731f14dcc080d01d7aa4ed3f941f1c2c1209f9ce67dd5fc1a6797bac94dda6f6ed304df319cc97e281fcb0b147cf092fbe034c5c0f694bcb992b652549298c376741870973185fa789547422fb7ef6336a2d033829d66975b5959ee3b3f6f2d03e7af40814dde0dd21f0198a431ee33717020cc3974f1df7bba9bc9daa7fbecb713bdc482ade449080064caa74869d1aaf26a899a1ef6611b4a19cb807a0cf67c080ac547328601485159951b2d33fda9e25e61036f8b81b3b1bf2e44a9040e9e20f5c715553f915634988ea2399d2532414efacd3a6500cb535639acad95d0cb7a5a88616d7686b5dfb7dc5eadb192935";
    }
}
