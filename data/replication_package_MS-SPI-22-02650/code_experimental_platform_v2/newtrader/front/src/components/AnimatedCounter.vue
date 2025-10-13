<template><span class="tweened-number">{{ tweenedPrice }}</span></template>
  
<script>
import gsap from 'gsap';

export default {
    props: {
        // The value that we'll be tweening to.
        value: {
            type: Number,
            required: true
        },

        // How long the tween should take. (In milliseconds.)
        tweenDuration: {
            type: Number,
            default: 500
        }
    },

    watch: {
        // Whenever `props.value` changes, update the tween.
        value(newVal, oldVal) {
            const that = this
            gsap.to(this, {
                duration: this.tweenDuration/1000, tweenedPrice: Number(newVal) || 0,
                onUpdate: function () {
                    that.tweenedPrice = that.tweenedPrice.toFixed(0)
                }
            })
        }
    },

    // This holds the temporary state of the tweened value.
    data() {
        return {
            tweenedPrice: 0
        }
    },

    mounted() {
        this.tweenedPrice=this.value
    },

    methods: {
        // This is our main logic block. It handles tweening from a start value to an end value.
        
    }
}
</script>