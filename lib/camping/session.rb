module Camping::Models
class Session < Base
    serialize :ivars
    def []=(k, v)
        self.ivars[k] = v
    end
    def [](k)
        self.ivars[k] rescue nil
    end

    RAND_CHARS = [*'A'..'Z'] + [*'0'..'9'] + [*'a'..'z']

    def self.generate cookies
        rand_max = RAND_CHARS.size
        sid = (0..32).inject("") { |ret,_| ret << RAND_CHARS[rand(rand_max)] }
        sess = Session.create :hashid => sid, :ivars => Camping::H[]
        cookies.camping_sid = sess.hashid
        sess
    end
    def self.persist cookies
        if cookies.camping_sid
            session = Camping::Models::Session.find_by_hashid cookies.camping_sid
        end
        unless session
            session = Camping::Models::Session.generate cookies
        end
        session
    end
    def self.create_schema
        unless table_exists?
            ActiveRecord::Schema.define do
                create_table :sessions, :force => true do |t|
                    t.column :id,          :integer, :null => false
                    t.column :hashid,      :string,  :limit => 32
                    t.column :created_at,  :datetime
                    t.column :ivars,       :text
                end
            end
            reset_column_information
        end
    end
end
end

module Camping
module Session
    def service(*a)
        session = Camping::Models::Session.persist @cookies
        app = self.class.name.gsub(/^(\w+)::.+$/, '\1')
        @state = (session.ivars[app] ||= Camping::H[])
        hash_before = Marshal.dump(@state).hash
        s = super(*a)
        if session
            hash_after = Marshal.dump(@state).hash
            unless hash_before == hash_after
                session.ivars[app] = @state
                session.save
            end
        end
        s
    end
end
end
