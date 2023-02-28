require "charge_succeeded_webhook"
require "charge_refunded_webhook"
require "subscription_updated_webhook"
require "subscription_deleted_webhook"
require "payment_action_required_webhook"

Stripe.api_key = Rails.application.credentials.stripe[:private_key]

class PaymentIncomplete < StandardError
  attr_reader :payment_intent

  def initialize(payment_intent)
    @payment_intent = payment_intent
  end
end

StripeEvent.signing_secret = ENV["STRIPE_SIGNING_SECRET"] || Rails.application.credentials.stripe[:signing_secret]
StripeEvent.configure do |events|
  events.subscribe "charge.succeeded", ChargeSucceededWebhook.new
  events.subscribe "charge.refunded", ChargeRefundedWebhook.new
  events.subscribe "customer.subscription.updated", SubscriptionUpdatedWebhook.new
  events.subscribe "customer.subscription.deleted", SubscriptionDeletedWebhook.new
  events.subscribe "invoice.payment_action_required", PaymentActionRequiredWebhook.new
end
