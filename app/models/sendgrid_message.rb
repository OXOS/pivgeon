class SendgridMessage
  require 'iconv'
  extend ActiveModel::Naming
  
  attr_accessor :from, :to, :cc, :subject, :body, :message_id  

  EMAIL_DETOKENIZE_REGEXP = /<(.*)>/


  def initialize(attrs)
    charsets = ActiveSupport::JSON.decode(attrs['charsets'])
    @from = detokenize(attrs['from'])
    @to = detokenize(attrs['to'])
    @cc = (attrs['cc'])
    @subject = decode(charsets['subject'], attrs['subject'])
    @body = decode(charsets['text'], attrs['text'])
    @message_id = get_message_id(attrs['headers'])
  end

  protected

  def decode(orig_charset,str)
    Iconv.conv('UTF-8',orig_charset,str)
  end

  def detokenize(str)
    result = str.match(EMAIL_DETOKENIZE_REGEXP)
    result ? str[1] : str
  end

  def get_message_id(headers)
    headers = ActiveSupport::JSON.decode(headers)
    headers['Message-ID']
  end

end
