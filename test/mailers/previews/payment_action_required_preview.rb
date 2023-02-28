class PaymentActionRequiredPreview < ActionMailer::Preview
  def payment_action_required
    user = User.new(email: "test@example.com", first_name: "Mark", last_name: "Smith")
    subscription = Subscription.new
    payment_intent = Stripe::PaymentIntent.retrieve("pi_3MgW8cAd1SFRKFWW0Z3Hd9UM")

    UserMailer.payment_action_required(user, payment_intent, subscription)
  end
end
