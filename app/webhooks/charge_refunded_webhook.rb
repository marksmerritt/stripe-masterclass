class ChargeRefundedWebhook
  def call(event)
    object = event.data.object
    user = User.find_by(stripe_id: object.customer)
    return if user.nil?

    charge = user.charges.find_by(stripe_id: object.id)
    return if charge.nil?

    charge.update(amount_refunded: object.amount_refunded)
  end
end
