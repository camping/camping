require "uri";require "rack";class Object;def meta_def m,&b;(class<<self;self
end).send:define_method,m,&b end end;module Camping;C=self;S=IO.read(__FILE__
)rescue nil;P="<h1>Cam\ping Problem!</h1><h2>%s</h2>";U=Rack::Utils;O={};Apps=[]
class H<Hash;def method_missing m,*a;m.to_s=~/=$/?self[$`]=a[0]:a==[]?self[m.
to_s]:super end;undef id,type if ??==63;end;module Helpers;def R c,*g;p,h=
/\(.+?\)/,g.grep(Hash);g-=h;raise"bad route"unless u=c.urls.find{|x|break x if
x.scan(p).size==g.size&&/^#{x}\/?$/=~(x=g.inject(x){|x,a|x.sub p,U.escape((a.
to_param rescue a))}.gsub(/\\(.)/){$1})};h.any?? u+"?"+U.build_query(h[0]):u end;def
/ p;p[0]==?/?@root + p : p end;def URL c='/',*a;c=R(c, *a) if c.respond_to?(
:urls);c=self/c;c=@request.url[/.{8,}?(?=\/)/]+c if c[0]==?/;URI c end end
module Base;attr_accessor:env,:request,:root,:input,:cookies,:state,:status,
:headers,:body;T={};L=:layout;def lookup n;T.fetch(n.to_sym){|k|t=Views.
method_defined?(k)||(f=Dir[[O[:views]||"views","#{n}.*"]*'/'][0])&&Template.
new(f,O[f[/\.(\w+)$/,1].to_sym]||{});O[:dynamic_templates]?t:T[k]=t} end
def render(v,*a,&b)if t=lookup(v);o=Hash===a[-1]?a.pop: {};s=(t==true)?mab{
send v,*a,&b}: t.render(self,o[:locals]||{},&b);s=render(L,o.merge(L=>false)){s
}if v.to_s[0]!=?_&&o[L]!=false&&lookup(L);s;else;raise"Can't find template #{v}"end
end;def mab &b;(@mab||=Mab.new({},self)).capture(&b) end;def r s,b,h={};b,h=h,
b if Hash===b;@status=s;@headers.merge!(h);@body=b;end;def redirect *a;r 302,'',
'Location'=>URL(*a).to_s;end;def r404 p;P%"#{p} not found"end;def r500 k,m,e
raise e;end;def r501 m;P%"#{m.upcase} not implemented"end;def to_a;@env[
'rack.session']=Hash[@state];r=Rack::Response.new(@body,@status,@headers)
@cookies.each{|k,v|next if @old_cookies[k]==v;v={:value=>v,:path=>self/"/"} if
String===v;r.set_cookie(k,v)};r.to_a;end;def initialize(env,m) r=@request=Rack::
Request.new(@env=env);@root,@input,@cookies,@state,@headers,@status,@method=r.
script_name.sub(/\/$/,''),n(r.params),H[@old_cookies = r.cookies],H[r.session],
{},m=~/r(\d+)/?$1.to_i: 200,m end;def n h;Hash===h ?h.inject(H[]){|m,(k,v)|m[k]=
n(v);m}: h end;def service *a;r=catch(:halt){send(@method,*a)};@body||=r;self
end;end;module Controllers;@r=[];class<<self;def r;@r end;def R *u;r=@r;Class.
new{meta_def(:urls){u};meta_def(:inherited){|x|r<<x}}end;def D p,m;p='/'if !p||
!p[0];r.map{|k|k.urls.map{|x|return(k.method_defined? m)?[k,m,*$~[1..-1]]:[I,
'r501',m]if p=~/^#{x}\/?$/}};[I,'r404',p] end;N=H.new{|_,x|x.downcase}.merge!(
"N"=>'(\d+)',"X"=>'([^/]+)',"Index"=>'');def M;def M;end;constants.map{|c|k=
const_get(c);k.send:include,C,X,Base,Helpers,Models;@r=[k]+r if r-[k]==r
k.meta_def(:urls){ [ "/#{c.to_s.scan(/.[^A-Z]*/).map(&N.method(:[]))*'/'}"]}if !k.
respond_to?:urls}end end;I=R();end;X=Controllers;class<<self;def goes m;Apps<<
eval(S.gsub(/Camping/,m.to_s),TOPLEVEL_BINDING) end;def call e;X.M
p=e['PATH_INFO']=U.unescape(e['PATH_INFO']);k,m,*a=X.D p,e['REQUEST_METHOD'].
downcase;k.new(e,m).service(*a).to_a;rescue;r500(:I,k,m,$!,:env=>e).to_a;end
def method_missing m,c,*a;X.M;h=Hash===a[-1]?a.pop: {};e=H[Rack::MockRequest.
env_for('',h.delete(:env)||{})];k=X.const_get(c).new(e,m.to_s);h.each{|i,v|k.
send"#{i}=",v};k.service(*a);end;def use*a,&b;m=a.shift.new(method(:call),*a,&b)
meta_def(:call){|e|m.call(e)}end;def options;O end;def set k,v;O[k]=v end end
module Views;include X,Helpers end;module Models;autoload:Base,'camping/ar';end
autoload:Mab,'camping/mab';autoload:Template,'camping/template';C end
