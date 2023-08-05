require "cam\ping/loads";E||="content-type";Z||="text/html"
class Object;def meta_def m,&b;(class<<self;self
end).define_method(m,&b) end;end
module Camping;C=self;S=IO.read(__FILE__)rescue nil
P="<h1>Cam\ping Problem!</h1><h2>%s</h2>";U=Rack::Utils;Apps=[];SK="camping";G=[]
class H<Hash;def method_missing m,*a;m.to_s=~/=$/?self[$`]=a[0]:a==[]?self[m
.to_s]:super end;undef id,type if ??==63;end;O=H.new;O[:url_prefix]=""
class Cookies<H;attr_accessor :_p
def _n;@n||={}end;alias _s []=;def set k,v,o={};_s(j=k.to_s,v);_n[j] =
{:value=>v,:path=>_p}.update o;end;def []=(k,v)set k,v,v.is_a?(Hash)?v:{} end
end
module Helpers;def R c,*g;p,h=
/\(.+?\)/,g.grep(Hash);g-=h;raise"bad route"if !u=c.urls.find{|x|break x if
x.scan(p).size==g.size&&/^#{x}\/?$/=~(x=g.inject(x){|x,a|x.sub p,U.escape((a.
to_param rescue a))}.gsub(CampTools.descape){$1})};h.any?? u+"?"+U.build_query(h[0]) : u
end;def /(p) p[0]==?/ ?(@root+@url_prefix.dup.prepend("/").chop+p) : p end
def URL c='/',*a;c=R(c,*a)if c.respond_to?(
:urls);c=self/c;c=@request.url[/.{8,}?(?=\/|$)/]+c if c[0]==?/;URI c end
def app_name;"Camping"end end
module Base;attr_accessor:env,:request,:root,:input,:cookies,:state,:status,
:headers,:body,:url_prefix;T={};L=:layout
def lookup n;T.fetch(n.to_sym){|k|t=Views.
method_defined?(k)||(t=O[:_t].keys.grep(/^#{n}\./)[0]and Template[t].new{
O[:_t][t]})||(f=Dir[[O[:views]||"views","#{n}.*"]*'/'][0])&&Template.
new(f,O[f[/\.(\w+)$/,1].to_sym]||{});O[:dynamic_templates]?t: T[k]=t}end
def render v,*a,&b;if t=lookup(v);r=@_r;@_r=o=Hash===a[-1]?a.pop: {};s=(t==true)?mab{
send v,*a,&b}: t.render(self,o[:locals]||{},&b);s=render(L,o.merge(L=>false)){s
} if o[L] or o[L].nil?&&lookup(L)&&!r&&v.to_s[0]!=?_;s else raise "no template: #{v}"
end end
def mab &b;extend Mab;mab &b;end
def r s,b,h={};b,h=h,b if Hash===b;@status=s;@headers.merge!(h);@body=b end
def redirect *a;r 302,'','Location'=>URL(*a).to_s;end
def r404 p;P%"#{p} not found"end
def r500 k,m,e;raise e end
def r501 m;P % "#{m.upcase} not implemented"end
def serve p,c;t=Rack::Mime.mime_type(p[/\..*$/], Z)and@headers[E]=t;c;end
def to_a;@env['rack.session'][SK]=Hash[@state];r=Rack::Response.new(@body,
@status,@headers);@cookies._n.each{|k,v|r.set_cookie k,v};r.to_a end
def initialize env,m,p
r=@request=Rack::Request.new(@env=env);@root,@input,@cookies,@state,@headers,
@status,@method,@url_prefix=r.script_name.sub(/\/$/,''),n(r.params),
Cookies[r.cookies],H[r.session[SK]||{}],{E=>Z},m=~/r(\d+)/?$1.to_i: 200,m,p
@cookies._p=self/"/";end
def n h;Hash===h ?h.inject(H[]){|m,(k,v)|m[k]=n(v);m}: h end
def service *a;r=catch(:halt){send(@method,*a)};@body||=r;self end end
module Controllers;@r=[];class Camper end;class<<self
def R *u;r,uf=@r,u.first;Class.new((uf.is_a?(Class)&&
(uf.ancestors.include?(Camper))) ? u.shift : Camper) {
meta_def(:urls){u};meta_def(:inherited){|x|r<< x} } end
def v;@r.map(&:urls);end
def D p,m,e;p='/'if
!p||!p[0];(a=O[:_t].find{|n,_|n==p}) and return [I,:serve,*a]
@r.map{|k|k.urls.map{|x|return(k.method_defined? m)?[k,m,*$~[1..-1].map{|x|U.unescape x}]:
[I, 'r501',m]if p=~/^#{x}\/?$/}};[I,'r404',p] end;
A=->(c,u,p){d=p.dup;d.chop! if u=='';u.prepend("/"+d) if !["I"].
include? c.to_s
if c.to_s=="Index";while d[-1]=="/";d.chop! end;u.prepend("/"+d)end;u}
N=H.new{|_,x|x.downcase}.merge! "N"=>'(\d+)',"X"=>'([^/]+)',"Index"=>''
def M p;def M p;end
constants.filter{|c|c.to_s!='Camper'}.map{|c|k=const_get(c);
k.include(C,X,Base,Helpers,Models)
@r=[k]+@r if @r-[k]==@r;mu=false;ka=k.ancestors
if (k.respond_to?(:urls) && ka[1].respond_to?(:urls)) && (k.urls == ka[1].urls)
mu = true unless ka[1].name == nil end
k.meta_def(:urls){[A.(k,"#{c.to_s.scan(/.[^A-Z]*/).map(&N.method(:[]))*'/'}",p)]} if (!k
.respond_to?(:urls) || mu==true)};end end;I=R()end;X=Controllers
class<<self;def make_camp;X.M prx;Apps.map(&:make_camp) end;def routes;(Apps.map(&:routes)<<X.v).flatten end
def prx;@_prx||=CampTools.normalize_slashes(O[:url_prefix])end
def call e;k,m,*a=X.D e["PATH_INFO"],e['REQUEST_METHOD'].
downcase,e;k.new(e,m,prx).service(*a).to_a;rescue;r500(:I,k,m,$!,:env=>e).to_a end
def method_missing m,c,*a;h=Hash===a[-1]?a.pop : {};e=H[Rack::MockRequest.
env_for('',h.delete(:env)||{})];k=X.const_get(c).new(e,m.to_s,prx);h.each{|i,v|
k.send"#{i}=",v};k.service(*a)end
def use*a,&b;m=a.shift.new(method(:call),*a,&b);meta_def(:call){|e|m.call(e)};m;end
def pack*a,&b;G<< g=a.shift;include g;g.setup(self,*a,&b)end
def gear;G end;def options;O;end;def set k,v;O[k]=v end
def goes m,g=TOPLEVEL_BINDING;sp=caller[0].split('`')[0].split(":");fl,ln,pr=
sp[0]+' <Cam\ping App> ',sp[1].to_i,nil;Apps<< a=eval(S.gsub(/Camping/,m.to_s),g,fl,1);caller[0]=~/:/
IO.read(a.set:__FILE__,$`)=~/^__END__/&&(b=$'.split(/^@@\s*(.+?)\s*\r?\n/m)
).shift rescue nil;a.set :_t,H[*b||[]]
a.set :_meta, H[file: fl, line_number: ln, parent: self,
root: (name != "Cam\ping" ? '/' + CampTools.to_snake(name) : '/')];C.configure(a)end end
module Views;include X,Helpers end;module Models
Helpers.include(X,self) end;autoload:Mab,'camping/mab'
autoload:Template,'camping/template';pack Gear::Inspection;pack Gear::Filters
pack Gear::Nancy;pack Gear::Kuddly;C end
