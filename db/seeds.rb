Movie.create!(title: 'The Matrix', video_url: "secret")

Plan.create!(name: "Small", stripe_id: "price_1MfpWoAd1SFRKFWWP7BuU2cA", amount: 25_00, interval: "month")
Plan.create!(name: "Small", stripe_id: "price_1MfpWoAd1SFRKFWWCtBrrFPj", amount: 250_00, interval: "annual")
Plan.create!(name: "Large", stripe_id: "price_1MfpWoAd1SFRKFWWk9eF5nmb", amount: 100_00, interval: "month")
Plan.create!(name: "Large", stripe_id: "price_1MfpWoAd1SFRKFWWZmhFg0WM", amount: 1000_00, interval: "year")
