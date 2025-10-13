<template>
  <v-col cols="12" fill-height class="d-flex flex-column">
    <div id="btns" class="flex-grow-0 flex-shrink-0 text-h4">

      <v-row class="mt-1 mx-1">
        <v-col cols="6">
          <pill label="Total wealth" prefix="$">
            <animated-counter :value="totalWealth()"></animated-counter>
          </pill>
        </v-col>
        <v-col>
          <pill label="Current price">
            <animated-counter :value="market.currentPrice"></animated-counter>
          </pill>
        </v-col>




      </v-row>
      <info-bar :market="market" v-if="salient"></info-bar>

      <v-row v-else class="mx-1">
        <v-col cols="6">
          <pill label="">&nbsp;</pill>
        </v-col>
        <v-col cols="6">

          <pill label="">&nbsp;</pill>
        </v-col>
      </v-row>

    </div>

    <div id="chart" ref="chartWrapper" style="height=100%" class="flex-grow-1 flex-shrink-0">
      <div :style="{ height: `${chartHeight}px` }" v-resize="onResize">
        <highcharts v-if="true" :constructorType="'stockChart'" class="hc" :options="chartOptions" ref="priceGraph"
          :updateArgs="[true, true, true]"></highcharts>
      </div>
    </div>

    <v-row v-if="false">

    </v-row>

  </v-col>
</template>

<script>
import AnimatedCounter from './AnimatedCounter.vue';

import InfoBar from "./InfoBar";
import Pill from "./Pill";
import { Chart } from "highcharts-vue";
import { differenceInSeconds, addSeconds, getTime } from "date-fns";
import { mapMutations, mapActions, mapGetters, mapState } from "vuex";
export default {
  components: {
    highcharts: Chart,
    AnimatedCounter,
    InfoBar,
    Pill,
  },
  props: ["name"],
  data() {
    const rawData = [100, ..._.fill(Array(10), null)];
    return {

      salient: window.salient,
      chartHeight: 0,
      prices: [],
      xAxis: { min: new Date().getTime() },
      tickFrequency: window.tick_frequency,
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
            pointStart: new Date().getTime(), // first of April
            pointInterval: 1000, // hourly data
            name: "Stock price",
            data: rawData,
          },
        ],
      },

      onPause: false,
    };
  },
  watch: {
    "market.currentPrice": {
      immediate: false,
      handler(v) {
        {

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
        }
      }
    },
  },
  computed: {
    ...mapState(["counter"]),
    ...mapGetters(["getMarket", "totalWealth",]),
    market() {
      return this.getMarket(this.name);
    },
  },
  async mounted() {
    this.tweenedPrice = this.market.currentPrice
    this.onResize();
  },

  methods: {
    ...mapMutations(["SET_MARKET_PROPERTY"]),
    ...mapActions(["setPrice", "purchase", "sell"]),
    onResize() {
      console.debug("DO WE MOUNT AND RESIZE??")
      this.chartHeight = this.$refs.chartWrapper.clientHeight - 30;
      this.$nextTick(() => {
        this.$refs.priceGraph.chart.setSize(null, this.chartHeight);
        this.$refs.priceGraph.chart.reflow();
      });
    },
    sellClicked() {

    },
    buyClicked() {

    },
  },
};
</script>
