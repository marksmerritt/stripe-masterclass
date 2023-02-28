module ApplicationHelper
  def formatted_amount(amount, **options)
    number_to_currency(amount.to_i / 100.0, options)
  end
end
