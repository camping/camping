%w[rubygems active_record markaby metaid ostruct tempfile].each{|l|require l}
module Camping;C=self
module Helpers;def R c,*args;p=/\(.+?\)/;args.inject(c.urls.detect{|x|x.
scan(p).size==args.size}.dup){|str,a|str.gsub(p,(a.method(a.class.primary_key
)[]rescue a).to_s)};end;def / p;File.join(@root,p) end;end;module Controllers
module Base;include Helpers;attr_accessor :input,:cookies,:headers,:body,
:status,:root;def method_missing(m,*args,&blk);str=m==:render ? markaview(
*args,&blk):eval("markaby.#{m}(*args,&blk)");str=markaview(:layout){str
}rescue nil;r(200,str.to_s);end;def r(s,b,h={});@status=s;@headers.merge!(h)
@body=b;end;def redirect(c,*args);c=R(c,*args)if c.respond_to?:urls;r(302,'',
'Location'=>self/c);end;def service(r,e,m,a)@status,@headers,@root=200,{},e[
'SCRIPT_NAME'];cook=C.cookie_parse(e['HTTP_COOKIE']);qs=C.qs_parse(e[
'QUERY_STRING']);if "POST"==m;inp=r.read(e['CONTENT_LENGTH'].to_i);if 
%r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n.match(e['CONTENT_TYPE'])
b="--#$1";inp.split(/(?:\r?\n|\A)#{Regexp::quote(b)}(?:--)?\r\n/m).each{|pt|
h,v=pt.split("\r\n\r\n",2);fh={};[:name,:filename].each{|x|fh[x]=$1 if h=~
/Content-Disposition: form-data;.*(?:\s#{x}="([^"]+)")/m};fn=fh[:name];if fh[
:filename];fh[:type]=$1 if h =~ /Content-Type: (.+?)(\r\n|\Z)/m;fh[:tempfile]=
Tempfile.new("#{C}").instance_eval{binmode;write v;rewind;self};else;fh=v;end
qs[fn]=fh if fn};else;qs.merge!(C.qs_parse(inp));end;end;@cookies,@input=[cook,
qs].map{|_|OpenStruct.new(_)};@body=method(m.downcase).call(*a);@headers["Set-\
Cookie"]=@cookies.marshal_dump.map{|k,v|"#{k}=#{C.escape(v)}; path=/" if v != 
cook[k]}.compact;self;end;def to_s
"Status: #{@status}\n#{{'Content-Type'=>'text/html'}.merge(@headers).map{|k,v|
v.to_a.map{|v2|"#{k}: #{v2}"}}.flatten.join("\n")}\n\n#{@body}";end;def \
markaby;Mab.new(instance_variables.map{|iv|[iv[1..-1],instance_variable_get(iv
)]},{})
end;def markaview(m,*args,&blk);markaby.instance_eval{Views.instance_method(m
).bind(self).call(*args, &blk);self}.to_s;end;end;class R;include Base end
class NotFound<R;def get(p);r(404,div{h1("#{C} Problem!")+h2("#{p} not found")
});end end;class ServerError<R;def get(k,m,e);r(500,markaby.div{h1 "#{C} Prob\
lem!";h2 "#{k}.#{m}";h3 "#{e.class} #{e.message}:";ul{e.backtrace.each{|bt|li(
bt)}}})end end;class<<self;def R(*urls);Class.new(R){meta_def(:inherited){|c|
c.meta_def(:urls){urls}}};end;def D(path);constants.each{|c|k=const_get(c)
return k,$~[1..-1] if (k.urls rescue "/#{c.downcase}").find {|x|path=~/^#{x}\
\/?$/}};[NotFound,[path]];end end end;class<<self;def escape(s);s.to_s.gsub(
/([^ a-zA-Z0-9_.-]+)/n){'%'+$1.unpack('H2'*$1.size).join('%').upcase}.tr(' ',
'+') end;def unescape(s);s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n){[$1.
delete('%')].pack('H*')} end;def qs_parse(qs,d ='&;');(qs||'').split(/[#{d}]\
 */n).inject({}){|hsh, p|k,v=p.split('=',2).map{|v|unescape(v)};hsh[k]=v \
unless v.blank?;hsh} end; def cookie_parse(s);c=qs_parse(s,';,') end
def run(r=$stdin,w=$stdout);w<<begin;k,a=Controllers.D "/#{ENV['PATH_INFO']}".
gsub(%r!/+!,'/');m=ENV['REQUEST_METHOD']||"GET";k.class_eval{include C
include Controllers::Base;include Models};o=k.new;o.service(r,ENV,m,a);rescue\
=>e;Controllers::ServerError.new.service(r,ENV,"GET",[k,m,e]);end;end;end
module Views; include Controllers; include Helpers end;module Models;end
Models::Base=ActiveRecord::Base;class Mab<Markaby::Builder;include Views
def tag!(*g,&b);[:href,:action].each{|a|(g.last[a]=self./(g.last[a]))rescue 0}
super;end;end;end
