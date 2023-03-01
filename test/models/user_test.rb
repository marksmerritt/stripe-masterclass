require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "updates card" do
    @user.update_card("pm_card_visa")
    assert_equal "Visa", @user.card_brand
    assert_equal "4242", @user.card_last4
  end

  test "can subscribe without authentication" do
    @user.update_card("pm_card_visa")
    @user.subscribe("price_1MfpWoAd1SFRKFWWP7BuU2cA")
    assert_not_nil @user.subscription
    assert @user.subscribed?
  end

  test "is not subscribed when authentication is required" do
    @user.update_card("pm_card_authenticationRequired")
    assert_raises PaymentIncomplete do
      @user.subscribe("price_1MfpWoAd1SFRKFWWP7BuU2cA")
    end
    assert_equal "incomplete", Subscription.last.status
  end

  test "can subscribe with trial" do
    @user.update_card("pm_card_visa")
    @user.subscribe("price_1MfpWoAd1SFRKFWWP7BuU2cA", trial_period_days: 5)
    assert @user.subscribed?
    assert @user.subscription.on_trial?
  end
end
