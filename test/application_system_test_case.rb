require "test_helper"

Capybara.default_max_wait_time = 10

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  include Warden::Test::Helpers

  def fill_stripe_elements(card: "4242 4242 4242 4242", expiry: "1234", cvc: "123", postal: "12345", selector: "#card-element > div > iframe")
    find_frame(selector) do
      card.to_s.chars.each do |piece|
        find_field("cardnumber").send_keys(piece)
      end

      find_field("exp-date").send_keys expiry
      find_field("cvc").send_keys cvc
      find_field("postal").send_keys postal
    end
  end

  def complete_stripe_sca
    find_frame("body > div > iframe") do
      sleep 1
      find_frame("#challengeFrame") do
        find("#test-source-authorize-3ds").click
      end
    end
  end

  def fail_stripe_sca
    find_frame("body > div > iframe") do
      sleep 1
      find_frame("#challengeFrame") do
        find("#test-source-fail-3ds").click
      end
    end
  end

  def find_frame(selector, &block)
    using_wait_time(15) do
      frame = find(selector)
      within_frame(frame) do
        block.call
      end
    end
  end
end
