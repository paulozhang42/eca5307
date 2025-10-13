const awards = [
  {
    name: "bronze",

    lock: true,
    locked: require("@/assets/bronze_locked.png"),
    unlocked: require("@/assets/bronze.png"),
    header: "Congratulations! You've earned a bronze badge!",
    message: "Level up! Doing well 👍",
    gif: window.bronzeGifPath,
  },

  {
    name: "silver",

    lock: true,
    locked: require("@/assets/silver_locked.png"),
    unlocked: require("@/assets/silver.png"),
    header: "Congratulations! You've earned a silver badge!",
    message: "You belong on the trading floor! 📈",
    gif: window.silverGifPath,
  },
  {
    name: "gold",

    lock: true,
    locked: require("@/assets/gold_locked.png"),
    unlocked: require("@/assets/gold.png"),
    header: "Congratulations! You've earned a gold badge!",
    message: "You are the money maker! 💰",
    gif: window.goldGifPath,
  },

  {
    name: "platinum",

    lock: true,
    locked: require("@/assets/platinum_locked.png"),
    unlocked: require("@/assets/platinum.png"),
    header: "Congratulations! You've earned a platinum badge!",
    message: "You are definitely going places! 👐",
    gif: window.platinumGifPath,
  },
  {
    name: "diamond",

    lock: true,
    locked: require("@/assets/diamond_locked.png"),
    unlocked: require("@/assets/diamond.png"),
    header: "Congratulations! You've earned a diamond badge!",
    message: "The Wolf of Wall Street  ☝️",
    gif: window.diamondGifPath,
  },
];
export default awards;
