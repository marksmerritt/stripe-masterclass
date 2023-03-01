# If you ever need to use webhooks for customer statuses not being correct you can call directly after looking up the event
# ie ChargeSucceededWebhook.new.call(event)

require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.update_card("pm_card_visa")
    @subscription = @user.subscribe("price_1MfpWoAd1SFRKFWWP7BuU2cA")
  end

  test "swapping plan" do
    @subscription.swap("price_1MfpWoAd1SFRKFWWk9eF5nmb")
    assert_equal "price_1MfpWoAd1SFRKFWWk9eF5nmb", @subscription.stripe_plan
  end

  test "can cancel subscription" do
    @subscription.cancel
    assert @subscription.canceled?
    assert @subscription.on_grace_period?
  end

  test "can cancel subscription immediatley" do
    @subscription.cancel
    assert @subscription.canceled?
    assert_not @subscription.on_grace_period?
  end

  test "can resume subscription" do
    @subscription.cancel
    @subscription.resume
    assert_not @subscription.canceled?
    assert @subscription.active?
  end

  test "cannot resume subscription that's outside the grace period" do
    @subscription.cancel_now!
    assert_raises StandardError do
      @subscription.resume
    end
  end
end
