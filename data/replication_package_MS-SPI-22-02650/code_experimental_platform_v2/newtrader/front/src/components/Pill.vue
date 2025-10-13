<template>
  <v-sheet outlined class="m-0 rounded-lg">
    <v-list-item>
      <v-list-item-content>
        <h3>{{ label }} <span v-if="label">:</span></h3>
      </v-list-item-content>
      <v-list-item-action class="font-weight-bold">
        <h3>
          {{ prefix }}<slot>{{ value }}</slot>
          
        </h3>
      </v-list-item-action>
    </v-list-item>
</v-sheet>
</template>

<script>


export default {
  props: {
    value: {

      required: false
    },
    label:{
      type:String,
      required:false,
      default:''
    },
    prefix:{type:String,
      required:false,
      default:''}


  },
  
  data() {
    return {};
  },

  methods: {},
};
</script>
