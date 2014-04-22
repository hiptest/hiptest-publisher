# encoding: UTF-8

module Actionwords
  def start_publisher(options = {})
    # TODO: Implement action: "start publisher with options #{options}"
    raise NotImplementedError
  end
  def parameters_and_assignements(no_default, default_integer = 1, default_string = 'My string', default_list = [])
    # Tags: parameters parameters:defaulted assignements
    nil_var = nil
    float_var = (3.14 - default_integer)
    list_var = [nil_var, [float_var]]
    dict_var = {a: '1', b: 1}
  end
  def control_blocks(x)
    # Tags: parameters dsltests
    while ((x < 0))
      x = x + 1
    end
    if ((x == 0))
      # TODO: Implement result: "#{x} is now equal to zero"
    else
      control_blocks(x = x - 1)
    end
  end
end