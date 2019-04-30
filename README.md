# MQL-Quotes
MT4 Client Quotes Export, Can be easily integrated with personal websites without the MT4 Manager API.

# Environment

- Windows 7 above (recommend)
- MetaTrader 4 Client
- [ZeroMQ](https://github.com/zeromq)
- [ZeroMQ for MQL](https://github.com/dingmaotu/mql-zmq)

# Features

- Remote Publisher and Subscriber (Based on IP address)
- Custom export symbols in MarketWatch

# Publisher Optins

| Properties | Description |
| --- | --- |
| `Server`                  | Bind the Publisher server IP address |
| `ServerDelayMilliseconds` | Push the order to subscriber delay milliseconds |
| `ServerReal`              | Under real server |
| `AllowSymbols`            | Allow trading Symbols |
| `OnlyInMarketWatch`       | Only push symbols in market watch |

# Publisher Response

| Properties | Type | Description |
| --- | --- | --- |
| `Login`  | Integer | Login |
| `Symbol` | String  | Symbol name |
| `Ask`    | Double  | Ask price |
| `Bid`    | Double  | Bid price |
| `Spread` | Integer | Spread value in points |

# License

Copyright (c) 2017-2019 ji-Feng Tsai.<br/>
MQL-Zmq Copyright (c) Ding Li [ZeroMQ for MQL](https://github.com/dingmaotu).

Code released under the MIT license.

# TODO

- More examples

# Donation

If this application help you reduce time to trading, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/TW/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3RNMD6Q3B495N&source=url)
