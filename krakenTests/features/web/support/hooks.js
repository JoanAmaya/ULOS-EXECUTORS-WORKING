const { After, Before } = require("@cucumber/cucumber");
const { WebClient } = require("kraken-node");

Before(async function () {
  const chromeOptions = {
    "goog:chromeOptions": {
      args: [
        "--headless=new",
        "--no-sandbox",
        "--disable-dev-shm-usage",
        "--disable-gpu",
        "--disable-software-rasterizer",
        "--window-size=1200,900",
        "--remote-allow-origins=*",
      ],
    },
  };

  // AQUÍ pon las opciones
  this.deviceClient = new WebClient("chrome", chromeOptions, this.userId);
  this.driver = await this.deviceClient.startKrakenForUserId(this.userId);
});

After(async function () {
  await this.deviceClient.stopKrakenForUserId(this.userId);
});
