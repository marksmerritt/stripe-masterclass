// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// document.addEventListener("turbo:load", () => {
//   const form = document.querySelector("#payment-form")

//   if (form == null) { return }

//   const public_key = document.querySelector("meta[name='stripe-key']").getAttribute("content")
//   const stripe = Stripe(public_key)

//   const elements = stripe.elements()
//   const card = elements.create("card")
//   card.mount("#card-element")

//   card.addEventListener("change", (event) => {
//     let displayError = document.getElementById("card-errors")
//     if (event.error) {
//       displayError.textContent = event.error.message
//     } else {
//       displayError.textContent = ""
//     }
//   })

//   form.addEventListener("submit", (event) => {
//     event.preventDefault()

//     let data = {
//       payment_method: {
//         card: card,
//         billing_details: {
//           name: form.querySelector("#name_on_card").value
//         }
//       }
//     }

//     stripe.confirmCardPayment(form.dataset.paymentIntentId, data).then((result) => {
//       if (result.error) {
//         let errorElement = document.getElementById("card-errors")
//         errorElement.textContent = result.error.message
//       } else {
//         form.submit()
//       }
//     })
//   })
// })

document.addEventListener("turbo:load", () => {
  let cardElement = document.querySelector("#card-element")

  if (cardElement !== null) { setupStripe() }

  let newCard = document.querySelector("#use-new-card")
  if (newCard !== null) {
    newCard.addEventListener("click", (event) => {
      event.preventDefault()
      document.querySelector("#payment-form").classList.remove("d-none")
      document.querySelector("#existing-card").classList.add("d-none")
    })
  }
})

function setupStripe() {
  const stripe_key = document.querySelector("meta[name='stripe-key']").getAttribute("content")
  const stripe = Stripe(stripe_key)

  const elements = stripe.elements()
  const card = elements.create("card")
  card.mount("#card-element")

  let displayError = document.getElementById("card-errors")

  card.addEventListener("change", event => {
    if (event.error) {
      displayError.textContent = event.error.message
    } else {
      displayError.textContent = ""
    }
  })

  const form = document.querySelector("#payment-form")
  let paymentIntentId = form.dataset.paymentIntent
  let setupIntentId = form.dataset.setupIntent

  if (paymentIntentId) {
    if (form.dataset.status == "requires_action") {
      stripe.confirmCardPayment(paymentIntentId, { setup_future_usage: "off_session" }).then((result) => {
        // If error, the intent status will change from requires action to requires_payment_method so we need their card info again

        if (result.error) {
          displayError.textContent = result.error.message
          form.querySelector("#card-details").classList.remove("d-none")
        } else {
          form.submit()
        }
      })
    }
  }

  form.addEventListener("submit", (event) => {
    event.preventDefault()

    let name = form.querySelector("#name_on_card").value

    let data = {
      payment_method_data: {
        card: card,
        billing_details: {
          name: name,
        }
      }
    }

    // Complete a payment intent
    if (paymentIntentId) {
      stripe.confirmCardPayment(paymentIntentId, {
        payment_method: data.payment_method_data,
        setup_future_usage: "off_session",
        save_payment_method: true
      }).then((result) => {
        if (result.error) {
          displayError.textContent = result.error.message
          form.querySelector("#card-details").classList.remove("d-none")
        } else {
          form.submit()
        }
      })

    // Update a card or subscribe with trial (using a Setup Intent)
    } else if (setupIntentId) {
      stripe.confirmCardSetup(setupIntentId, {
        payment_method: data.payment_method_data
      }).then((result) => {
        if (result.error) {
          displayError.textContent = result.error.message
        } else {
          addHiddenField(form, "payment_method_id", result.setupIntent.payment_method)
          form.submit()
        }
      })

    } else {
      // Subscribe with no trial
      data.payment_method_data.type = "card"
      stripe.createPaymentMethod(data.payment_method_data).then((result) => {
        if (result.error) {
          displayError.textContent = result.error.message
        } else {
          addHiddenField(form, "payment_method_id", result.paymentMethod.id)
          form.submit()
        }
      })
    }
  })
}

function addHiddenField(form, name, value) {
  let hiddenInput = document.createElement("input")
  hiddenInput.setAttribute("type", "hidden")
  hiddenInput.setAttribute("name", name)
  hiddenInput.setAttribute("value", value)
  form.appendChild(hiddenInput)
}
