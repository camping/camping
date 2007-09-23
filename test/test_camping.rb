require "test/unit"
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require "camping"

class Test_Camping_class_methods < Test::Unit::TestCase
  def test_escape_from_the_doc
    assert_equal "I%27d+go+to+the+museum+straightway%21", Camping.escape("I'd go to the museum straightway!")
  end

  def test_utf8_escape
    assert_equal "%E6%97%A5%E6%9C%AC%E5%9B%BD", Camping.escape("\346\227\245\346\234\254\345\233\275")
  end

  def test_unescape_from_the_doc
    assert_equal "I'd go to the museum straightway!", Camping.un("I%27d+go+to+the+museum+straightway%21")
  end

  def test_utf8_unescape
    assert_equal "\346\227\245\346\234\254\345\233\275", Camping.un("%E6%97%A5%E6%9C%AC%E5%9B%BD")
  end

  def test_qsp_from_the_doc
    input = Camping.qsp("name=Philarp+Tremain&hair=sandy+blonde")
    assert_equal "Philarp Tremain", input.name
    assert_equal "sandy blonde", input.hair
  end

  def test_qsp_with_array
    input = Camping.qsp("users[]=why&users[]=rambo")
    assert_equal ["why", "rambo"], input.users
  end

  def test_qsp_with_hash
    input = Camping.qsp("post[id]=1&post[user]=_why")
    hash = {'post' => {'id' => '1', 'user' => '_why'}}
    assert_equal hash, input
  end

  def test_qsp_malformed1
    input = Camping.qsp("name=Philarp+Tremain&&hair=sandy+blonde")
    assert_equal "Philarp Tremain", input.name
    assert_equal "sandy blonde", input.hair
  end

  def test_qsp_malformed2
    input = Camping.qsp("morta==del")
    assert_equal "=del", input.morta
  end

  # TODO : Test Camping.kp
  # TODO : Test Camping.run

end

