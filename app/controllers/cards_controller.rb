class CardsController < ApplicationController
  before_action :authenticate_user!

  def edit
    # Setup intents are for cards that are going to be charged in the future
    @setup_intent = current_user.create_setup_intent
  end

  def update
    current_user.update_card(params[:payment_method_id])
    redirect_to edit_card_path, notice: "Your card was successfully updated."
  rescue Stripe::StripeError => e
    redirect_to edit_card_path, alert: "Our payment processor returned the following error: #{e.message}"
  end
end
