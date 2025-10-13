<template></template>
<script>
import { mapState, mapActions, mapMutations, mapGetters } from "vuex";
import _ from "lodash";
export default {
  props: ["value", "label"],
  data() {
    return {};
  },
  computed: {
    ...mapState(["transactionCounter", "awardTrades", "awardGiven"]),
    ...mapGetters(["nTransactions", "showPredictionDlg", 'hedonic']),
  },
  watch: {
    "$store.getters.showPredictionDlg"(v) {
      if (v() === true) {
        this.pause();
      }
    },
    "$store.state.marketA.priceDynamicCounter"(v) {
      const absDynamic = Math.abs(v);
      if (absDynamic === window.snackAlertN)
        this.addSnackMessage("A", v, absDynamic);
    },

    "$store.state.ticks": {
      deep: true,
      handler: function (newVal, oldVal) {
        const v = this.nTransactions();
        if (this.awardTrades.includes(v)) {
          if (this.$isHedonic) {
            this.$confetti.start({ defaultType: "heart" });
            this.pause();
            this.giveAward();
            this.awardShow();
            const that = this;
            setTimeout(function () {
              that.$confetti.stop();
              that.awardHide();
              that.unpause();
            }, 3000);
          }
        }
      },
    },
  },
  methods: {
    ...mapActions(["giveAward", "nextTick"]),
    ...mapMutations({
      awardShow: "AWARD_SHOW",
      awardHide: "AWARD_HIDE",
      pause: "PAUSE",
      unpause: "UNPAUSE",
      addSnackMessageToStore: "ADD_SNACK_MESSAGE",
      removeSnackMessage: "REMOVE_SNACK_MESSAGE",
    }),
    addSnackMessage(marketName, v, absV) {
      const direction = v > 0 ? "up" : "down";
      const directionColor = v > 0 ? "green" : "red";
      const msg = `Alert: Stock price went ${direction} ${absV} times in a row`;

      this.addSnackMessageToStore({
        message: msg,
        color: directionColor,
        bottom: true,
        absolute: true,
      });
      const that = this;
      setTimeout(() => that.removeSnackMessage(), 5000);
    },
  },
};
</script>
