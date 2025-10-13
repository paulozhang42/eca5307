<template>
   
      <div :style="{ height: `${chartHeight}px` }" v-resize="onResize">
        <highcharts
          v-if="true"
          :constructorType="'stockChart'"
          class="hc"
          :options="chartOptions"
          ref="priceGraph"
          :updateArgs="[true, true, true]"
        ></highcharts>
      </div>
    
</template>

<script>

import { Chart } from "highcharts-vue";

import {  mapGetters, mapState } from "vuex";
export default {
  components: {
    highcharts: Chart,
   
  },
  props: ["name"],
  data() {
    const rawData = [100, ..._.fill(Array(10), null)];
    return {
      chartHeight: 0,
      
      rawData: rawData,

      chartOptions: {
        chart: {
          // height: "100%",
          events: {
            load: function (event) {
              // event.target.reflow();
            },
          },
        },

        events: {
          load: (function (self) {
            return function () {
              self.chart = this; // saving chart reference in the component
            };
          })(this),
        },
        time: { useUTC: false },
        rangeSelector: {
          // allButtonsEnabled: true,
          enabled: true,
          inputEnabled: false,
          buttons: [
            {
              type: "second",
              count: 10,
              text: "10s",
            },
            {
              type: "all",
              text: "All",
              title: "View all",
            },
          ],
          selected: 0,
        },
        navigator: { enabled: false },
        credits: { enabled: false },
        series: [
          {
            type: "line",
            pointStart: new Date().getTime(), 
            pointInterval: 1000, 
            name: "Stock price",
            data: rawData,
          },
        ],
      },

      onPause: false,
    };
  },
  watch: {
    "market.currentPrice"(v) {
      let updObj = v;
      const data = this.$refs.priceGraph.chart.series[0];
      if (this.counter < this.rawData.length) {
        const { x, y } = data.data[this.counter];
        this.$refs.priceGraph.chart.series[0].removePoint(this.counter, false);
        updObj = { x, y: v };
      }
      this.$refs.priceGraph.chart.series[0].addPoint(
        updObj,
        false,
        false,
        true
      );
      this.$refs.priceGraph.chart.redraw();
    },
  },
  computed: {
    ...mapState(["counter"]),
    ...mapGetters(["getMarket"]),
    market() {
      return this.getMarket(this.name);
    },
  },
  async mounted() {
    this.onResize();
  },

  methods: {
    onResize() {
      this.chartHeight = this.$refs.chartWrapper.clientHeight - 50;
      this.$nextTick(() => {
        this.$refs.priceGraph.chart.setSize(null, this.chartHeight);
        this.$refs.priceGraph.chart.reflow();
      });
    },
   
  },
};
</script>
