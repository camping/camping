#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + "/../../lib"
$:.unshift File.dirname(__FILE__)
require 'rubygems'
require 'fileutils'
require 'camping'
require 'rvg/rvg'
require 'pie'
  
Camping.goes :Charts

module Charts::Controllers
  class Index < R '/'
    def get
      # find all charts
      @charts = Dir.glob("charts/*.gif").sort_by{|f|f.match(/(\d+)/)[1].to_i}.reverse
      
      # keep only ten charts
      (@charts[10..-1] || []).each{|f|FileUtils.rm(f,:force => true)}
      @charts = @charts[0..9]
      
      render :index
    end
  end
  
  class Create < R '/create'
    def post
      # get our data
      slices = input.data.split(',')
      slices.reject!{|slice| slice !~ /\d+/}
      slices.map!{|slice| slice.match(/(\d+)/)[1].to_i}
      slices = [100] if slices.empty?
      
      data = slices.map{|slice| {:value => slice, :style => "rgb(#{rand(255)},#{rand(255)},#{rand(255)})"}}
      
      # save our chart
      chart = Pie.new(data)
      i = Dir.glob("charts/*.gif").map{|f|f.match(/(\d+)/)[1].to_i + 1}.max || 1
      chart.draw(25).write("charts/#{i}.gif")
      
      redirect Index
    end
  end
  
  class Chart < R '/charts/(.+\.gif)'
    def get filename
      @headers["Content-Type"] = "image/gif"
      
      @body = File.read("charts/#{filename}")
    end
  end
end

module Charts::Views

  def layout
    html do
      head do
        title 'Charts!'
      end
      body do
        div.content do
          self << yield
        end
      end
    end
  end

  def index
    form(:method => 'post', :action => '/create') do
      label do
        input :name => 'data', :type => 'text', :value => '10,20,30'
      end
      input :type => 'submit', :value => 'Prepare a chart'
    end
    
    div.charts do
      @charts.each do |src|
        img :src => src
      end
    end
  end
    
end
 
if __FILE__ == $0
  Charts.run
end
