%w[rubygems active_record markaby metaid tempfile uri].each{|l|require l}
module Camping;C=self;F=__FILE__;S=IO.read(F).gsub(/_+FILE_+/,F.dump)
module Helpers;def R c,*args;p=/\(.+?\)/;args.inject(c.urls.find{|x|x.scan(p).
size==args.size}.dup){|str,a|str.sub(p,(a.__send__(a.class.primary_key)rescue
a).to_s)} end;def URL c='/',*a;c=R(c,*a)if c.respond_to?:urls;c=self/c;c=
"http://"+@env.HTTP_HOST+c if c[/^\//];URI(c) end;def / p;p[/^\//]?@root+p:p end
def errors_for o;ul.errors{o.errors.each_full{|x|li x}}if o.errors.any? end end
module Base;include Helpers;attr_accessor :input,:cookies,:env,:headers,:body,
:status,:root;def method_missing m,*a,&b;s=m==:render ? markaview(*a,&b):eval(
"markaby.#{m}(*a,&b)");s=markaview(:layout){s} if Views.method_defined?:layout
r 200,s.to_s end;def r s,b,h={};@status=s;@headers.merge!(h);@body=b end;def 
redirect *a;r 302,'','Location'=>URL(*a) end;def initialize r,e,m;e=H[e.to_hash]
@status,@method,@env,@headers,@root=200,m.downcase,e,{'Content-Type'=>"text/htm\
l"},e.SCRIPT_NAME.sub(/\/$/,'');@k=C.kp e.HTTP_COOKIE;q=C.qs_parse e.QUERY_STRING
@in=r;if %r|\Amultipart/form-.*boundary=\"?([^\";,]+)|n.match e.CONTENT_TYPE;b=
/(?:\r?\n|\A)#{Regexp::quote("--#$1")}(?:--)?\r$/;until @in.eof?;fh=H[];for l in
@in;case l;when "\r\n":break;when /^Content-Disposition: form-data;/:fh.u H[*$'.
scan(/(?:\s(\w+)="([^"]+)")/).flatten];when /^Content-Type: (.+?)(\r$|\Z)/m;fh[
:type]=$1;end;end;fn=fh[:name];o=if fh[:filename];fh[:tempfile]=Tempfile.new(:C).
binmode;else;fh="";end;while l=@in.read(16384);if l=~b;o<<$`.chomp;@in.seek(-$'.
size,IO::SEEK_CUR);break;end;o<<l;end;q[fn]=fh if fn;fh[:tempfile].rewind if
fh.is_a?H;end;elsif @method=="post";q.u C.qs_parse(@in.read) end;@cookies,@input=
@k.dup,q.dup end;def service *a;@body=send(@method,*a)if respond_to?@method
@headers["Set-Cookie"]=@cookies.map{|k,v|"#{k}=#{C.escape(v)}; path=#{self/"/"}\
" if v != @k[k]}.compact;self end;def to_s;"Status: #{@status}\n#{@headers.map{
|k,v|[*v].map{|x|"#{k}: #{x}"}*"\n"}*"\n"}\n\n#{@body}" end;def markaby;Mab.new(
instance_variables.map{|iv|[iv[1..-1],instance_variable_get(iv)]}) end;def 
markaview m,*a,&b;h=markaby;h.send m,*a,&b;h.to_s end end;class R;include Base
end;module Controllers;class NotFound;def get p;r(404,div{h1 "Cam\ping Problem!"
h2 p+" not found"}) end end;class ServerError;include Base;def get k,m,e;r(500,
Mab.new{h1 "Cam\ping Problem!";h2 "#{k}.#{m}";h3 "#{e.class} #{e.message}:";ul{
e.backtrace.each{|bt|li(bt)}}}.to_s)end end;class<<self;def R *urls;Class.new(
R){meta_def(:urls){urls}}end;def D path;constants.inject(nil){|d,c|k=const_get c
k.meta_def(:urls){["/#{c.downcase}"]}if !(k<R);d||([k,$~[1..-1]]if k.urls.find{
|x|path=~/^#{x}\/?$/})}||[NotFound,[path]] end end end;class<<self;def goes m
eval(S.gsub(/Camping/,m.to_s),TOPLEVEL_BINDING)end;def escape s;s.to_s.gsub(
/([^ a-zA-Z0-9_.-]+)/n){'%'+$1.unpack('H2'*$1.size).join('%').upcase}.tr ' ','+'
end;def un s;s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n){[$1.delete('%'
)].pack('H*')} end;def qs_parse q,d='&;';m=proc{|_,o,n|o.u(n,&m)rescue([*o
]<<n)};q.to_s.split(/[#{d}] */n).inject(H[]){|h,p|k,v=un(p).split('=',2)
h.u k.split(/[\]\[]+/).reverse.inject(v){|x,i|H[i,x]},&m}end;def kp(s);c=
qs_parse(s,';,')end;def run r=$stdin,e=ENV;k,a=Controllers.D un("/#{e['PATH_INFO']
}".gsub(/\/+/,'/'));k.send:include,C,Base,Models;k.new(r,e,(m=e['REQUEST_METHOD'
]||"GET")).service *a;rescue=>x;Controllers::ServerError.new(r,e,'get').service(
k,m,x)end end;module Views;include Controllers,Helpers end;module Models;A=
ActiveRecord;Base=A::Base;def Base.table_name_prefix;"#{name[/^(\w+)/,1]}_".
downcase.sub(/^(#{A}|camping)_/i,'')end end;class Mab<Markaby::Builder;include \
Views;def tag! *g,&b;h=g[-1];[:href,:action,:src].map{|a|(h[a]=self/h[a])rescue
0};super end end;H=HashWithIndifferentAccess;class H;def method_missing m,*a
if m.to_s=~/=$/;self[$`]=a[0];elsif a.empty?;self[m];else;raise NoMethodError,
"#{m}" end end;alias_method:u,:regular_update;end end
