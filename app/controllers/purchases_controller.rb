class PurchasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product

  def show
    @payment_intent = Stripe::PaymentIntent.create(
      amount: @product.amount,
      currency: "usd",
    )
  end

  def create
    @payment_intent = Stripe::PaymentIntent.retrieve(id: params[:payment_intent_id], expand: ["latest_charge"])

    if @payment_intent.status == "succeeded"
      charge = @payment_intent.latest_charge
      card = charge.payment_method_details.card

      Order.create(
        stripe_id: charge.id,
        user: current_user,
        product: @product,
        card_brand: card.brand.titleize,
        card_last4: card.last4,
        card_exp_month: card.exp_month,
        card_exp_month: card.exp_year
      )

      redirect_to root_path, notice: "Your order has been submitted"
    else
      flash[:alert] = "Your order was unsuccessful. Please try again"
      render :show
    end
  end


  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end
