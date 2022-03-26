import os
import json
import subprocess
import time

os.system('ls')

counter = 1
for i in range(1486, 1501):
    path = 'json/' + str(i) + '.json'
    with open(path) as json_file:
        data = json.load(json_file)
        streng = json.dumps(data)
        asci = bytes(streng.encode("ascii"))
        listy = list(asci)
        s = ";"
        s = s.join(map(str, listy))
        with open('wallet.json') as wallets:
            listof = json.load(wallets)
            streng2 = listof[str(i)]
            subprocess.call(r'dfx canister --network ic call nft1 mintNFT "(record { to = (variant { \"principal\" = principal \"'  + streng2 + r'\" }); metadata=opt vec{' + s + r'} } )"', shell=True)

    