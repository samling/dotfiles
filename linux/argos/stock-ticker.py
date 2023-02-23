#!
from datetime import datetime
import os
from pathlib import Path
import yfinance as yf

stock_symbol = "NVDA"
nvda = yf.Ticker(stock_symbol)

price_current = nvda.fast_info['lastPrice']
price_last_market_close = nvda.fast_info['regularMarketPreviousClose']
price_changed = (float(price_current - price_last_market_close))
price_percent_changed = (float(price_current/price_last_market_close) - 1)*100

#-----------------------------------------------------------------------------

if price_changed is not None:
    if float(price_changed) < 0:
        print("📉 <span></span> <span foreground='#ffb3ba'>{} {:.2f} {:.2f} ({:.2f}%)</span>".format(stock_symbol, price_current, price_changed, price_percent_changed))
    else:
        print("📈 <span></span> <span foreground='#baffc9'>{} {:.2f} {:.2f} ({:.2f}%)</span>".format(stock_symbol, price_current, price_changed, price_percent_changed))
else:
    color = "black"
    print("{} {:.2f} | color={}".format(stock_symbol, price_current, color))

# Write last timestamp
curr_date = datetime.now()
curr_date_str = curr_date.strftime('%-m/%d/%Y %-I:%M%p')
last_updated = open(f"/tmp/argos-stockticker-lastupdated.txt", "w")
last_updated.write(curr_date_str)
last_updated.close()

