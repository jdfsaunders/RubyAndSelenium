require 'test/unit'
require 'selenium-webdriver'
require 'faker'

class SampleTest < Test::Unit::TestCase

  def setup
    @form_url =
        'https://docs.google.com/forms/d/181whJlBduFo5qtDbxkBDWHjNQML5RutvHWOCjEFWswY/viewform'
    @form_submission_confirmation_url =
        'https://docs.google.com/forms/d/181whJlBduFo5qtDbxkBDWHjNQML5RutvHWOCjEFWswY/formResponse'

    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to @form_url
    @name_field = @driver.find_element(:id, 'entry_1041466219')
    @enjoy_development_yes_option = @driver.find_element(:id, 'group_310473641_1')
    @framework_selection = Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, 'entry_262759813'))
    @comments_entry = @driver.find_element(:id, 'entry_649813199')
    @submit_button = @driver.find_element(:id, 'ss-submit')
  end

  def teardown
    @driver.quit
  end

  # Verify that a form can be submitted when all fields are completed by
  # confirming that the user is brought to the next screen, the response
  # message is displayed, and the message is as expected.
  # Data recording is also partially verified by checking that the name and
  # comment left by the user are present on the results page.  This may make
  # more sense as a separate test case. Due to being unable to clear existing
  # data, the development enjoyment question and favourite framework results
  # are not checked.
  def test_form_submission_and_recording
    name_entered = Faker::Name.name
    @name_field.send_keys name_entered
    @enjoy_development_yes_option.click
    @framework_selection.select_by(:text, 'Cucumber')

    comment_entered = Faker::Lorem.paragraph
    @comments_entry.send_keys comment_entered
    @submit_button.click

    assert_equal(@driver.current_url, @form_submission_confirmation_url,
                'The form failed to submit')

    response_message = @driver.find_element(:class, 'ss-resp-message')
    assert_true(response_message.displayed?,
                'Form submission confirmation message is not displayed')
    assert_equal(response_message.text, 'Your response has been recorded.',
                'Form submission confirmation screen does not have expected user message')

    result_url = @driver.find_element(:link_text, 'See previous responses')
                     .attribute('href')
    @driver.navigate.to result_url

    assert_true(@driver.page_source.include?(name_entered),
                'The name of the submitter,' + name_entered + ' was not saved')
    assert_true(@driver.page_source.include?(comment_entered),
                "The submitter's comment was not saved")
  end

  # Verify that "Do you enjoy development?" question is required by confirming
  # that the user is not brought to the next screen and that the error
  # notification is displayed on the entry group.
  def test_development_enjoyment_is_required
    @name_field.send_keys Faker::Name.name
    @comments_entry.send_keys Faker::Lorem.paragraphs
    @framework_selection.select_by(:text, 'JUnit')
    @submit_button.click

    assert_equal(@driver.current_url, @form_url,
                 "The next page loaded when a required field was not entered")

    container_div = @enjoy_development_yes_option
                        .find_element(:xpath,
                                      'ancestor::div[@class="ss-form-entry"]')
    required_message = container_div.find_element(:class, 'required-message')
    assert_true(required_message.displayed?, "Error message not displayed")
  end
end