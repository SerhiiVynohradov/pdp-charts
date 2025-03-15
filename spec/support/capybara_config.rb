Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  unless ENV['NOHEADLESS'] == 'true'
    options.add_argument('--headless=new')
  end
  options.add_argument('--profile-directory=Default')
  options.add_argument('--disable-infobars')
  options.add_argument('--no-sandbox')
  options.add_argument('--allow-file-access-from-files')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--no-zygote')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--disable-translate')
  options.add_argument('--blink-settings=imagesEnabled=false')
  options.add_argument('--disable-extensions')
  options.add_argument('--disable-web-security')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('==user-data-dir=/dev/shm/profiles')
  options.add_argument('--disable-site-isolation-trials') # Please do not remove, increase significantly stability in docker. Originally it's browser thread isolation, security thing.
  options.add_argument('--ignore-certificate-errors') # Please do not remove, fixes issues with turbo/file attachments in docker. It's ceritification validation, not needed in localhost.

  options.add_preference(
    :download,
    default_directory: CHROME_DOWNLOAD_DIR,
    prompt_for_download: false,
    directory_upgrade: true
  )

  options.add_preference(
    :browser,
    set_download_behavior: { behavior: 'allow' }
  )

  options.add_preference(
    :profile,
    default_content_settings: { 'multiple-automatic-downloads': 1 },
    default_content_setting_values: { automatic_downloads: 1 },
    password_manager_enabled: false,
    safebrowsing: {
      enabled: false,
      disable_download_protection: true
    },
    directory_upgrade: true
  )

  options.add_preference(
    :plugins,
    always_open_pdf_externally: true
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, clear_session_storage: true, clear_local_storage: true, options:)
end

Capybara.register_driver :selenium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless=new')

  Capybara::Selenium::Driver.new(app, browser: :chrome, clear_session_storage: true, clear_local_storage: true, options:)
end

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

# DO NOT UNCOMMENT OR INSERT. For some reason this causes test to run twice as slow.
#Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before(:each, :js, type: :feature) do
    Capybara.current_driver = :headless_chrome
  end
end
