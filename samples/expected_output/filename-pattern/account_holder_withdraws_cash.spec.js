describe('Account Holder withdraws cash', function () {
  beforeEach(function () {
    this.actionwords = Object.create(require('./actionwords.js').Actionwords);
  });

  describe('Account has sufficient funds', function () {
    function accountHasSufficientFunds (amount, ending_balance) {
      // Given the account balance is "$100"
      this.actionwords.theAccountBalanceIsBalance("$100");
      // And the machine contains enough money
      this.actionwords.theMachineContainsEnoughMoney();
      // And the card is valid
      this.actionwords.theCardIsValid();
      // When the Account Holder requests "<amount>"
      this.actionwords.theAccountHolderRequestsAmount(String(amount));
      // Then the ATM should dispense "<amount>"
      this.actionwords.theATMShouldDispenseAmount(String(amount));
      // And the account balance should be "<ending_balance>"
      this.actionwords.theAccountBalanceShouldBeBalance(String(ending_balance));
      // And the card should be returned
      this.actionwords.theCardShouldBeReturned();
    }

    it('withdraw $100 (uid:f3c30b42-1994-4d32-ad61-f81eddc981aa)', function () {
      accountHasSufficientFunds.apply(this, ['$100', '$0']);
    });

    it('withdraw $50 (uid:4e53c154-f4ab-43be-9d78-f43551c0cebd)', function () {
      accountHasSufficientFunds.apply(this, ['$50', '$50']);
    });

    it('withdraw $20 (uid:538a01bc-6025-4a9b-a8df-fbe5ad2a32bb)', function () {
      accountHasSufficientFunds.apply(this, ['$20', '$80']);
    });
  });


  it('Account has insufficient funds (uid:5ca96bdf-e40a-4387-89f2-5fbfd2383b13)', function () {
    // Given the account balance is "$10"
    this.actionwords.theAccountBalanceIsBalance("$10");
    // And the card is valid
    this.actionwords.theCardIsValid();
    // And the machine contains enough money
    this.actionwords.theMachineContainsEnoughMoney();
    // When the Account Holder requests "$20"
    this.actionwords.theAccountHolderRequestsAmount("$20");
    // Then the ATM should not dispense any money
    this.actionwords.theATMShouldNotDispenseAnyMoney();
    // And the ATM should say there are insufficient funds
    this.actionwords.theATMShouldSayThereAreInsufficientFunds();
  });

  it('Card has been disabled (uid:f5c6c3d0-b4b3-44ea-89ff-ebb8117787e1)', function () {
    // Given the card is disabled
    this.actionwords.theCardIsDisabled();
    // When the Account Holder requests "$10"
    this.actionwords.theAccountHolderRequestsAmount("$10");
    // Then the ATM should retain the card
    this.actionwords.theATMShouldRetainTheCard();
    // And the ATM should say the card has been retained
    this.actionwords.theATMShouldSayTheCardHasBeenRetained();
  });
});
