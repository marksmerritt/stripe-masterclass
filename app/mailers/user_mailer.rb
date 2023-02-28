class UserMailer < ApplicationMailer
  def payment_action_required(user, payment_intent, subscription)
    @user = user
    @payment_intent = payment_intent
    @subscription = subscription

    mail to: @user.email, subject: "Paymen confirmation required"
  end
end

