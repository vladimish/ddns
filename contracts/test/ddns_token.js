const ddnsToken = artifacts.require("DDNSToken");

contract("DDNSToken", (accounts) => {
    let instance;
    let owner = accounts[0];
    let initialSupply = 50_000_000;
    let tokenCap = 100_000_000;
    let tokenBlockReward = 50;

    beforeEach(async () => {
        instance = await ddnsToken.new(initialSupply, tokenCap, tokenBlockReward, {from: owner});
    });

    contract("Deployment", () => {
        it("Should set the right owner", async () => {
            const contractOwner = await instance.owner();
            assert.equal(contractOwner, owner);
        });

        it("Should assign the total supply of tokens to the owner", async () => {
            const ownerBalance = (await instance.balanceOf(owner)).toString();
            assert.equal((await instance.totalSupply()).toString(), ownerBalance);
        });

        it("Should set the max capped supply to the argument provided during deployment", async () => {
            const cap = (await instance.cap()).toString();
            assert.equal(cap, web3.utils.toWei(tokenCap.toString(), "ether"));
        });

        it("Should set the blockReward to the argument provided during deployment", async () => {
            const blockReward = (await instance.blockReward()).toString();
            assert.equal(blockReward, web3.utils.toWei(tokenBlockReward.toString(), "ether"));
        });
    });

    contract("Transactions", () => {
        it("Should transfer tokens between accounts", async () => {
            // Transfer 50 tokens from owner to accounts[1]
            await instance.transfer(accounts[1], 50, {from: owner});
            const addr1Balance = (await instance.balanceOf(accounts[1])).toString();
            assert.equal(addr1Balance, "50");

            // Transfer 50 tokens from accounts[1] to accounts[2]
            await instance.transfer(accounts[2], 50, {from: accounts[1]});
            const addr2Balance = (await instance.balanceOf(accounts[2])).toString();
            assert.equal(addr2Balance, "50");
        });

        it("Should fail if sender doesn't have enough tokens", async () => {
            const initialOwnerBalance = (await instance.balanceOf(owner)).toString();
            // Try to send 1 token from accounts[1] (0 tokens) to owner (1000000 tokens).
            // `require` will evaluate false and revert the transaction.
            try {
                await instance.transfer(owner, 1, {from: accounts[1]});
            } catch (e) {
                assert.equal(true, e.reason.includes("ERC20: transfer amount exceeds balance"));
            }
            // Owner balance shouldn't have changed.
            assert.equal((await instance.balanceOf(owner)).toString(), initialOwnerBalance);
        });

        it("Should update balances after transfers", async () => {
            const initialOwnerBalance = (await instance.balanceOf(owner)).toString();
            // Transfer 100 tokens from owner to accounts[1].
            await instance.transfer(accounts[1], 100);
            // Transfer another 50 tokens from owner to accounts[2].
            await instance.transfer(accounts[2], 50);
            // Check balances.
            const finalOwnerBalance = (await instance.balanceOf(owner)).toString();
            assert.equal(finalOwnerBalance, (BigInt(initialOwnerBalance) - BigInt(150)).toString());

            const addr1Balance = (await instance.balanceOf(accounts[1])).toString();
            assert.equal(addr1Balance, "100");

            const addr2Balance = (await instance.balanceOf(accounts[2])).toString();
            assert.equal(addr2Balance, "50");
        });
    });
});