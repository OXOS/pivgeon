#TODO: publish this fix in github
#Fix for gem 'multipart-post'
Net::HTTP::Post::Multipart::Parts::FilePart.class_eval do
  def initialize(boundary, name, io)
    file_length = io.respond_to?(:length) ? io.length : File.size(io.path)
    @head = build_head(boundary, name, io.original_filename, io.content_type, file_length,
                       io.respond_to?(:opts) ? io.opts : {})
    @foot = "\r\n"
    @length = @head.length + file_length + @foot.length
    @io = CompositeReadIO.new(StringIO.new(@head), io, StringIO.new(@foot))
  end
end