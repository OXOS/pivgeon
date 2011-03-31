module ApplicationHelper
  
  def display_all_error_messages(object,method)
    list_items = object.errors[method].map { |msg| content_tag(:li, msg) }
    list_items.join().html_safe()
  end

  
end
