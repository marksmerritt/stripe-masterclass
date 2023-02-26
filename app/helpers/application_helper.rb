module ApplicationHelper
  def formatted_amount(amount)
    number_to_currency amount / 100.0
  end
end
