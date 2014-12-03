module StringHelper

  def self.valid_ruby_variable_name?(str)
    (/^[a-z_][a-zA-Z_0-9]*$/ =~ str) == 0
  end

end