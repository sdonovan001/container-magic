import os
import yfinance as yf
import binascii
import matplotlib
import pandas as pd
matplotlib.use("SVG")

from mplchart.chart import Chart
from mplchart.primitives import Candlesticks, Volume
from mplchart.indicators import ROC, SMA, EMA, RSI, MACD
from flask import Flask, make_response

app = Flask(__name__)
ip_addr = os.environ.get('ip_addr', '0.0.0.0')
print("listening on %s" % ip_addr)

@app.route('/')
@app.route('/status')
def hello_world():
    return {'status': 'OK'}, 200 

@app.route('/chart/<symbol>')
def get_chart(symbol):
    prices = yf.Ticker(symbol).history('2y') 
    max_bars = 126

    indicators = [
        Candlesticks(), SMA(50), SMA(200), Volume(),
        RSI(),
        MACD(),
    ]

    chart = Chart(title=symbol, figsize=(10, 5), max_bars=max_bars)
    chart.plot(prices, indicators)

    svg = chart.render("svg")
    svg_str = svg.decode("UTF-8")

    # strip off xml stuff at the begining
    output = svg_str.split("\n", 3)[3]

    return make_response(output)
    
if __name__ == '__main__':
    app.run(debug=False, host="0.0.0.0", port=8080)
