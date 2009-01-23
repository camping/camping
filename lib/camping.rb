%w[uri stringio rack].map{|l|require l};class Object;def meta_def m,&b
(class<<self;self end).send:define_method,m,&b end end;module Camping;C=self
S=IO.read(__FILE__)rescue nil;P="<h1>Cam\ping Problem!</h1><h2>%s</h2>"
U=Rack::Utils;Apps=[];class H<Hash
def method_missing m,*a;m.to_s=~/=$/?self[$`]=a[0]:a==[]?self[m.to_s]:super end
undef id,type;end;module Helpers;def R c,*g
p,h=/\(.+?\)/,g.grep(Hash);g-=h;raise"bad route"unless u=c.urls.find{|x|
break x if x.scan(p).size==g.size&&/^#{x}\/?$/=~(x=g.inject(x){|x,a|
x.sub p,U.escape((a[a.class.primary_key]rescue a))})}
h.any?? u+"?"+U.build_query(h[0]):u end;def / p
p[0]==?/?@root+p:p end;def URL c='/',*a;c=R(c, *a) if c.respond_to?:urls
c=self/c;c=@request.url[/.{8,}?(?=\/)/]+c if c[0]==?/;URI c end
end;module Base;attr_accessor:input,:cookies,:headers,:body,:status,:root
M=proc{|_,o,n|o.merge(n,&M)}
def render v,*a,&b;mab(/^_/!~v.to_s){send(v,*a,&b)} end
def mab l=nil,&b;m=Mab.new({},self);s=m.capture(&b)
s=m.capture{layout{s}} if l && m.respond_to?(:layout);s end
def r s,b,h={};b,h=h,b if Hash===b;@status=s;
@headers.merge!(h);@body=b;end;def redirect *a;r 302,'','Location'=>URL(*a).
to_s;end;def r404 p;P%"#{p} not found"end;def r500 k,m,e;raise e;end
def r501 m;P%"#{m.upcase} not implemented"end;def to_a
r=Rack::Response.new(@body,@status,@headers)
@cookies.each{|k,v|v={:value=>v,:path=>self/"/"} if String===v
r.set_cookie(k,v)}
r.to_a;end;def initialize(env,m)
r=@request=Rack::Request.new(@env=env)
@root,p,@cookies,@headers,@status,@method=
(env.SCRIPT_NAME||'').sub(/\/$/,''),H[r.params],
H[r.cookies],{},m=~/r(\d+)/?$1.to_i: 200,m
@input=p.inject(H[]){|h,(k,v)|h.merge k.split(/[\]\[]+/).reverse.inject(v){|x,i|
H[i=>x]},&M};end;def service *a
r=catch(:halt){send(@method,*a)};@body||=r
self;end;end;module Controllers;@r=[];class<<self;def r;@r end;def R *u;r=@r
Class.new{meta_def(:urls){u};meta_def(:inherited){|x|r<<x}}end
def D p,m;p='/'if !p||!p[0]
r.map{|k|k.urls.map{|x|return(k.instance_method(m)rescue nil)?
[k,m,*$~[1..-1]]:[I,'r501',m]if p=~/^#{x}\/?$/}};[I,'r404',p] end
N=H.new{|_,x|x.downcase}.merge! "N"=>'(\d+)',"X"=>'([^/]+)',"Index"=>''
def M;def M;end;constants.map{|c|k=const_get(c)
k.send:include,C,Base,Helpers,Models;@r=[k]+r if r-[k]==r
k.meta_def(:urls){["/#{c.scan(/.[^A-Z]*/).map(&N.method(:[]))*'/'}"]
}if !k.respond_to?:urls}end end;I=R()
end;X=Controllers;class<<self;def goes m
Apps<<eval(S.gsub(/Camping/,m.to_s),TOPLEVEL_BINDING) end;def call e
X.M;e=H[e];p=e.PATH_INFO=U.unescape(e.PATH_INFO)
k,m,*a=X.D p,(e.REQUEST_METHOD||'get').downcase
k.new(e,m).service(*a).to_a;rescue;r500(:I,k,m,$!,:env=>e).to_a;end
def method_missing m,c,*a;X.M;h=Hash===a[-1]?a.pop: {}
e=H[Rack::MockRequest.env_for('',h[:env]||{})]
k=X.const_get(c).new(e,m.to_s);k.send("input=",h[:input])if h[:input]
k.service(*a);end;end;module Views;include X,Helpers end;module Models
autoload:Base,'camping/ar';def Y;self;end end;autoload:Mab,'camping/mab';C end
