describe('Account Holder transfers cash', function () {
  beforeEach(function () {
    this.actionwords = Object.create(require('./actionwords.js').Actionwords);
  });

  it('Account has sufficient funds for transferring cash (uid:a8f1f78e-fba6-459c-b901-d80968d14f21)', function () {
    // Given the account balance is "$100"
    this.actionwords.theAccountBalanceIsBalance("$100");
    // And the savings account balance is "$1000"
    this.actionwords.theSavingsAccountBalanceIsAmount("$1000");
    // And the card is valid
    this.actionwords.theCardIsValid();
    // When the Account Holder transfers "$20" to the savings account
    this.actionwords.theAccountHolderTransfersAmountToTheSavingsAccount("$20");
    // And the ATM should dispense "$0"
    this.actionwords.theATMShouldDispenseAmount("$0");
    // And the account balance is "$80"
    this.actionwords.theAccountBalanceIsBalance("$80");
    // And the savings account balance should be "$1020"
    this.actionwords.theSavingsAccountBalanceShouldBeAmount("$1020");
    // And the card should be returned
    this.actionwords.theCardShouldBeReturned();
  });
});
