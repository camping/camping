%w[rubygems active_record markaby metaid tempfile].each{|l|require l}
module Camping;C=self;F=__FILE__;S=IO.read(F).gsub(/_+FILE_+/,F.dump)
module Helpers;def R c,*args;p=/\(.+?\)/;args.inject(c.urls.find{|x|x.scan(p
).size==args.size}.dup){|str,a|str.sub(p,(a.__send__(a.class.primary_key)rescue
a).to_s)};end;def / p;p[/^\//]?@root+p:p end;def errors_for(o);ul.errors{o.
errors.each_full{|er|li er}}unless o.errors.empty?;end;end;module Controllers
module Base; include Helpers;attr_accessor :input,:cookies,:env,:headers,:body,
:status,:root;def method_missing(m,*a,&b);str=m==:render ? markaview(*a,
&b):eval("markaby.#{m}(*a,&b)");str=markaview(:layout){str} if Views.method_defined? :layout;r(
200,str.to_s);end;def r(s,b,h={});@status=s;@headers.merge!(h);@body=b;end;def 
redirect(c,*args);c=R(c,*args)if c.respond_to?:urls;r(302,'','Location'=>self/c)
end;def service(r,e,m,a)@status,@env,@headers,@root=200,e,{'Content-Type'=>'text/html'},e['SCRIPT_NAME'];cook=C.kp(
e['HTTP_COOKIE']);qs=C.qs_parse(e['QUERY_STRING']);if "post"==m;inp=r.read(e[
'CONTENT_LENGTH'].to_i);if %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)|n.
match(e['CONTENT_TYPE']);b="--#$1";inp.split(/(?:\r?\n|\A)#{Regexp::quote(
b)}(?:--)?\r\n/m).each{|pt|h,v=pt.split("\r\n\r\n",2);fh={};[:name,:filename].
each{|x|fh[x]=$1 if h=~/^Content-Disposition: form-data;.*(?:\s#{x}="([^"]+)")\
/m};fn=fh[:name];if fh[:filename];fh[:type]=$1 if h =~ /^Content-Type: (.+?)(\
\r\n|\Z)/m;fh[:tempfile]=Tempfile.new("C").instance_eval{binmode;write v
rewind;self};else;fh=v;end;qs[fn]=fh if fn};else;qs.merge!(C.qs_parse(inp));end
end;@cookies, @input = cook.dup, qs.dup;@body=send(m,*a) if respond_to? m;@headers["Set-Cookie"]=@cookies.map{|k,v|"#{k}=#{C.
escape(v)}; path=#{self/"/"}" if v != cook[k]}.compact;self;end;def to_s;"Status: #{
@status}\n#{@headers.map{|k,v|[*v].map{
|x|"#{k}: #{x}"}*"\n"}*"\n"}\n\n#{@body}";end;def markaby;Mab.new(
instance_variables.map{|iv|[iv[1..-1],instance_variable_get(iv)]});end;def 
markaview(m,*a,&b);h=markaby;h.send(m,*a,&b);h.to_s
end;end;class R;include Base end;class 
NotFound;def get(p);r(404,div{h1("Cam\ping Problem!")+h2("#{p} not found")});end
end;class ServerError;include Base;def get(k,m,e);r(500,Mab.new{h1 "Cam\ping Problem!"
h2 "#{k}.#{m}";h3 "#{e.class} #{e.message}:";ul{e.backtrace.each{|bt|li(bt)}}}.to_s
)end end;class<<self;def R(*urls);Class.new(R){meta_def(:urls){urls}};end;def 
D(path);constants.inject(nil){|d,c|k=
const_get(c);k.meta_def(:urls){["/#{c.downcase}"]}if !(k<R);d||([k, $~[1..-1]
] if k.urls.find { |x| path =~ /^#{x}\/?$/ })}||[NotFound, [path]];end end end
class<<self;def goes m;eval(S.gsub(/Camping/,m.to_s),TOPLEVEL_BINDING)end;def 
escape s;s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n){'%'+$1.unpack('H2'*$1.size).join(
'%').upcase}.tr(' ','+') end;def unescape(s);s.tr('+', ' ').gsub(/((?:%[0-9a-f\
A-F]{2})+)/n){[$1.delete('%')].pack('H*')} end;def qs_parse qs,d='&;';m=proc{
|_,o,n|o.merge(n,&m)rescue([*o]<<n)};qs.to_s.split(/[#{d}] */n).inject(H[]){
|h,p|k,v=unescape(p).split('=',2);h.merge(k.split(/[\]\[]+/).reverse.inject(v){
|x,i|H[i,x]},&m)}end;def kp(s);c=qs_parse(s,';,');end
def run(r=$stdin,e=ENV);begin;k,a=Controllers.D "/#{e['PATH_INFO']}".
gsub(%r!/+!,'/');m=e['REQUEST_METHOD']||"GET";k.send :include,C,Controllers::Base,
Models;o=k.new;o.service(r,e,m.downcase,a);rescue\
=>x;Controllers::ServerError.new.service(r,e,"get",[k,m,x]);end;end;end
module Views; include Controllers,Helpers end;module Models
A=ActiveRecord;Base=A::Base;def Base.table_name_prefix;"#{name[/^(\w+)/,1]}_".
downcase.sub(/^(#{A}|camping)_/i,'');end;end
class Mab<Markaby::Builder;include Views
def tag!(*g,&b);h=g[-1];[:href,:action].each{|a|(h[a]=self/h[a])rescue 0}
super;end;end;class H<HashWithIndifferentAccess;def method_missing(m,*a)
if m.to_s=~/=$/;self[$`]=a[0];elsif a.empty?;self[m];else;raise NoMethodError,
"#{m}";end;end;end;end
