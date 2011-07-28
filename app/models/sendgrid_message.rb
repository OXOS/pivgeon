class SendgridMessage
  require 'iconv'
  extend ActiveModel::Naming
  
  attr_accessor :from, :to, :cc, :subject, :body, :message_id  

  EMAIL_DETOKENIZE_REGEXP = /<(.*)>/
  white_space             = %Q|\x9\x20|
  CRLF                    = /\r\n/
  WSP                     = /[#{white_space}]/
  

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
    Iconv.conv('UTF-8',orig_charset,str)
  end

  def detokenize(str)
    return str if str.blank?
    result = str.match(EMAIL_DETOKENIZE_REGEXP)
    result ? result[1] : str
  end

  def parse_headers(headers)
    Hash[*headers.gsub(/\n|\r\n|\r/) { "\r\n" }.gsub(/#{CRLF}#{WSP}+/,' ').gsub(/#{WSP}+/,' ').split(CRLF).map{|e| e.split(":",2)}.flatten]
  end

  def get_message_id(headers)
    headers = parse_headers(headers)
    headers['Message-ID'] || "" 
  end

end
