class SendgridMessage
  require 'iconv'
  extend ActiveModel::Naming
  
  attr_accessor :from, :to, :cc, :subject, :body, :message_id  

  EMAIL_DETOKENIZE_REGEXP = /<(.*)>/


  def initialize(attrs)
    charsets = ActiveSupport::JSON.decode(attrs['charsets'])
    @from = detokenize(attrs['from'])
    @to = detokenize(attrs['to'])
    @cc = detokenize(attrs['cc'])
    @subject = decode(charsets['subject'], attrs['subject'])
    @body = decode(charsets['text'], attrs['text'])
    @message_id = get_message_id(attrs['headers'])
  end

  protected

  def decode(orig_charset,str)
    Iconv.conv('iso-8859-1',orig_charset,str)
  end

  def detokenize(str)
    result = str.match(EMAIL_DETOKENIZE_REGEXP)
    result ? result[1] : str
  end

  def get_message_id(headers)
    mail = Mail.new(headers)
    return mail['Message-ID'].to_s
  end

end
