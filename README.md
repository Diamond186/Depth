# Depth

A desktop order book viewer for crypto exchanges, written in Delphi in 2018.

This is where the idea behind [Depth Liquidity](https://depthliquidity.com) started: look past the
candles and see how much money actually sits in the book around the price.

## What it does

- Pulls order books, 24h stats and recent trades over public REST APIs
- Supports 11 exchanges: Binance, BitMEX, Bitfinex, Bitstamp, Bittrex, Coinbase Pro, HitBTC, Huobi,
  Kraken, OKEx, Poloniex
- Shows bids and asks inside a price range, set as a percent from the price or as min/max
- Hides orders below a minimum amount and highlights the big ones
- Several pairs side by side, each in its own panel

## Status

Archived. Written for Windows (VCL) against the exchange APIs of 2018, many of which have changed
or shut down since. The live successor is [depthliquidity.com](https://depthliquidity.com).

## Author

**Igor Movchan**: [LinkedIn](https://www.linkedin.com/in/igor-movchan-947193a5/)
