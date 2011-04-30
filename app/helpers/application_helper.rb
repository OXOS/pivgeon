module ApplicationHelper
  
  def display_all_error_messages(object,method)
    errors = ( method == :all ? object.errors.full_messages : object.errors[method])
    list_items = errors.map{|msg| content_tag(:li, msg) }
    list_items.join().html_safe()
  end

  
end
