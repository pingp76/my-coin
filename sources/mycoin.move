module MyCoinAddress::MyCoin {
    //use StarcoinFramework::Errors;
    use StarcoinFramework::Signer;

    //Const Error
    const ERROR_NOT_DEPLOYER:u64 = 101;
    const ERROR_BALANCE_EXIST:u64 = 102;
    const ERROR_BALANCE_NOT_EXIST:u64 = 103;
    const ERROR_INSUFFICENT_BALANCE:u64 = 104;
    const ERROR_NO_MINT_CAPABILITY:u64 = 105;
    const ERROR_TRASFER_TO_SELF:u64 = 106;

    struct Coin<phantom CoinType> has store {
        value: u64
    }

    // struct balance
    struct Balance<phantom CoinType> has key {
        coins: Coin<CoinType>
    }

    struct MintCapability<phantom CoinType> has key {}
    struct BurnCapability<phantom CoinType> has key{}

    // init coin
    fun init_coin<CoinType:drop>(account:&signer, _witness:CoinType) {
        // check address
        assert!(Signer::address_of(account)==@MyCoinAddress, ERROR_NOT_DEPLOYER);

        // create balance
        init_balance<CoinType>(account);

        //capability 
        move_to(account,MintCapability<CoinType> {});
        move_to(account,BurnCapability<CoinType> {});
    }

        // init balance
    fun init_balance<CoinType> (account:&signer) {
        assert!(!exists<Balance<CoinType>>(Signer::address_of(account)), ERROR_BALANCE_EXIST);
        move_to(account, Balance<CoinType>{coins:Coin<CoinType>{value:0} });
    }

    spec init_balance {
        let addr = Signer::address_of(account);
        aborts_if exists<Balance<CoinType>>(addr);
    }

    // balance of
    fun balance_of<CoinType> (account:&signer):u64 acquires Balance{
        assert!(exists<Balance<CoinType>>(Signer::address_of(account)), ERROR_BALANCE_NOT_EXIST);
        borrow_global<Balance<CoinType>>(Signer::address_of(account)).coins.value
    }

    spec balance_of{
        pragma aborts_if_is_strict;
        aborts_if !exists<Balance<CoinType>>(Signer::address_of(account)); 
    }

   // mint coin
    public fun mint<CoinType:drop>(account:&signer, amount:u64, _witness:CoinType) acquires Balance{
        assert!(exists<MintCapability<CoinType>>(Signer::address_of(account)),ERROR_NO_MINT_CAPABILITY);
        deposit<CoinType>(Signer::address_of(account), Coin<CoinType>{value:amount});
    }

    spec mint {
        aborts_if !exists<MintCapability<CoinType>>(Signer::address_of(account));
        include DepositSchema<CoinType>{
            addr:Signer::address_of(account),
            value:amount
        };
    }

    // transfer coin
    public fun transfer<CoinType:drop>(from:&signer, dest:address, amount:u64) acquires Balance{
        assert!(Signer::address_of(from)!=dest,ERROR_TRASFER_TO_SELF);
        let coins = withdraw<CoinType>(from, amount);
        deposit<CoinType>(dest, coins);
    }

    spec transfer {
        let from_addr = Signer::address_of(from);
        let from_balance = global<Balance<CoinType>>(from_addr).coins.value;
        let dest_balance = global<Balance<CoinType>>(dest).coins.value;
        let post from_post_balance = global<Balance<CoinType>>(from_addr).coins.value;
        let post dest_post_balance = global<Balance<CoinType>>(dest).coins.value;

        // exist balance?
        aborts_if !exists<Balance<CoinType>>(from_addr);
        aborts_if !exists<Balance<CoinType>>(dest);
        // from = to?
        aborts_if from_addr==dest;
        //enough balance
        aborts_if from_balance < amount;
        //exceed maxium
        aborts_if dest_balance > MAX_U64 - amount; 
        // check balance
        ensures from_post_balance == from_balance - amount;
        ensures dest_post_balance == dest_balance + amount;
    }

    // deposit
    fun deposit<CoinType>(addr:address, coins: Coin<CoinType>) acquires Balance {
        assert!(exists<Balance<CoinType>>(addr), ERROR_BALANCE_NOT_EXIST);
        let balance = borrow_global_mut<Balance<CoinType>>(addr);
        let Coin<CoinType> { value } = coins;
        balance.coins.value = balance.coins.value+value;
    }

    spec deposit {
        include DepositSchema<CoinType>{addr:addr, value:coins.value};
    }

    spec schema DepositSchema<CoinType> {
        //
        addr:address;
        value:u64;

        let balance = global<Balance<CoinType>>(addr).coins.value;
        aborts_if !exists<Balance<CoinType>>(addr);
        aborts_if balance > MAX_U64-value;

        let post balance_post = global<Balance<CoinType>>(addr).coins.value;
        ensures balance_post == balance + value; 
    }


    // withdraw
    fun withdraw<CoinType:drop>(account:&signer, amount:u64):Coin<CoinType> acquires Balance{
        assert!(exists<Balance<CoinType>>(Signer::address_of(account)), ERROR_BALANCE_NOT_EXIST);
        let balance = borrow_global_mut<Balance<CoinType>>(Signer::address_of(account));

        if(balance.coins.value>=amount) {
            balance.coins.value = balance.coins.value - amount;
        } else {
            abort(ERROR_INSUFFICENT_BALANCE)
        };
        Coin<CoinType>{value:amount}
    }

    spec withdraw {
        let addr = Signer::address_of(account);
        let balance = global<Balance<CoinType>>(addr).coins.value;
        //balance
        aborts_if !exists<Balance<CoinType>>(addr);
        // amount
        aborts_if global<Balance<CoinType>>(addr).coins.value < amount;

        let post balance_post = global<Balance<CoinType>>(addr).coins.value;
        ensures balance_post == balance - amount;
    }

        // struct coin
    struct LebingCoin has drop {
    }

    public(script) fun init_coin_script(account:signer) {
        init_coin<LebingCoin>(&account, LebingCoin{});
    }

    public(script) fun mint_script(account:signer, amount:u64) acquires Balance {
        mint<LebingCoin>(&account,amount,LebingCoin{});
    }

    public(script) fun init_balance_script(account:signer) {
        init_balance<LebingCoin> (&account);
    }

    public(script) fun transfer_script(account:signer, dest:address, amount:u64) acquires Balance{
        transfer<LebingCoin>(&account, dest, amount);
    }
}
