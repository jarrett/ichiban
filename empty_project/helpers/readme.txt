You can write custom helper modules and put them in this directory. The methods they define
will be available in your templates. For example:

# helpers/my_helper.rb

module MyHelper
  def double(num)
    num * 2
  end
end