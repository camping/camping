require 'test_helper'
require 'camping'
require 'camping/commands'

# The idea behind the inception stuff is that you can inherit settings
# templates, etc... from a Camping app and just... extend it.
# This is a tabled, but not abandoned idea. It became a little difficult
# to inherit all of these things, along with views, Models, etc... that's
# associated with a camping app. Getting this to work would mean a big
# rewrite of Camping's core, which is a no no.

Camping.goes :Inception
# Inception.goes :Leonardo
# Leonardo.goes :Donatello

class Inception::Test < TestCase
  def the_app
    app = Camping::Apps.select{|a| a.name == "Inception" }.first
    app.make_camp
    app
  end

#   def the_child
#     app = Inception::Apps.select{|a| a.name == "Leonardo" }.first
#     app.make_camp
#     app
#   end
#
#   def the_brother
#     app = Leonardo::Apps.select{|a| a.name == "Donatello" }.first
#     app.make_camp
#     app
#   end

  # Test that the S is pretty big in the app.
  # def test_has_big_s
  #   s = the_app::S
  #   c = the_child::S
  #   b = the_brother::S
  #   # assert (s.length == c.length), "This S is the wrong length. parent: #{s.length}, child: #{c.length}."
  #   assert (c.length == b.length), "This S is the wrong length. child: #{c.length}, brother: #{b.length}."
  # end

  # Test that a Gsubbed S is equivalent.

end
