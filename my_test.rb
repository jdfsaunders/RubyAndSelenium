require 'test/unit'
require 'selenium-webdriver'
require 'faker'

class SampleTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to 'https://docs.google.com/forms/d/181whJlBduFo5qtDbxkBDWHjNQML5RutvHWOCjEFWswY/viewform'
    @name_field = @driver.find_element(:id, 'entry_1041466219')
    @yes_option = @driver.find_element(:id, 'group_310473641_1')
    @framework_selection = Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, 'entry_262759813'))
    @comments_entry = @driver.find_element(:id, 'entry_649813199')
    @submit_button = @driver.find_element(:id, 'ss-submit')
  end

  def teardown
    @driver.quit
  end

  # Test that a form can be submitted when all fields are filled out and that
  # the submitter's name & comment are recorded.
  def test_form_submission_and_recording
    name_entered = Faker::Name.name
    @name_field.send_keys name_entered
    @yes_option.click
    @framework_selection.select_by(:text, 'Cucumber')

    comment_entered = Faker::Lorem.paragraph
    @comments_entry.send_keys comment_entered
    @submit_button.click

    assert(@driver.page_source.include?('Your response has been recorded.'),
           'The Form failed to submit')

    result_url = @driver.find_element(:link_text, 'See previous responses')
                     .attribute('href')
    @driver.navigate.to result_url

    assert_true(@driver.page_source.include?(name_entered),
                'The name of the submitter,' + name_entered + ' was not saved')
    assert_true(@driver.page_source.include?(comment_entered),
                "The submitter's comment was not saved")
  end

  # Test that user is notified after submitting the form with neither option
  # selected for the developer preference question
  def test_development_preference_is_required
    @name_field.send_keys Faker::Name.name
    @comments_entry.send_keys Faker::Lorem.paragraphs
    @framework_selection.select_by(:text, 'JUnit')
    @submit_button.click

    container_div = @yes_option
                        .find_element(:xpath,
                                      'ancestor::div[@class="ss-form-entry"]')
    required_message = container_div.find_element(:class, 'required-message')
    assert_true(required_message.displayed?, "Error message not displayed")
  end
end