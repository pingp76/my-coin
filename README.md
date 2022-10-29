# my-coin

用来本地测试网测试发币安全性

-------0xc1a686339c6e2cfd2d26f6b3b30ee5d7----发币合约地址
account unlock 0xc1a686339c6e2cfd2d26f6b3b30ee5d7 -p123456

// 部署合约
dev deploy /Users/lbxie/starcoin/workspace/my-coin/release/my-coin.v0.0.0.blob -s 0xc1a686339c6e2cfd2d26f6b3b30ee5d7 -b

//发币
account execute-function --function 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::init_coin_script -s 0xc1a686339c6e2cfd2d26f6b3b30ee5d7 -b

//mint
account execute-function --function 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::mint_script --arg 10000 -s 0xc1a686339c6e2cfd2d26f6b3b30ee5d7 -b

// 转钱给受害者100
account execute-function --function 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::transfer_script --arg 0xa0d8e8bc48488466188b163d62b2c919 --arg 100 -s 0xc1a686339c6e2cfd2d26f6b3b30ee5d7 -b

//给黑客转钱22测试
account execute-function --function 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::transfer_script --arg 0xac3e5a1bda65d73b1b893892548578f7 --arg 22 -s 0xc1a686339c6e2cfd2d26f6b3b30ee5d7 -b

//查看余额
state get resource 0xc1a686339c6e2cfd2d26f6b3b30ee5d7 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::Balance<0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::LebingCoin>


------ 0xa0d8e8bc48488466188b163d62b2c919 ------受害者地址
account unlock 0xa0d8e8bc48488466188b163d62b2c919 -p123456

// 初始化balance
account execute-function --function 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::init_balance_script -s 0xa0d8e8bc48488466188b163d62b2c919 -b

//查看余额
state get resource 0xa0d8e8bc48488466188b163d62b2c919 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::Balance<0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::LebingCoin>


------- 0xac3e5a1bda65d73b1b893892548578f7 ---黑客地址
//初始化balance
account execute-function --function 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::init_balance_script -s 0xac3e5a1bda65d73b1b893892548578f7 -b

// 部署黑客合约
dev deploy /Users/lbxie/starcoin/workspace/my-coin/release/my-coin.v0.0.0.blob -s 0xac3e5a1bda65d73b1b893892548578f7 -b

// 以受害者角色来偷钱
account execute-function --function 0xac3e5a1bda65d73b1b893892548578f7::Hackcoin::hack_transfer --arg 0xac3e5a1bda65d73b1b893892548578f7 --arg 20 -s 0xa0d8e8bc48488466188b163d62b2c919 -b

//查看余额
state get resource 0xac3e5a1bda65d73b1b893892548578f7 0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::Balance<0xc1a686339c6e2cfd2d26f6b3b30ee5d7::MyCoin::LebingCoin>


