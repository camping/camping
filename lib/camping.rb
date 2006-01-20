%w[rubygems active_record markaby metaid ostruct].each { |lib| require lib }

module Camping
  C = self
  module Models; end ; Models::Base = ActiveRecord::Base

  module Helpers
    def R(c,*args)
      p = /\(.+?\)/
      args.inject(c.urls.detect{|x|x.scan(p).size==args.size}.dup){|str,a|
        str.gsub(p,(a.method(a.class.primary_key)[] rescue a).to_s)
      }
    end
    def /(u); File.join(@root,u) end
  end
  module Controllers
    module RM
      include Helpers
      attr_accessor :input, :cookies, :headers, :body, :status, :root
      def method_missing(m, *args, &blk)
        str = m==:render ? markaview(*args, &blk):eval("markaby.#{m}(*args, &blk)")
        str = markaview(:layout) { str } rescue nil
        r(200, str.to_s)
      end
      def redirect(*args)
        c, *args = args
        c = R(c,*args) if c.respond_to? :urls
        r(302, '', 'Location' => self/c)
      end
      def r(s, b, h = {}); @status = s; @headers.merge!(h); @body = b; end
      def service(r, e, m, a)
        @status, @headers, @root = 200, {}, e['SCRIPT_NAME']
        @cookies = C.cookie_parse(e['HTTP_COOKIE'] || e['COOKIE'])
        cook = @cookies.marshal_dump.dup
        if ("POST" == e['REQUEST_METHOD']) and
            %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n.match(e['CONTENT_TYPE'])
          return r(500, "Urgh, multipart/form-data not yet supported.")
        else
          @input = C.qs_parse(e['REQUEST_METHOD'] == "POST" ? 
                                    r.read(e['CONTENT_LENGTH'].to_i) : e['QUERY_STRING'])
        end

        @body = method( m.downcase ).call(*a)
        @headers['Set-Cookie'] = @cookies.marshal_dump.map { |k,v| "#{k}=#{C.escape(v)}; path=/" if v != cook[k] }.compact
        self
      end
      def to_s
        "Status: #{@status}\n#{{'Content-Type'=>'text/html'}.merge(@headers).map{|k,v|v.to_a.map{|v2|"#{k}: #{v2}"}}.flatten.join("\n")}\n\n#{@body}"
      end
      private
      def markaby
          Class.new(Markaby::Builder) {@root=@root;include Views;def tag!(*g,&b);[:href,:action].each{|a|(g.last[a]=self./(g.last[a]))rescue 0};super end }.new( instance_variables.map { |iv| 
            [iv[1..-1].intern, instance_variable_get(iv)] }, {} )
      end
      def markaview(m, *args, &blk)
        markaby.instance_eval { Views.instance_method(m).bind(self).call(*args, &blk); self }.to_s
      end
    end
    class R; include RM end
    class NotFound < R; def get; r(404, div{h1("#{C} Problem!")+h2('Not Found')}); end end

    class << self
      def R(*urls); Class.new(R) { meta_def(:inherited) { |c| c.meta_def(:urls) { urls } } }; end
      def D(path)
        constants.each do |c| 
            k = const_get(c)
            return k, $~[1..-1] if (k.urls rescue "/#{c.downcase}").find { |x| path =~ /^#{x}\/?$/ }
        end
        [NotFound, []]
      end
    end
  end

  class Response; include Controllers::RM
    def initialize(s = 200, &blk)
      @headers, @body, @status = {}, "", s
      instance_eval &blk
    end
  end

  class << self
    def escape(s); s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n){'%'+$1.unpack('H2'*$1.size).join('%').upcase}.tr(' ', '+') end
    def unescape(s); s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n){[$1.delete('%')].pack('H*')} end
    def qs_parse(qs, d = '&;'); OpenStruct.new((qs||'').split(/[#{d}] */n).
        inject({}){|hsh, p|k, v = p.split('=',2).map {|v| unescape(v)}; hsh[k] = v unless v.empty?; hsh}) end
    def cookie_parse(s); c = qs_parse(s, ';,'); end
    def run(r=$stdin,w=$stdout)
      w <<
        begin
          k, a = Controllers.D "/#{ENV['PATH_INFO']}".gsub(%r!/+!,'/')
          m = ENV['REQUEST_METHOD']||"GET"
          k.class_eval { include C; include Controllers::RM; include Models }
          o = k.new
          o.service(r, ENV, m, a)
        rescue => e
          Response.new(200) { @body = Markaby::Builder.new({}, {}) { h1 "#{C} Problem!"; h2 "#{k}.#{m}"; h3 "#{e.class} #{e.message}:"; ul { e.backtrace.each { |bt| li bt } } }.to_s }
        end
    end
  end
  module Views; include Controllers; include Helpers end
end
