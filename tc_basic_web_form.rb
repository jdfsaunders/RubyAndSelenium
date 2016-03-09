require 'test/unit'
require 'selenium-webdriver'
require 'faker'

class TestBasicWebForm < Test::Unit::TestCase

  FORM_URL =
      'https://docs.google.com/forms/d/181whJlBduFo5qtDbxkBDWHjNQML5RutvHWOCjEFWswY/viewform'
  FORM_RESPONSE_URL =
      'https://docs.google.com/forms/d/181whJlBduFo5qtDbxkBDWHjNQML5RutvHWOCjEFWswY/formResponse'

  def setup
    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to FORM_URL
    @name_field = @driver.find_element(:id, 'entry_1041466219')
    @enjoy_development_yes_option = @driver.find_element(:id, 'group_310473641_1')
    @framework_selection = Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, 'entry_262759813'))
    @comments_field = @driver.find_element(:id, 'entry_649813199')
    @submit_button = @driver.find_element(:id, 'ss-submit')
  end

  def teardown
    @driver.quit
  end

  # Verify that a form can be submitted when all fields are completed by
  # confirming that:
  # 1) the user is brought to the next screen
  # 2) the response message is displayed
  # 3) the message is as expected.
  def test_form_submission_all_fields_filled
    @name_field.send_keys Faker::Name.name
    @enjoy_development_yes_option.click
    @framework_selection.select_by(:text, 'Cucumber')
    @comments_field.send_keys Faker::Lorem.paragraphs
    @submit_button.click

    assert_equal(FORM_RESPONSE_URL, @driver.current_url,
                 'The form failed to submit')

    response_message = @driver.find_element(:class, 'ss-resp-message')
    assert_true(response_message.displayed?,
                'Form submission confirmation message is not displayed')

    assert_equal('Your response has been recorded.',
                 response_message.text,
                'Form submission confirmation screen does not have expected user message')
  end

  # Verify that 'Do you enjoy development?' question is required by confirming
  # that:
  # 1) the user remains on the form
  # 2) the error notification is displayed on the entry group.
  def test_development_enjoyment_is_required
    @name_field.send_keys Faker::Name.name
    @comments_field.send_keys Faker::Lorem.paragraphs
    @framework_selection.select_by(:text, 'JUnit')
    @submit_button.click

    assert_equal(FORM_URL,
                 @driver.current_url,
                 'The next page loaded when a required field was not entered')

    container_div = @enjoy_development_yes_option
                        .find_element(:xpath,
                                      'ancestor::div[@class="ss-form-entry"]')

    required_message = container_div.find_element(:class, 'required-message')

    assert_true(required_message.displayed?, 'Error message not displayed')
  end
end