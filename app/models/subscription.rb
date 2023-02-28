class Subscription < ApplicationRecord
  belongs_to :user

  def active?
    ["trialing", "active"].include?(status) && (ends_at.nil? || on_grace_period? || on_trial?)
  end

  def on_grace_period?
    canceled? && Time.zone.now < ends_at
  end

  def on_trial?
    trial_ends_at? && Time.zone.now < trial_ends_at
  end

  def canceled?
    ends_at?
  end

  def has_incomplete_payment?
    ["past_due", "incomplete"].include?(status)
  end

  def swap(plan)
    stripe_sub = stripe_subscription

    args = {
      cancel_at_period_end: false,
      items: [
        {
          id: stripe_sub.items.data[0].id,
          plan: plan,
        }
      ]
    }

    subscription = Stripe::Subscription.update(stripe_id, args)
    update(stripe_plan: plan, ends_at: nil)
  end

  def cancel
    sub = Stripe::Subscription.update(stripe_id, { cancel_at_period_end: true })
    update(status: "canceled", ends_at: Time.at(sub.cancel_at))
  end

  def cancel_now!
    sub = Stripe::Subscription.cancel(stripe_id)
    update(status: "canceled", ends_at: Time.at(sub.ended_at))
  end

  def resume
    if Time.current < ends_at
      Stripe::Subscription.update(stripe_id, cancel_at_period_end: false)
      update(status: "active", ends_at: nil)
    else
      raise StandardError, "You cannot resume a subscription that has already been canceled"
    end
  end

  def stripe_subscription
    Stripe::Subscription.retrieve(stripe_id)
  end
end
