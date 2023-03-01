require "application_system_test_case"

class StripeTest < ApplicationSystemTestCase
  setup do
    VCR.eject_cassette
    @user = users(:one)
    login_as @user, scope: :user
    @plan = plans(:small_monthly)
  end

  test "creating a subscription" do
    visit new_subscription_path(plan_id: @plan.id)
    fill_stripe_elements
    fill_in "name_on_card", with: "#{@user.first_name} #{@user.last_name}"
    click_on "Subscribe"
    assert_selector "div", text: "Thanks for subscribing"
    assert @user.subscribed?
  end

  test "failing to create a subscription with authentication" do
    visit new_subscription_path(plan_id: @plan.id)
    fill_stripe_elements card: "4000002760003184"
    fill_in "name_on_card", with: "#{@user.first_name} #{@user.last_name}"
    click_on "Subscribe"
    assert_selector "h1", text: "Confirm your $25.00 payment"
    fail_stripe_sca
    assert_selector "div", text: "We are unable to authenticate your payment"
  end
end
