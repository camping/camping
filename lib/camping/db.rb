require 'active_support'
class MissingLibrary < Exception #:nodoc: all
end
begin
    require 'active_record'
rescue LoadError => e
    raise MissingLibrary, "ActiveRecord could not be loaded (is it installed?): #{e.message}"
end
module Camping
  module Models
    A = ActiveRecord
    # Base is an alias for ActiveRecord::Base.  The big warning I'm going to give you
    # about this: *Base overloads table_name_prefix.*  This means that if you have a
    # model class Blog::Models::Post, it's table name will be <tt>blog_posts</tt>.
    #
    # ActiveRecord is not loaded if you never reference this class.  The minute you
    # use the ActiveRecord or Camping::Models::Base class, then the ActiveRecord library
    # is loaded.
    Base = A::Base

    # The default prefix for Camping model classes is the topmost module name lowercase
    # and followed with an underscore.
    #
    #   Tepee::Models::Page.table_name_prefix
    #     #=> "tepee_pages"
    #
    def Base.table_name_prefix
        "#{name[/\w+/]}_".downcase.sub(/^(#{A}|camping)_/i,'')
    end
  end
end
Camping::S.sub! "autoload:Base,'camping/db'", "Base=ActiveRecord::Base"
Camping::Apps.each do |app|
    app::Models::Base = ActiveRecord::Base
end
