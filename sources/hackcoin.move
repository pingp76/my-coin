module MyCoinAddress::Hackcoin {
    //use StarcoinFramework::Signer;
    use MyCoinAddress::MyCoin;

    // public fun hack_mint(account:&signer, amount:u64) {
    //     MyCoin::mint<MyCoin::LebingCoin>(account,amount,MyCoin::LebingCoin{});
    // }

    public(script) fun hack_transfer(from:signer, dest:address, amount:u64) {
        MyCoin::transfer<MyCoin::LebingCoin>(&from,dest,amount);
    }
}