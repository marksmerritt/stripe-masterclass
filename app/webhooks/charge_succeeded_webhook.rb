class ChargeSucceededWebhook
  def call(event)
    object = event.data.object
    user = User.find_by(stripe_id: object.customer)
    return if user.nil?
    return if user.charges.where(stripe_id: object.id).any?

    user.charges.create(
      stripe_id: object.id,
      amount: object.amount,
      card_brand: object.payment_method_details.card.brand.titleize,
      card_last4: object.payment_method_details.card.last4,
      card_exp_month: object.payment_method_details.card.exp_month,
      card_exp_year: object.payment_method_details.card.exp_year,
      created_at: Time.at(object.created)
    )
  end
end
