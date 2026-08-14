# frozen_string_literal: true

When('I log in with Google') do
  click_button('Google Login')
end

Then('I click {string}') do |string|
  click_link(string)
end
