const main = async () => {
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy('artesanato');
    await domainContract.deployed();
    console.log('Domain contract delivered to: ', domainContract.address);

    const registerName = await domainContract.register('oficinacanto', {value: hre.ethers.utils.parseEther('0.01')});
    await registerName.wait();

    const domainOwnerAddress = await domainContract.getAddress('oficinacanto');
    console.log('Domain owner is', domainOwnerAddress);

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log('Our balance is', hre.ethers.utils.formatEther(balance));
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    };
};

runMain();
