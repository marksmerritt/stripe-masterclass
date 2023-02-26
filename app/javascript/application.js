// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
  const form = document.querySelector("#payment-form")

  if (form == null) { return }

  const public_key = document.querySelector("meta[name='stripe-key']").getAttribute("content")
  const stripe = Stripe(public_key)

  const elements = stripe.elements()
  const card = elements.create("card")
  card.mount("#card-element")

  card.addEventListener("change", (event) => {
    let displayError = document.getElementById("card-errors")
    if (event.error) {
      displayError.textContent = event.error.message
    } else {
      displayError.textContent = ""
    }
  })

  form.addEventListener("submit", (event) => {
    event.preventDefault()

    let data = {
      payment_method: {
        card: card,
        billing_details: {
          name: form.querySelector("#name_on_card").value
        }
      }
    }

    stripe.confirmCardPayment(form.dataset.paymentIntentId, data).then((result) => {
      if (result.error) {
        let errorElement = document.getElementById("card-errors")
        errorElement.textContent = result.error.message
      } else {
        form.submit()
      }
    })
  })
})
