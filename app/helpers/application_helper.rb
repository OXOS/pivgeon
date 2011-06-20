module ApplicationHelper
  
  def display_all_error_messages(object,method)
    Rails.logger.info "@@@@@@@@@@@ #{object.inspect}"
    errors = ( method == :all ? object.errors.full_messages : object.errors[method])
    Rails.logger.info "@@@@@@@@@@@ #{errors.inspect}"
    list_items = errors.map{|msg| content_tag(:li, msg) }
    Rails.logger.info "@@@@@@@@@ end"
    list_items.join().html_safe()
  end

  
end
