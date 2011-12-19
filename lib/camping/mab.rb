require 'cgi'

begin
  require 'mab'
rescue LoadError
  module Mab
    class Error < StandardError; end
    SELFCLOSING = %w[base link meta hr br wbr img embed param source track area col input keygen command]

    %w[a abbr acronym address applet area article aside audio b base
  basefont bdi bdo big blockquote body br button canvas caption center cite
  code col colgroup command datalist dd del details dfn dir div dl dt em
  embed fieldset figcaption figure font footer form frame frameset h1 h2 h3 h4 h5
  h6 head header hgroup hr html i iframe img input ins keygen kbd label
  legend li link map mark math menu meta meter nav noframes noscript object ol
  optgroup option output p param pre progress q rp rt ruby s samp script
  section select small source span strike strong style sub summary sup svg
  table tbody td textarea tfoot th thead time title tr track tt u ul var video
  wbr xmp].each do |tag|
      sc = SELFCLOSING.include?(tag).inspect
      class_eval "def #{tag}(*args, &blk); mab_tag :#{tag}, #{sc}, *args, &blk end"
    end

    class Tag
      def initialize(context, instance, name, sc)
        @context = context
        @instance = instance
        @name = name
        @sc = sc
      end

      def attributes
        @attributes ||= {}
      end

      def merge_attributes(attrs)
        if defined?(@attributes)
          @attributes.merge!(attrs)
        else
          @attributes = attrs
        end
      end

      def method_missing(name, content = nil, attrs = nil, &blk)
        name = name.to_s

        if name[-1] == ?!
          attributes[:id] = name[0..-2]
        else
          if attributes.has_key?(:class)
            attributes[:class] << " #{name}"
          else
            attributes[:class] = name.dup
          end
        end

        insert(content, attrs, &blk)
      end

      def insert(content = nil, attrs = nil, &blk)
        raise Error, "This tag is already closed" if @done

        if content.is_a?(Hash)
          attrs = content
          content = nil
        end

        merge_attributes(attrs) if attrs

        if block_given?
          raise Error, "`#{@name}` is not allowed to have content" if @sc
          @done = :block
          before = @context.size
          res = yield
          @content = res if @context.size == before
          @context << "</#{@name}>"
        elsif content
          raise Error, "`#{@name}` is not allowed to have content" if @sc
          @done = true
          @content = CGI.escapeHTML(content.to_s)
        elsif attrs
          @done = true
        end

        self
      end

      def to_ary; nil end
      def to_str; to_s end

      def to_s
        @result ||= begin
          res = "<#{@name}#{attrs_to_s}>"
          res << @content if @content
          res << "</#{@name}>" if !@sc && @done != :block
          res
        end
      end

      def inspect; to_s.inspect end

      def attrs_to_s
        @instance.mab_attributes(attributes).inject("") do |res, (name, value)|
          if value
            value = (value == true) ? name : CGI.escapeHTML(value.to_s)
            res << " #{name}=\"#{value}\""
          end
          res
        end
      end
    end

    def mab
      old = @mab_context
      ctx = @mab_context = []
      res = yield if block_given?
      ctx.empty? ? res : ctx.join
    ensure
      @mab_context = old
    end

    def mab_tag(name, sc, content = nil, attrs = nil, &blk)
      ctx = @mab_context || raise(Error, "Tags can only be written within a `mab { }`-block")
      tag = Tag.new(ctx, self, name, sc)
      ctx << tag
      tag.insert(content, attrs, &blk)
    end

    def mab_attributes(attrs)
      attrs
    end

    def text(str = nil, &blk)
      str = str ? CGI.escapeHTML(str.to_s) : blk.call.to_s
      if @mab_context
        @mab_context << str
      else
        str
      end
    end
  end
end

$MAB_CODE = %{
  module Mab
    PREPEND_SCRIPT_NAME = {:href => true, :src => true, :action => true}
    include ::Mab

    def mab
      extend Views
      super
    end

    alias capture mab 
    alias << text

    def mab_attributes(attrs)
      attrs.map do |k, v|
        if PREPEND_SCRIPT_NAME.include?(k)
          [k, self / v]
        else
          [k, v]
        end
      end
    end
  end
}

Camping::S.sub! /autoload\s*:Mab\s*,\s*['"]camping\/mab['"]/, $MAB_CODE
Camping::Apps.each do |c|
  c.module_eval $MAB_CODE
end
