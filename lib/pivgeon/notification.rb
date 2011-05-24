module Pivgeon
  module Notification

    def self.included(base)
      base.extend(NotificationClassMethods)
    end

    module NotificationClassMethods
      def add_notifier(mailer_class,send_method_name)
          (class << self; self; end).send(:define_method,"send_notification") do |obj,error_message,reference_message_id|
            send_method = if( error_message or ( obj.respond_to?(:errors) and !obj.errors.blank? ) )
              "not_#{send_method_name}"
            else
              send_method_name
            end
            mailer_class.send(send_method,obj,error_message,reference_message_id).deliver
          end
      end
    end

  end
end