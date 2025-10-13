<template>
  <v-app app>
    <i-bottom-bar v-if="$areNotifications"></i-bottom-bar>
    <input type="hidden" name="intermediary_payoff" :value="totalWealth()" />
    <trade-allowed-dialog
      v-if="$store.getters.tradingAllowed() && !$store.state.training"
    ></trade-allowed-dialog>

    <div class="" v-if="$isHedonic">
      <transition
        enter-active-class="animate__animated animate__bounce animate__slow"
        leave-active-class="animate__animated animate__fadeOutTopRight animate__slow"
      >
        <award-given-block
          v-if="isAwardGiven"
          :awardGiven="awardGiven"
        ></award-given-block>
      </transition>
    </div>
    <v-system-bar
      app
      dark
      v-if="$store.state.training"
      color="red "
      height="30"
      class="d-flex justify-center"
    >
      <div class="text-center">
        <b>TRAINING ROUND</b>
      </div>
    </v-system-bar>
    <v-system-bar
      app
      dark
      height="50"
      class="d-flex justify-center"
      v-if="false"
    >
      <div class="text-center text-h5">
        <b v-if="$isHedonic"
          >Odds to win E$1,000 sweepstake: {{ fullLoteryProb() }} in 1000</b
        >
      </div>
    </v-system-bar>
    <top-bar></top-bar>

    <v-main app v-show="true">
      
      <v-row style="height: calc(100%)">
        <market v-for="market in markets" :name="market" :key="market"></market>
      </v-row>
    </v-main>
    <prediction-dlg></prediction-dlg>
    <div height="100" :border="false" class="mb-3">
      <v-row class="mx-1">
        <v-col cols="6" class="d-flex" >
        <pill label="Position" style="width:100%">
          <animated-counter :value="market.shares" :tweenDuration="1000"></animated-counter>
        </pill>
      </v-col>
      <v-col cols="6">
        
        <buy-sell-bar  :market="market" ></buy-sell-bar>
      </v-col>
      </v-row>
      
    </div>
  </v-app>
</template>

<script>
/* eslint-disable */
import AnimatedCounter from './components/AnimatedCounter.vue';
import AwardGivenBlock from "./components/AwardGiven";
import Pill from "./components/Pill";
import Market from "./components/Market";
import { mapGetters, mapState, mapActions, mapMutations } from "vuex";

import TopBar from "./components/TopBar";
import IBottomBar from "./components/IBottomBar";
import PredictionDlg from "./components/PredictionDialog";
import TradeAllowedDialog from "./components/TradeAllowedDialog";
import BuySellBar from "./components/BuySellBar";
import _ from "lodash";

export default {
  name: "App",
  components: {
    AnimatedCounter,
    Pill,
    AwardGivenBlock,
    PredictionDlg,
    TradeAllowedDialog,
    Market,
    TopBar,
    IBottomBar,
    BuySellBar,
  },
  data: function () {

    return {
      timeInTrade: 0,
      markets: _.shuffle(["A", ]),
      sample: {
        colors: ["red", "green", "blue"],
        interval: 3000,
        transition: {
          duration: 1000,
        },
      },

      startTime: new Date(),
      endTime: null,
      timeSpent: null,
      reset: false,
      messageMoveDelay: 5000,
      dialog: false,
      tweenedPrice: null,
      stockInterval: null,

      awardsGiven: [],
      awards: {
        4: {
          id: 0,
          img: "https://cdn0.iconfinder.com/data/icons/business-finance-vol-2-56/512/stock_trader_trade_exchange-256.png",
          name: "Level I",
          brief: "Level I Badge: Trading intern",
          desc: [
            "Level up! Doing well 👍",
            "Way to go -- stay strong! 💎🤲",
            "You are definitely going places! 🙌",
          ],
        },
        9: {
          id: 1,
          img: "https://cdn2.iconfinder.com/data/icons/financial-strategy-20/496/trader-bitcoin-cryptocurrency-investment-businessman-1024.png",
          name: "Level II",
          brief: "Level II Badge: Trading manager",
          desc: [
            "Level up again! You belong on the trading floor 🤑",
            "Nerves of steel: stocks are going strong! 📈",
            "Bulls 🐂 are in the arena. Good job!",
            "Have you ever thought of opening your own trading firm?",
          ],
        },
        19: {
          id: 2,
          img: "https://cdn1.iconfinder.com/data/icons/office-and-internet-3/49/217-512.png",
          name: "Level III",
          brief: "Level III Badge: Money Boss",
          desc: [
            "You are the money-maker! 💰",
            "Diamond hands 💎🤲 Impressive run!",
            "To the moon! 🚀 🚀 🚀",
          ],
        },
      },
    };
  },
  
  computed: {
    ...mapState(["isAwardGiven", "awardGiven", "counter", "socket", ]),
    ...mapGetters([
    'getMarket',
      "showPredictionDlg",
      "endGame",
      "fullLoteryProb",
      "totalWealth",
    ]),
    market() {
      return this.getMarket('A');
    },
    getMenuStyle() {
      return this.training ? { top: "25px" } : null;
    },
    awardTimes() {
      return _.keys(this.awards);
    },

    pconfig() {
      if (this.particle_type == "fountain") return {};
      return this.heartConfig;
    },
    formattedTween() {
      if (this.tweenedPrice) return this.tweenedPrice.toFixed(2);
      return this.currentPrice.toFixed(2);
    },
  },
  watch: {
    "socket.isConnected"(v) {
      if (v == true) {
        this.sendMessage({ name: "GAME_STARTS" });
      }
    },
    dialog(v) {},
    async counter(v) {
      if (v >= window.initialPricesA.length) {
        this.PAUSE();
        await this.sendMessage({ name: "GAME_ENDS" });
        document.getElementById("form").submit();
      }
    },
  },
  mounted() {
    this.SET_START_TIME();
  },
  methods: {
    ...mapActions(["sendMessage"]),
    ...mapMutations(["SET_START_TIME", "PAUSE"]),
    tweenUpd(v) {
      this.tweenedPrice = _.round(this.tweenedPrice, 2);
    },

    async sell() {},
  },
};
</script>

<style>
#app {
  background: rgba(0, 0, 0, 0);
  /* font-family: "Avenir", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px; */
}

.word-break {
  word-break: break-word;
}

.titlestyle {
  padding-left: 10px;
  margin-left: 20px;
  white-space: pre-wrap;
}

.message {
  padding-left: 10px;
  margin-left: 20px;
  white-space: normal;
  font-family: "Open Sans", sans-serif;
  box-sizing: border-box;
  position: relative;
  max-width: 400px;
  padding: 6px 15px;
  font-size: 12px;
  word-break: break-word;
  color: #fff;
  border: none;
  background-color: rgb(0, 153, 255);
  border-radius: 20px;
}

.listouter1 {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.listouter2 {
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
  /* flex-direction: column-reverse; */
  overflow-y: scroll;
}

.canvas {
  z-index: 1000;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 1s;
}

.fade-enter,
.fade-leave-to
/* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}

.funnyam {
  position: fixed;
  z-index: 1000;
  bottom: 10px;
  right: 10px;
}

.gray {
  filter: gray;
  /* IE6-9 */
  -webkit-filter: grayscale(1);
  /* Google Chrome, Safari 6+ & Opera 15+ */
  filter: grayscale(1);
  /* Microsoft Edge and Firefox 35+ */
}
</style>
