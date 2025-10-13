<template>
  <v-overlay :value="true" :dark="false" :opacity="0" z-index="10000">
    <div class="d-flex flex-column justify-center align-center">
      <v-card elevation="3" width="600">
        <v-card-title class="text-h5 mb-1 red white--text d-flex align-center justify-center text-center">
          {{awardGiven.header}}
        </v-card-title>
        <v-card-text>
          <v-img contain :src="awardGiven.gif" class="my-3"></v-img>
          <h3 class="text-center">{{ awardGiven.message }}</h3>
        </v-card-text>
      </v-card>
    </div>
  </v-overlay>
</template>

<script>
export default {
  props: ["awardGiven"],
  data() {
    return {};
  },
  mounted() {},
  methods: {},
};
</script>
