class Pie
    
  RADIANS = Math::PI/180
  MIN_PERCENT = (0.1 / 360.0) * 100
  MAX_PERCENT = 100 - MIN_PERCENT
  
  def initialize(data)
    @data = data
  end
  
  def draw(size)
    position = size / 2
    offset = (size < 20 ? 1 : size / 20)
    offset = 5 if offset > 5
    radius = position - offset
    
    total = @data.inject(0){|sum, item| sum + item[:value].to_f}
    percent_scale = 100.0 / total

    full_circle = false
    angles = [12.5 * 3.6 * RADIANS]
    slices = []
    
    @data.each do |item|
      percent = percent_scale * item[:value].to_f
      percent = MIN_PERCENT if percent < MIN_PERCENT
      if percent > MAX_PERCENT
        full_circle = item
      else
        prev_angle = angles.last
        angles << prev_angle + (percent * 3.6 * RADIANS)
        slices << {:start => angles[-2], :end => angles[-1], :style => item[:style]}
    	end
    end
    
    rvg = Magick::RVG.new(size,size) do |canvas|
      canvas.background_fill = 'white'
      
      # is there a full circle here? then draw it
      canvas.circle(radius,position,position).styles(:fill => full_circle[:style]) if full_circle
      
      # draw the fills of the slices
      slices.each do |slice|
        canvas.path(slice_path(position,position,radius,slice[:start],slice[:end])).styles(:fill => slice[:style])
      end
      
      # outline the graph
      canvas.circle(radius,position,position).styles(:stroke => 'black', :stroke_width => 0.7, :fill => 'transparent')
      
      # draw lines between each slice
      angles[0..-2].each do |a|
        canvas.line(position, position, position+(Math.sin(a)*radius), position-(Math.cos(a)*radius)).styles(:stroke => 'black', :stroke_width => 0.7, :fill => 'transparent')
      end
    end
    
    rvg.draw

  end
  
protected

  def slice_path(x, y, size, start_angle, end_angle)
    x_start = x+(Math.sin(start_angle) * size)
    y_start = y-(Math.cos(start_angle) * size)
    x_end = x+(Math.sin(end_angle) * size)
    y_end = y-(Math.cos(end_angle) * size)
    "M#{x},#{y} L#{x_start},#{y_start} A#{size},#{size} 0, #{end_angle - start_angle >= 50 * 3.6 * RADIANS ? '1' : '0'},1, #{x_end} #{y_end} Z"
  end
  
end