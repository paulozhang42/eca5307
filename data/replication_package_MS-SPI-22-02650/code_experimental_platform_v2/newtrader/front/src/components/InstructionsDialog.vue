<template>
  <div class="text-center">
    <v-dialog  v-model="dialog" width="800">
       <template v-slot:activator="{ on, attrs }">
        <v-btn
          color="green white--text"
          
          v-bind="attrs"
          v-on="on"
          class='mx-1'
        >
          Instructions
        </v-btn>
      </template>
      <v-card>
        <v-card-title class="text-h5 grey lighten-2"> Instructions </v-card-title>

        <v-card-text v-html="instructions" class="text-left">
           
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
            text
           
         @click="closeDialog"
          >
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>

export default {
  data() {
    return {
      dialog: false,
      instructions:document.getElementById('instructions').innerHTML
    };
  },
   
  methods: {
    closeDialog() {
      
      this.dialog = false;
    },
   
  },
};
</script>