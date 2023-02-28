class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plan, only: [:new, :create, :update]

  def show
    @subscription = current_user.subscription
  end

  def new
  end

  def create
    current_user.update_card(params[:payment_method_id]) if params[:payment_method_id]
    current_user.subscribe(@plan.stripe_id)

    redirect_to root_path, notice: "Thanks for subscribing"
  rescue PaymentIncomplete => e
    redirect_to payment_path(e.payment_intent.id)
  end

  def edit
    @subscription = current_user.subscription
    @plans = Plan.all
  end

  def update
    @subscription = current_user.subscription
    @subscription.swap(@plan.stripe_id)
    redirect_to subscription_path, notice: "You have successfully changed plans"
  end

  def destroy
    current_user.subscription.cancel
    redirect_to subscription_path, notice: "Your subscription has been canceled"
  end

  def resume
    current_user.subscription.resume
    redirect_to subscription_path, notice: "Your subscription has been resumed"
  end


  private

  def set_plan
    @plan = Plan.find_by(id: params[:plan_id])
    redirect_to pricing_path if @plan.nil?
  end
end
