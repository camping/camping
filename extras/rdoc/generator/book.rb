class RDoc::Generator::Book < RDoc::Generator::SingleDarkfish
	RDoc::RDoc.add_generator(self)
	
	def index_template
	  'book.rhtml'
  end
  
  def chapters
    @chapters ||= @files.each do |file|
      (class << file; self; end).class_eval { attr_accessor :title, :content, :toc, :id }
      file.toc = []
      file.content = convert(file)
      
      file.content.gsub!(%r{<h2>(.*?)</h2>}) do
        file.title = $1
        file.id = make_id($1)
        '<h2 class="ruled" id="%s">%s</h2>' % [file.id, file.title]
      end
      
      file.content.gsub!(%r{<h3>(.*?)</h3>}) do |match|
        arr = [file.id + '-' + make_id($1), $1]
        file.toc << arr
        '<h3 id="%s">%s</h3>' % arr
      end 
    end
  end
  
  def convert(file)
    case File.extname(file.relative_name)
    when '.rdoc', ''
      file.description
    when '.markdown', '.md'
      require 'rdiscount'
      RDiscount.new(file.comment).to_html
    when '.textile'
      require 'redcloth'
      RedCloth.new(file.comment).to_html
    end
  end
  
  def make_id(title)
    title.downcase.gsub(/\s/, '-').gsub(/[^\w-]+/, '')
  end
end
