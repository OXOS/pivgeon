module Pivgeon
  module Notification

    def self.included(base)
      base.extend(NotificationClassMethods)
    end

    module NotificationClassMethods
      # This add method send_notification that according to the mode either sends one or two 
      # email notifications (only to object creator or to object creator and to owner)
      def add_notifier(mailer_class,mode={:on_create=>false,:on_error=>false})
          (class << self; self; end).send(:define_method,"send_notification") do |obj,error_message|
            mail_methods = if( error_message or ( obj.respond_to?(:errors) and !obj.errors.blank? ) )
              methods = ["not_created_for_creator"]
              methods << "not_created_for_owner" if mode[:on_error]
              methods
            else
              methods = ["created_for_creator"]
              methods << "created_for_owner" if mode[:on_create]
              methods
            end            
            mail_methods.each do |method_name|
              mailer_class.send(method_name,obj,error_message).deliver
            end
          end
      end
    end

  end
end