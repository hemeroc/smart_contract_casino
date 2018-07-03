import React, {Component} from 'react';
import {Chart, ChartCanvas} from "react-stockcharts";
import {XAxis, YAxis} from "react-stockcharts/lib/axes";
import {discontinuousTimeScaleProvider} from "react-stockcharts/lib/scale";
import {last} from "react-stockcharts/lib/utils";
import {tsvParse} from "d3-dsv";
import CandlestickSeries from "react-stockcharts/es/lib/series/CandlestickSeries";
import EdgeIndicator from "react-stockcharts/es/lib/coordinates/EdgeIndicator";

class ChartBlock extends Component {
    componentDidMount() {
        getData().then(data => {
            console.log(data);
            this.setState({data: data})
        })
    }

    render() {
        if (this.state == null) {
            return <h2>Loading...</h2>
        }

        const xScaleProvider = discontinuousTimeScaleProvider
            .inputDateAccessor(d => d.date);
        const {
            data,
            xScale,
            xAccessor,
            displayXAccessor,
        } = xScaleProvider(this.state.data);

        const start = xAccessor(last(data));
        const end = xAccessor(data[Math.max(0, data.length - 150)]);
        const xExtents = [start, end];

        return (
            <ChartCanvas seriesName="Ether"
                         width={1200}
                         height={600}
                         ratio={2}
                         data={data}
                         xScale={xScale}
                         xAccessor={xAccessor}
                         displayXAccessor={displayXAccessor}
                         xExtents={xExtents}
            >
                <Chart id={1}
                       yExtents={[d => [d.high, d.low]]}
                       padding={{top: 40, bottom: 20}}
                >
                    <XAxis axisAt="bottom" orient="bottom"/>
                    <YAxis axisAt="right" orient="right" ticks={5}/>
                    <CandlestickSeries/>
                    <EdgeIndicator itemType="last" orient="right" edgeAt="right"
                                   yAccessor={d => d.close} fill={d => d.close > d.open ? "#6BA583" : "#FF0000"}/>
                </Chart>
            </ChartCanvas>
        );
    }
}

function parseData(parse) {
    return function (d) {
        d.date = parse(d.date);
        d.open = +d.open;
        d.high = +d.high;
        d.low = +d.low;
        d.close = +d.close;
        d.volume = +d.volume;
        return d;
    };
}

function getData() {
    return fetch("//rrag.github.io/react-stockcharts/data/MSFT_INTRA_DAY.tsv")
        .then(response => response.text())
        .then(data => tsvParse(data, parseData(d => new Date(+d))));
}

export default ChartBlock;
