const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');

Given('I open the Example Domain page', async function () {
  await this.driver.url('https://example.com/');
});

Then('the page title should be {string}', async function (expectedTitle) {
  const title = await this.driver.getTitle();
  assert.strictEqual(title, expectedTitle, `Expected title "${expectedTitle}", got "${title}"`);
});

Then('the main heading should be {string}', async function (expectedHeading) {
  const h1 = await this.driver.$('h1');
  const text = await h1.getText();
  assert.strictEqual(text, expectedHeading, `Expected H1 "${expectedHeading}", got "${text}"`);
});

When('I follow the {string} link', async function (linkText) {
  // busca el enlace por el texto visible en la página
  const link = await this.driver.$(`a=${linkText}`);
  await link.waitForExist({ timeout: 5000 });
  await link.click();
});

Then('the current URL should contain {string}', async function (substring) {
  const url = await this.driver.getUrl();
  assert.ok(url.includes(substring), `Expected URL to contain "${substring}", got "${url}"`);
});
