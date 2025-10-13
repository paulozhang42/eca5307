import Vue from "vue";
import App from "./App.vue";
import vuetify from "./plugins/vuetify";
import Highcharts from "highcharts";
import Stock from "highcharts/modules/stock";
import HighchartsVue from "highcharts-vue";
import VueNativeSock from "vue-native-websocket";

import "animate.css";

import VueParticlesBg from "particles-bg-vue";
Vue.prototype.$gamified = window.gamified;
Vue.prototype.$isHedonic = window.gamified && window.hedonic;
Vue.prototype.$areNotifications = window.gamified && window.notifications;
Vue.use(VueParticlesBg);
import vueAwesomeCountdown from "vue-awesome-countdown";
Vue.use(vueAwesomeCountdown, "vac");
import VueConfetti from "vue-confetti";
Vue.use(VueConfetti);

import "vue-slider-component/theme/default.css";
import "vuetify/dist/vuetify.min.css";

import store from "./store";
Stock(Highcharts);
Vue.use(HighchartsVue);
Vue.config.productionTip = false;

const ws_scheme = window.location.protocol === "https:" ? "wss" : "ws";
const ws_path = ws_scheme + "://" + window.location.host + window.socket_path;
console.debug("WASPATH", ws_path);
Vue.use(VueNativeSock, ws_path, {
  store: store,
  format: "json",
  reconnection: true,
  reconnectionAttempts: 5,
  reconnectionDelay: 3000,
});

new Vue({
  vuetify,
  store,
  render: (h) => h(App),
}).$mount("#app");
