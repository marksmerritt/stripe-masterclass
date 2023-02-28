class PaymentsController < ApplicationController
  before_action :set_payment_intent

  def show
  end

  def update
    redirect_to root_path, notice: "Thanks for your payment"
  end

  private

  def set_payment_intent
    @payment_intent = Stripe::PaymentIntent.retrieve(params[:id])
  end
end
