<template>
  <div v-if="true">
    <v-overlay z-index="5" :value="true" v-if="$store.getters.showPredictionDlg()">
    </v-overlay>
    <transition appear enter-active-class="animate__animated animate__slideInUp animate__slow"
      leave-active-class="animate__animated animate__slideOutDown animate__slow">

      <v-bottom-navigation app height="300" z-index="6" style="z-index: 6" v-if="$store.getters.showPredictionDlg()">
        <v-row>
          <v-col cols="10">
            <v-sheet outlined class="p-3 m-3 d-flex flex-column justify-space-around" rounded elevation="3" full-height
              height="280">
              <div>
                <h6 class="" v-if="counter===0">How likely is the stock to go up in the first period?</h6>
                <h6 class="" v-else>How likely is the stock to go up next?</h6>
                <div style="margin-left: 50px; margin-right: 50px">
                  <vue-slider :min="1" :max="5" :marks="marks1" :tooltip="'always'" :tooltip-placement="'bottom'"
                    v-model="stockUpA" @change="setClicker(0)" :tooltip-formatter="formatter1">
                  </vue-slider>
                </div>
              </div>
              <div>
                <h6 class="">How confident are you in the assessment?</h6>
                <div style="margin-left: 50px; margin-right: 50px">
                  <vue-slider :min="1" :max="5" :marks="marks2" :tooltip="'always'" :tooltip-placement="'bottom'"
                    v-model="confidenceA" @change="setClicker(1)" :tooltip-formatter="formatter2">
                  </vue-slider>
                </div>
              </div>
            </v-sheet>
          </v-col>

          <v-col cols="2">
            <v-sheet outlined class="p-3 m-3 d-flex flex-column justify-center align-center" rounded height="280"
              elevation="3">
              <v-btn large color="primary" id="submitbtn" @click="closeDialog" v-if="allClicked">
                Submit
              </v-btn>
              <v-alert type="info" v-else>Please make your predictions. You need to move the slides before submitting.
              </v-alert>
            </v-sheet>
          </v-col>
        </v-row>
      </v-bottom-navigation>
    </transition>
  </div>
</template>

<script>
import _ from "lodash";
import { mapState, mapActions, mapMutations } from "vuex";
import VueSlider from "vue-slider-component";
import "vue-slider-component/theme/default.css";
export default {
  components: {
    VueSlider,
  },
  data() {
    return {
      marks1: {
        1: "Very unlikely (1)",
        2: "Unlikely (2)",
        3: "Neither likely nor unlikely",
        4: "Likely (4)",
        5: "Very likely (5)",
      },
      marks2: {
        1: "Very unconfident  (1)",
        2: "2",
        3: "3",
        4: "4",
        5: "Very confident (5)",
      },
      tooltips2: {
        1: "Very unconfident  (1)",
        2: "Somewhat unconfident (2)",
        3: "Neither confident nor unconfident (3)",
        4: "Somewhat confident (4)",
        5: "Very confident (5)",
      },
      clickers: [0, 0],
      dialog: true,
      stockUpA: 3,
      confidenceA: 1,

    };
  },
  mounted() {
    this.PAUSE();
  },
  computed: {
    ...mapState(['counter']),
    allClicked() {
      return _.every(this.clickers, (e) => e === 1);
    },
  },
  methods: {
    formatter1(v) {
      return this.marks1[v];
    },
    formatter2(v) {
      return this.tooltips2[v];
    },
    setClicker(id) {
      this.clickers.splice(id, 1, 1);
    },
    ...mapActions(["nextTick", "sendMessage"]),
    ...mapMutations(["PAUSE"]),
    async closeDialog() {
      const { stockUpA, confidenceA } = this;
      await this.sendMessage({
        name: "PREDICTIONS_SENT",
        action: "predictions_send",
        stockUpA,
        confidenceA,

      });
      this.clickers = [0, 0],
      this.stockUpA =3,
      this.confidenceA = 1,
      this.dialog = false;
      this.nextTick();
    },
  },
};
</script>
<style lang="scss" scoped>
#submitbtn {
  -webkit-text-size-adjust: 100%;
  word-break: normal;
  tab-size: 4;
  -webkit-font-smoothing: antialiased;
  -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
  --blue: #007bff;
  --indigo: #6610f2;
  --purple: #6f42c1;
  --pink: #e83e8c;
  --red: #dc3545;
  --orange: #fd7e14;
  --yellow: #ffc107;
  --green: #28a745;
  --teal: #20c997;
  --cyan: #17a2b8;
  --white: #fff;
  --gray: #6c757d;
  --gray-dark: #343a40;
  --primary: #007bff;
  --secondary: #6c757d;
  --success: #28a745;
  --info: #17a2b8;
  --warning: #ffc107;
  --danger: #dc3545;
  --light: #f8f9fa;
  --dark: #343a40;
  --breakpoint-xs: 0;
  --breakpoint-sm: 576px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 992px;
  --breakpoint-xl: 1200px;
  --font-family-sans-serif: -apple-system, BlinkMacSystemFont, "Segoe UI",
    Roboto, "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji",
    "Segoe UI Emoji", "Segoe UI Symbol";
  --font-family-monospace: SFMono-Regular, Menlo, Monaco, Consolas,
    "Liberation Mono", "Courier New", monospace;
  --animate-duration: 1s;
  --animate-delay: 1s;
  --animate-repeat: 1;
  word-wrap: break-word;
  background-repeat: no-repeat;
  box-sizing: inherit;
  margin: 0;
  font: inherit;
  overflow: visible;
  border-style: none;
  cursor: pointer;
  align-items: center;
  border-radius: 4px;
  display: inline-flex;
  flex: 0 0 auto;
  font-weight: 500;
  letter-spacing: 0.0892857143em;
  justify-content: center;
  outline: 0;
  position: relative;
  text-decoration: none;
  text-indent: 0.0892857143em;
  text-transform: uppercase;
  transition-duration: 0.28s;
  transition-property: box-shadow, transform, opacity;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  user-select: none;
  vertical-align: middle;
  white-space: nowrap;
  box-shadow: 0 3px 1px -2px rgba(0, 0, 0, 0.2), 0 2px 2px 0 rgba(0, 0, 0, 0.14),
    0 1px 5px 0 rgba(0, 0, 0, 0.12);
  -webkit-appearance: button;
  color: #fff !important;
  caret-color: #fff !important;
  background-color: #4c4faf !important;
  border-color: #4caf50 !important;
  margin-right: 4px !important;
  margin-left: 4px !important;
  font-size: 1rem;
  height: 50px;
  min-width: 50px;
  padding: 0 12.4444444444px;
}
</style>
