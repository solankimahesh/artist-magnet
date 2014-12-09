def visit_home(locale = I18n.default_locale)
  visit "/"
end

# def select_from_chosen(item_text, options)
#   puts "ITEM: #{item_text}, OPTIONS: #{options}"
#   field = find_field(options[:from], visible: false)
#   option_value = page.evaluate_script("$(\"##{field[:id]} option:contains('#{item_text}')\").val()")
#   page.execute_script("value = ['#{option_value}']\; if ($('##{field[:id]}').val()) {$.merge(value, $('##{field[:id]}').val())}")
#   option_value = page.evaluate_script("value")
#   page.execute_script("$('##{field[:id]}').val(#{option_value})")
#   page.execute_script("$('##{field[:id]}').trigger('chosen:updated')")
# end


def select_from_chosen(item_text, options)
  # Source: https://gist.github.com/michael-harrison/4102026
  # =begin
  # Notes
  # =====
  # Labels: On the label you should put a "for" attribute if you're not using something like simple_form
  # This helps capybara to find your field
  # e.g. <label for="my_field_id">Some label</label>
  # =end

  field = options[:from]
  value = item_text


  field_name = options[:from]
  selected_value = item_text

  # Find the field
  field = find_field(field_name, visible: false)
  # Open the Chosen drop down
  page.execute_script(%Q!$("##{field[:id]}_chosen").mousedown()!)
  # Simulate text being typed
  typed_text = ""
  value.chars.each do |char|
    typed_text += char
  # Put a value in the search field
    page.execute_script(%Q!$("##{field[:id]}_chosen input").val("#{typed_text}")!)
  # Fire the search via a keyup
    page.execute_script(%Q!$("##{field[:id]}_chosen input").keyup()!)
  end

  # If you're using Ajax Chosen then wait for the Ajax callback
  sleep 1
  start_time = Time.now
  page.evaluate_script('jQuery.isReady&&jQuery.active==0').class.should_not eql(String) until page.evaluate_script('jQuery.isReady&&jQuery.active==0') or (start_time + 5.seconds) < Time.now do
    sleep 1
  end

  # Do the selection via firing a mouse up on the option
  page.execute_script(%Q!$("##{field[:id]}_chosen .chosen-results li:contains('#{value}')").mouseup()!)
end


