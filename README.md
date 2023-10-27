git clone https://github.com/aechen1202/RugPullHW.git  
cd RugPullHW  
forge install openzeppelin/openzeppelin-contracts --no-commit  
forge install dmfxyz/murky --no-commit  
forge test --mc TradingCenterTest -vv  
forge test --mc USDCTest -vv  
