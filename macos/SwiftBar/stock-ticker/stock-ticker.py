#!/usr/bin/env python3

import json
import os
import requests
from pprint import pformat
from typing import Optional, Dict, Any, Union

api_base = "https://api.tiingo.com/iex/"

class Stock:
    def __init__(self, symbol: str, last_price: float, previous_close: float, open: float):
        self.symbol = symbol
        self.open = open
        self.last_price = last_price
        self.previous_close = previous_close

    def __repr__(self):
        return (f"Stock(symbol={self.symbol}, last_price={self.last_price}, previous_close={self.previous_close}, open={self.open})")

    def get_change(self):
        change = self.last_price - self.previous_close
        return change, f"{change:.2f}" if change != 0 else "0.00"

class TiingoClient:
    def __init__(self, api_token):
        self.api_token = api_token

    def get_stock_data(self, symbol: str) -> Optional[Stock]:
        try:
            response = requests.get(
                f"{api_base}/?tickers={symbol}&token={self.api_token}"
            )
            response.raise_for_status()

            data = response.json()
            # print(pformat(data))
            if data and isinstance(data, list) and len(data) > 0:
                stock_data = data[0]
                return Stock(
                    symbol=stock_data['ticker'],
                    open=stock_data['open'],
                    last_price=stock_data['tngoLast'],
                    previous_close=stock_data['prevClose'],
                )
            raise ValueError(f"No stock data for symbol {symbol} returned from API")
        except requests.exceptions.HTTPError as e:
            if hasattr(e, 'response') and e.response.status_code == 429:
                raise RuntimeError(f"Error (429)|color=orange")
            raise RuntimeError(e)
        except Exception as e:
            raise RuntimeError(e)

headers = {
    'Content-Type': 'application/json'
}

api_key = os.getenv('TIINGO_API_KEY')
if not api_key:
    print("TIINGO_API_KEY is not set")
    print("---")

client = TiingoClient(api_key)
try:
    ticker = 'NVDA'
    stock_data = client.get_stock_data(ticker)

    change, change_str = stock_data.get_change()
    color_code = 'lime' if change > 0 else 'red' if change < 0 else 'white' # green for positive, red for negative

    print(f"""{ticker} ${stock_data.last_price} ({change_str})|color={color_code}
---
Test
""")
except Exception as e:
    print(f"{e}")
    print("---")
